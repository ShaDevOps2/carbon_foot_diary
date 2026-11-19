import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../core/theme/app_colors.dart';
import '../domain/carbon_calculator.dart';
import '../domain/models.dart';
import 'seed_data.dart';

/// Central in-memory store for the app. A REST-backed repository can replace
/// this later without changing the UI layer.
class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }

  // ---------------- Session & settings ----------------
  final List<AppUser> users = [];
  AppUser? currentUser;
  ThemeMode themeMode = ThemeMode.light;
  bool rememberMe = true;
  int _failedLogins = 0;
  DateTime? _lockedUntil;

  bool pushEnabled = true;
  bool emailEnabled = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 20, minute: 30);
  final Map<String, bool> notifyCategories = {
    'Daily reminders': true,
    'Goal progress': true,
    'Achievements': true,
    'Challenges': true,
    'Weekly summary': true,
  };

  // ---------------- Data ----------------
  final List<EmissionFactor> factors = SeedData.factors();
  final List<DiaryEntry> entries = [];
  final List<Goal> goals = [];
  final List<Challenge> challenges = SeedData.challenges();
  final List<AppNotification> notifications = [];
  final List<FeedbackItem> feedback = [];
  final List<AuditLog> auditLogs = [];
  final Set<CategoryType> inactiveCategories = {};
  int quizzesCompleted = 1;

  bool get isAdmin => currentUser?.role == UserRole.admin;
  bool get isMetric => currentUser?.metric ?? true;

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void refresh() => notifyListeners();

  // ---------------- Auth (FR-01, FR-02) ----------------
  int? get lockSecondsLeft {
    if (_lockedUntil == null) return null;
    final s = _lockedUntil!.difference(DateTime.now()).inSeconds;
    return s > 0 ? s : null;
  }

  /// Returns null on success, or an error message.
  String? login(String email, String password, {bool remember = true}) {
    final lock = lockSecondsLeft;
    if (lock != null) return 'Too many attempts. Try again in ${lock}s.';
    final user = users.where((u) => u.email.toLowerCase() == email.trim().toLowerCase()).firstOrNull;
    if (user == null || user.password != password) {
      _failedLogins++;
      if (_failedLogins >= 5) {
        _lockedUntil = DateTime.now().add(const Duration(seconds: 60));
        _failedLogins = 0;
        return 'Too many attempts. Login locked for 60 seconds.';
      }
      return 'Incorrect email or password (${5 - _failedLogins} attempts left).';
    }
    if (user.status == AccountStatus.suspended) return 'This account is suspended.';
    _failedLogins = 0;
    rememberMe = remember;
    currentUser = user;
    notifyListeners();
    return null;
  }

  String? register({
    required String name,
    required String email,
    required String password,
    required String country,
    required bool metric,
  }) {
    if (users.any((u) => u.email.toLowerCase() == email.trim().toLowerCase())) {
      return 'An account with this email already exists.';
    }
    final user = AppUser(
      id: 'u${users.length + 1}',
      name: name.trim(),
      email: email.trim(),
      password: password,
      country: country,
      metric: metric,
    );
    users.add(user);
    currentUser = user;
    notifyListeners();
    return null;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  void deleteAccount() {
    final u = currentUser;
    if (u == null) return;
    u.status = AccountStatus.pendingDeletion;
    entries.removeWhere((e) => e.userId == u.id);
    currentUser = null;
    notifyListeners();
  }

  // ---------------- Catalogue ----------------
  List<Activity> activitiesFor(CategoryType c) =>
      SeedData.activities.where((a) => a.category == c).toList();

  Activity? activity(String id) => SeedData.activities.where((a) => a.id == id).firstOrNull;

  EmissionFactor? factorFor(String activityId) =>
      factors.where((f) => f.activityId == activityId && f.active).firstOrNull;

  // ---------------- Diary (FR-04, FR-05) ----------------
  List<DiaryEntry> get myEntries {
    final id = currentUser?.id;
    return entries.where((e) => e.userId == id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  DiaryEntry addEntry({
    required Activity? activity,
    required CategoryType category,
    required String description,
    required double quantity,
    required String unit,
    required DateTime date,
    String notes = '',
    double? customFactor,
    int passengers = 1,
    bool roundTrip = false,
    double renewable = 0,
  }) {
    final f = activity == null ? null : factorFor(activity.id);
    final factorValue = customFactor ?? f?.value ?? 0;
    final emission = CarbonCalculator.calculate(
      quantity: quantity,
      unit: unit,
      factor: factorValue,
      passengers: passengers,
      roundTrip: roundTrip,
      renewablePercent: renewable,
    );
    final isRecycle = activity?.id == 'recycled';
    final entry = DiaryEntry(
      id: 'e${DateTime.now().microsecondsSinceEpoch}',
      userId: currentUser!.id,
      activityId: activity?.id ?? 'custom',
      category: category,
      description: description,
      quantity: quantity,
      unit: unit,
      factorId: f?.id ?? 'user_provided',
      factorValue: factorValue,
      factorVersion: f?.version ?? 0,
      emission: emission,
      avoided: isRecycle ? quantity * 0.5 : 0,
      date: date,
      notes: notes,
      isUserFactor: customFactor != null,
    );
    entries.add(entry);
    _maybeNotifyFirstEntry();
    notifyListeners();
    return entry;
  }

  void updateEntry(DiaryEntry e, {required double quantity, required DateTime date, required String notes}) {
    e
      ..quantity = quantity
      ..date = date
      ..notes = notes
      ..emission = CarbonCalculator.calculate(quantity: quantity, unit: e.unit, factor: e.factorValue)
      ..updatedAt = DateTime.now();
    notifyListeners();
  }

  /// Re-applies the latest active factor (user-initiated only).
  void recalculateWithLatest(DiaryEntry e) {
    final f = factorFor(e.activityId);
    if (f == null) return;
    e
      ..factorId = f.id
      ..factorValue = f.value
      ..factorVersion = f.version
      ..emission = CarbonCalculator.calculate(quantity: e.quantity, unit: e.unit, factor: f.value)
      ..updatedAt = DateTime.now();
    notifyListeners();
  }

  void deleteEntry(DiaryEntry e) {
    entries.remove(e);
    notifyListeners();
  }

  // ---------------- Aggregations (FR-07, FR-08) ----------------
  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  double totalBetween(DateTime from, DateTime to, {CategoryType? category}) => myEntries
      .where((e) => !e.date.isBefore(from) && e.date.isBefore(to))
      .where((e) => category == null || e.category == category)
      .fold(0.0, (s, e) => s + e.emission);

  double get todayTotal {
    final t = dayOf(DateTime.now());
    return totalBetween(t, t.add(const Duration(days: 1)));
  }

  double get yesterdayTotal {
    final t = dayOf(DateTime.now());
    return totalBetween(t.subtract(const Duration(days: 1)), t);
  }

  DateTime get weekStart {
    final t = dayOf(DateTime.now());
    return t.subtract(Duration(days: t.weekday - 1));
  }

  double get weekTotal => totalBetween(weekStart, weekStart.add(const Duration(days: 7)));
  double get lastWeekTotal => totalBetween(weekStart.subtract(const Duration(days: 7)), weekStart);

  DateTime get monthStart => DateTime(DateTime.now().year, DateTime.now().month);
  double get monthTotal => totalBetween(monthStart, DateTime(monthStart.year, monthStart.month + 1));
  double get lastMonthTotal => totalBetween(DateTime(monthStart.year, monthStart.month - 1), monthStart);

  Map<CategoryType, double> breakdown(DateTime from, DateTime to) {
    final map = <CategoryType, double>{};
    for (final e in myEntries.where((e) => !e.date.isBefore(from) && e.date.isBefore(to))) {
      map[e.category] = (map[e.category] ?? 0) + e.emission;
    }
    final sorted = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  /// Daily totals for the last [days] days (oldest first).
  List<double> dailySeries(int days, {DateTime? end}) {
    final last = dayOf(end ?? DateTime.now());
    return [
      for (var i = days - 1; i >= 0; i--)
        totalBetween(last.subtract(Duration(days: i)), last.subtract(Duration(days: i - 1))),
    ];
  }

  int get streak {
    var s = 0;
    var d = dayOf(DateTime.now());
    final days = myEntries.map((e) => dayOf(e.date)).toSet();
    if (!days.contains(d)) d = d.subtract(const Duration(days: 1));
    while (days.contains(d)) {
      s++;
      d = d.subtract(const Duration(days: 1));
    }
    return s;
  }

  // ---------------- Goals (FR-10) ----------------
  double goalActual(Goal g) => totalBetween(g.start, g.end.add(const Duration(days: 1)), category: g.category);

  GoalStatus goalStatus(Goal g) => CarbonCalculator.goalStatus(
        actual: goalActual(g),
        target: g.target,
        start: g.start,
        end: g.end.add(const Duration(days: 1)),
      );

  void saveGoal(Goal g) {
    if (!goals.contains(g)) goals.add(g);
    notifyListeners();
  }

  void deleteGoal(Goal g) {
    goals.remove(g);
    notifyListeners();
  }

  // ---------------- Gamification (FR-13) ----------------
  Set<String> get earnedBadges {
    final mine = myEntries;
    final set = <String>{};
    if (mine.isNotEmpty) set.add('first');
    if (streak >= 7) set.add('streak7');
    if (mine.where((e) => ['bicycle', 'walk', 'train'].contains(e.activityId)).length >= 5) set.add('traveller');
    if (mine.where((e) => e.activityId == 'recycled').length >= 5) set.add('waste');
    if (goals.any((g) => goalStatus(g) == GoalStatus.completed)) set.add('goal');
    return set;
  }

  int get points =>
      myEntries.length * 5 +
      quizzesCompleted * 10 +
      SeedData.achievements.where((a) => earnedBadges.contains(a.id)).fold(0, (s, a) => s + a.points);

  // ---------------- Recommendations (FR-11) ----------------
  List<Recommendation> get recommendations {
    final from = dayOf(DateTime.now()).subtract(const Duration(days: 30));
    final b = breakdown(from, DateTime.now().add(const Duration(days: 1)));
    final recent = myEntries.where((e) => e.date.isAfter(from)).toList();
    final list = <Recommendation>[];
    int count(String id) => recent.where((e) => e.activityId == id).length;

    if ((b[CategoryType.transport] ?? 0) > 0 && count('car_petrol') >= 5) {
      list.add(const Recommendation(title: 'Try public transport twice a week', body: 'Car trips are your top transport source. Swapping two commutes for LRT or bus could noticeably lower your weekly total.', category: CategoryType.transport, impact: 'High impact'));
    }
    if (count('beef') + count('lamb') >= 3) {
      list.add(const Recommendation(title: 'Swap one red-meat meal', body: 'Replacing one beef or lamb meal with chicken or a plant-based dish is one of the easiest food swaps.', category: CategoryType.food, impact: 'High impact'));
    }
    if ((b[CategoryType.electricity] ?? 0) > 20) {
      list.add(const Recommendation(title: 'Set air-con to 25 °C', body: 'Electricity is a big slice of your footprint. A slightly warmer setting and a fan can reduce usage.', category: CategoryType.electricity, impact: 'Medium impact'));
    }
    if (count('food_waste') >= 2) {
      list.add(const Recommendation(title: 'Plan meals to cut food waste', body: 'You logged food waste several times recently. A weekly meal plan and shopping list can help.', category: CategoryType.food, impact: 'Medium impact'));
    }
    if (count('plastic') >= 2) {
      list.add(const Recommendation(title: 'Carry a reusable kit', body: 'A bottle, bag and container in your bag can reduce plastic waste entries.', category: CategoryType.waste, impact: 'Low impact'));
    }
    list.add(const Recommendation(title: 'Take shorter showers', body: 'Cutting a few minutes from each shower saves water-heating energy.', category: CategoryType.water, impact: 'Low impact'));
    return list;
  }

  // ---------------- Feedback (FR-19) ----------------
  void submitFeedback(String type, String subject, String description) {
    feedback.insert(
      0,
      FeedbackItem(id: 'f${feedback.length + 1}', userId: currentUser?.id, type: type, subject: subject, description: description),
    );
    notifyListeners();
  }

  // ---------------- Admin (FR-06, FR-16–18) ----------------
  void _audit(String action, String record, String prev, String next) {
    auditLogs.insert(0, AuditLog(adminId: currentUser?.id ?? 'system', action: action, record: record, previous: prev, next: next));
  }

  void updateFactor(EmissionFactor f, double value, String source) {
    final prev = '${f.value} (v${f.version})';
    f
      ..value = value
      ..source = source
      ..version = f.version + 1
      ..effectiveDate = DateTime.now()
      ..updatedAt = DateTime.now();
    _audit('Updated emission factor', f.id, prev, '$value (v${f.version})');
    notifyListeners();
  }

  void toggleFactor(EmissionFactor f) {
    f.active = !f.active;
    _audit(f.active ? 'Activated factor' : 'Deactivated factor', f.id, '${!f.active}', '${f.active}');
    notifyListeners();
  }

  void toggleCategory(CategoryType c) {
    final wasActive = !inactiveCategories.contains(c);
    wasActive ? inactiveCategories.add(c) : inactiveCategories.remove(c);
    _audit(wasActive ? 'Deactivated category' : 'Activated category', c.label, '$wasActive', '${!wasActive}');
    notifyListeners();
  }

  void setUserStatus(AppUser u, AccountStatus s) {
    _audit('Changed account status', u.email, u.status.name, s.name);
    u.status = s;
    notifyListeners();
  }

  void setUserRole(AppUser u, UserRole r) {
    _audit('Changed role', u.email, u.role.name, r.name);
    u.role = r;
    notifyListeners();
  }

  void respondFeedback(FeedbackItem f, String response, String status) {
    f
      ..response = response
      ..status = status;
    _audit('Responded to feedback', f.id, '-', status);
    notifyListeners();
  }

  void _maybeNotifyFirstEntry() {
    if (myEntries.length == 1) {
      notifications.insert(0, AppNotification(title: 'Badge unlocked: First Entry', message: 'You logged your first activity. Great start!', icon: Icons.emoji_events_rounded, color: AppColors.amber, time: DateTime.now()));
    }
  }

  // ---------------- Seed ----------------
  void _seed() {
    users.addAll([
      AppUser(id: 'u1', name: 'Aisyah Rahman', email: 'user@cfootnote.app', password: 'Demo@1234', createdAt: DateTime.now().subtract(const Duration(days: 120))),
      AppUser(id: 'admin', name: 'Admin Daniel', email: 'admin@cfootnote.app', password: 'Admin@1234', role: UserRole.admin, createdAt: DateTime.now().subtract(const Duration(days: 300))),
      AppUser(id: 'u3', name: 'Wei Jie Tan', email: 'weijie@example.com', password: 'x', createdAt: DateTime.now().subtract(const Duration(days: 40))),
      AppUser(id: 'u4', name: 'Priya Nair', email: 'priya@example.com', password: 'x', createdAt: DateTime.now().subtract(const Duration(days: 12))),
      AppUser(id: 'u5', name: 'Hafiz Ismail', email: 'hafiz@example.com', password: 'x', status: AccountStatus.suspended, createdAt: DateTime.now().subtract(const Duration(days: 75))),
      AppUser(id: 'u6', name: 'Emily Wong', email: 'emily@example.com', password: 'x', status: AccountStatus.pendingDeletion, createdAt: DateTime.now().subtract(const Duration(days: 5))),
    ]);

    final rnd = Random(7);
    final today = dayOf(DateTime.now());
    final pattern = <(String, double, double)>[
      ('car_petrol', 14, 10), ('train', 18, 6), ('bus', 8, 4), ('grid_elec', 6, 4),
      ('aircon', 4, 3), ('chicken', 1, 1), ('rice', 2, 1), ('beef', 1, 0),
      ('plant', 1, 1), ('shower', 8, 6), ('general_waste', 1.5, 1), ('recycled', 1, 1),
      ('online_order', 1, 0), ('lpg', 0.4, 0.2), ('walk', 2, 2), ('food_waste', 0.3, 0.2),
      ('plastic', 0.3, 0.2), ('laundry', 1, 0),
    ];
    for (final uid in ['u1', 'u3', 'u4']) {
      for (var d = 0; d < 75; d++) {
        final date = today.subtract(Duration(days: d)).add(Duration(hours: 8 + rnd.nextInt(10)));
        for (final (id, base, spread) in pattern) {
          if (rnd.nextDouble() > 0.42) continue;
          final a = activity(id)!;
          final f = factorFor(id)!;
          final qty = double.parse((base + rnd.nextDouble() * spread).toStringAsFixed(1));
          entries.add(DiaryEntry(
            id: 's$uid$d$id',
            userId: uid,
            activityId: id,
            category: a.category,
            description: a.name,
            quantity: qty,
            unit: a.unit,
            factorId: f.id,
            factorValue: f.value,
            factorVersion: f.version,
            emission: CarbonCalculator.calculate(quantity: qty, unit: a.unit, factor: f.value),
            avoided: id == 'recycled' ? qty * 0.5 : 0,
            date: date,
            createdAt: date,
            updatedAt: date,
          ));
        }
      }
    }

    goals.addAll([
      Goal(id: 'g1', name: 'Weekly footprint under 60 kg', period: GoalPeriod.weekly, baseline: 72, target: 60, start: weekStart, end: weekStart.add(const Duration(days: 6))),
      Goal(id: 'g2', name: 'Cut transport this month', period: GoalPeriod.monthly, category: CategoryType.transport, baseline: 140, target: 110, start: monthStart, end: DateTime(monthStart.year, monthStart.month + 1, 0)),
      Goal(id: 'g3', name: 'Daily budget 9 kg', period: GoalPeriod.daily, baseline: 11, target: 9, start: today, end: today),
    ]);

    final now = DateTime.now();
    notifications.addAll([
      AppNotification(title: 'Time to log your day', message: 'Take 30 seconds to record today\'s activities.', icon: Icons.edit_calendar_rounded, color: AppColors.forest, time: now.subtract(const Duration(hours: 1))),
      AppNotification(title: 'Goal check-in', message: 'You\'re on track for "Weekly footprint under 60 kg". Keep going!', icon: Icons.flag_rounded, color: AppColors.success, time: now.subtract(const Duration(hours: 20))),
      AppNotification(title: 'Car-Free Week: day 4', message: 'You\'re over halfway through the challenge.', icon: Icons.no_crash_rounded, color: AppColors.sky, time: now.subtract(const Duration(days: 1, hours: 3)), read: true),
      AppNotification(title: 'Your weekly summary is ready', message: 'Last week you emitted 8% less than the week before.', icon: Icons.insights_rounded, color: AppColors.waste, time: now.subtract(const Duration(days: 3)), read: true),
    ]);

    feedback.addAll([
      FeedbackItem(id: 'f1', userId: 'u3', type: 'Calculation concern', subject: 'Grid factor seems high', description: 'Is the electricity factor for Malaysia up to date?', createdAt: now.subtract(const Duration(days: 2))),
      FeedbackItem(id: 'f2', userId: 'u4', type: 'Feature suggestion', subject: 'Add carpool option', description: 'Would love to split car emissions with friends automatically.', createdAt: now.subtract(const Duration(days: 4)), status: 'In review'),
      FeedbackItem(id: 'f3', userId: null, type: 'Bug report', subject: 'Chart label overlaps', description: 'On small phones the bar labels overlap.', createdAt: now.subtract(const Duration(days: 9)), status: 'Resolved', response: 'Fixed in v1.0.1, thanks!'),
    ]);

    auditLogs.addAll([
      AuditLog(adminId: 'admin', action: 'Updated emission factor', record: 'ef_grid_elec', previous: '0.61 (v1)', next: '0.58 (v1)', time: now.subtract(const Duration(days: 6))),
      AuditLog(adminId: 'admin', action: 'Changed account status', record: 'hafiz@example.com', previous: 'active', next: 'suspended', time: now.subtract(const Duration(days: 10))),
    ]);
  }
}

/// Exposes [AppState] to the widget tree.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
