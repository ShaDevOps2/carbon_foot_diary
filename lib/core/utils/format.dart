/// Formatting and validation helpers (no external packages).
abstract final class Fmt {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String kg(double v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(2)} t' : v.toStringAsFixed(2);
  static String kgShort(double v) => v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  static String month(int m) => _months[(m - 1) % 12];
  static String weekday(DateTime d) => _days[d.weekday - 1];
  static String date(DateTime d) => '${d.day} ${month(d.month)} ${d.year}';
  static String dateShort(DateTime d) => '${d.day} ${month(d.month)}';
  static String time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String relativeDay(DateTime d) {
    final now = DateTime.now();
    final a = DateTime(d.year, d.month, d.day);
    final b = DateTime(now.year, now.month, now.day);
    final diff = b.difference(a).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${weekday(d)}, ${dateShort(d)}';
    return date(d);
  }

  static String ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static String pctChange(double now, double prev) {
    if (prev == 0) return '—';
    final p = (now - prev) / prev * 100;
    return '${p >= 0 ? '+' : ''}${p.toStringAsFixed(0)}%';
  }

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  static String num(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

abstract final class Validators {
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    if (!_email.hasMatch(v.trim())) return 'Enter a valid email, e.g. name@mail.com';
    return null;
  }

  static String? required(String? v, [String field = 'This field']) =>
      v == null || v.trim().isEmpty ? '$field is required' : null;

  /// 0–4 strength score.
  static int strength(String p) {
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (strength(v) < 4) return 'Use 8+ chars with upper, lower, number & symbol';
    return null;
  }

  static String? positiveNumber(String? v) {
    final n = double.tryParse(v ?? '');
    if (n == null) return 'Enter a number';
    if (n <= 0) return 'Must be greater than 0';
    if (n > 100000) return 'That looks too large';
    return null;
  }
}
