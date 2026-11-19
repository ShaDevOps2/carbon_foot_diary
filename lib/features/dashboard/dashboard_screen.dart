import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../domain/models.dart';
import '../diary/entry_detail_screen.dart';
import '../goals/goals_screens.dart';
import '../notifications/notifications_screen.dart';
import '../recommendations/recommendations_screen.dart';

/// Home dashboard (FR-07).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onSeeDiary, required this.onSeeInsights});
  final VoidCallback onSeeDiary;
  final VoidCallback onSeeInsights;

  static const dailyBudget = 10.0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final user = s.currentUser!;
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final unread = s.notifications.where((n) => !n.read).length;
    final week = s.dailySeries(7);
    final now = DateTime.now();
    final labels = [for (var i = 6; i >= 0; i--) Fmt.weekday(now.subtract(Duration(days: i))).substring(0, 1)];
    final monthBreak = s.breakdown(s.monthStart, now.add(const Duration(days: 1)));
    final top = monthBreak.entries.isEmpty ? null : monthBreak.entries.first;
    final recent = s.myEntries.take(4).toList();
    final recs = s.recommendations;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Hero(
                  name: user.name.split(' ').first,
                  initials: user.initials,
                  today: s.todayTotal,
                  yesterday: s.yesterdayTotal,
                  budget: dailyBudget,
                  streak: s.streak,
                  unread: unread,
                  onBell: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                sliver: SliverList.list(
                  children: [
                    Row(children: [
                      Expanded(
                        child: FadeSlideIn(
                          child: StatTile(
                            label: 'This week',
                            value: Fmt.kgShort(s.weekTotal),
                            imagePath: 'assets/images/badges/img_1.png',
                            color: AppColors.sky,
                            now: s.weekTotal,
                            prev: s.lastWeekTotal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: FadeSlideIn(
                          index: 1,
                          child: StatTile(
                            label: 'This month',
                            value: Fmt.kgShort(s.monthTotal),
                            imagePath: 'assets/images/badges/img_1.png',
                            color: AppColors.waste,
                            now: s.monthTotal,
                            prev: s.lastMonthTotal,
                          ),
                        ),
                      ),
                    ]),
                    const SectionHeader('Last 7 days'),
                    AppCard(
                      onTap: onSeeInsights,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text('${Fmt.kgShort(week.fold(0.0, (a, b) => a + b))} kg', style: t.titleLarge),
                            const SizedBox(width: 8),
                            Text('total', style: TextStyle(color: scheme.onSurfaceVariant)),
                            const Spacer(),
                            Row(children: [
                              Container(width: 14, height: 2, color: AppColors.coral),
                              const SizedBox(width: 6),
                              Text('Daily budget', style: t.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                            ]),
                          ]),
                          const SizedBox(height: 16),
                          TrendLineChart(values: week, labels: labels, target: dailyBudget, height: 150),
                        ],
                      ),
                    ),
                    if (top != null) ...[
                      const SectionHeader('Top category this month'),
                      _TopCategoryCard(category: top.key, value: top.value, total: s.monthTotal),
                    ],
                    if (s.goals.isNotEmpty) ...[
                      SectionHeader('Goals', action: 'See all',
                          onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen()))),
                      GoalCard(goal: s.goals.first),
                    ],
                    SectionHeader('Suggested for you', action: 'More',
                        onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecommendationsScreen()))),
                    SizedBox(
                      height: 168,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: recs.length.clamp(0, 4),
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => SizedBox(width: 260, child: RecommendationCard(rec: recs[i], compact: true)),
                      ),
                    ),
                    SectionHeader('Recent entries', action: 'View diary', onAction: onSeeDiary),
                    if (recent.isEmpty)
                      const EmptyState(icon: Icons.edit_note_rounded, title: 'No entries yet', message: 'Tap the + button to log your first activity.')
                    else
                      for (final (i, e) in recent.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: FadeSlideIn(
                            index: i,
                            child: EntryTile(
                              entry: e,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EntryDetailScreen(entry: e))),
                            ),
                          ),
                        ),
                    const SizedBox(height: 12),
                    const EstimateNote(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.name,
    required this.initials,
    required this.today,
    required this.yesterday,
    required this.budget,
    required this.streak,
    required this.unread,
    required this.onBell,
  });

  final String name;
  final String initials;
  final double today;
  final double yesterday;
  final double budget;
  final int streak;
  final int unread;
  final VoidCallback onBell;

  @override
  Widget build(BuildContext context) {
    final over = today > budget;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.forestDeep,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        child: Stack(
          children: [
            // Realistic organic leaf texture background
            Positioned.fill(
              child: Image.asset(
                'assets/images/leaf_hero_bg.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            // Premium dark green gradient overlay for text readability & depth
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0F3D2C).withValues(alpha: 0.88),
                      const Color(0xFF1E6B4E).withValues(alpha: 0.82),
                      const Color(0xFF0F3D2C).withValues(alpha: 0.94),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 28),
                child: Column(
                  children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Fmt.greeting(), style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                            Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Notifications',
                        onPressed: onBell,
                        icon: Badge(
                          isLabelVisible: unread > 0,
                          label: Text('$unread'),
                          backgroundColor: AppColors.amber,
                          textColor: AppColors.forestDeep,
                          child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      CarbonRing(
                        progress: today / budget,
                        size: 156,
                        colors: over ? const [AppColors.amber, AppColors.coral] : const [AppColors.mint, Color(0xFFB8F5D9)],
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedNumber(today,
                                decimals: 1,
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1)),
                            Text('kg CO₂e today', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              over ? 'Above daily budget' : '${Fmt.kgShort(budget - today)} kg left',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text('of your ${Fmt.num(budget)} kg daily budget',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                            const SizedBox(height: 14),
                            Row(children: [
                              TrendChip(now: today, prev: yesterday, onDark: true),
                              const SizedBox(width: 6),
                              Text('vs yesterday', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                            ]),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(100)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.local_fire_department_rounded, color: AppColors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text('$streak-day streak', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _TopCategoryCard extends StatelessWidget {
  const _TopCategoryCard({required this.category, required this.value, required this.total});
  final CategoryType category;
  final double value;
  final double total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : value / total;
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          CategoryAvatar(category, size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.label, style: t.titleMedium),
                const SizedBox(height: 2),
                Text('${Fmt.kgShort(value)} kg CO₂e · ${(pct * 100).toStringAsFixed(0)}% of month',
                    style: t.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 10),
                SoftProgressBar(value: pct, color: category.color, height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
