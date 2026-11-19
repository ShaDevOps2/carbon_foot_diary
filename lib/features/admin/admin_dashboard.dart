import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../domain/models.dart';
import 'audit_logs_screen.dart';

/// Administrator Overview and System Stats (FR-16).
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final users = s.users;
    final totalEntries = s.entries.length;
    final totalEmissions = s.entries.fold(0.0, (sum, e) => sum + e.emission);
    final activeUsers = users.where((u) => u.status == AccountStatus.active).length;

    // Top categories overall
    final catTotals = <CategoryType, double>{};
    for (final e in s.entries) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.emission;
    }
    final sortedCats = catTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final barData = [
      for (final e in sortedCats.take(5))
        BarDatum(e.key.label, e.value, e.key.color, icon: e.key.icon),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Audit Logs',
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditLogsScreen())),
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => s.logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
          AppCard(
            gradient: AppColors.heroGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text('System Health: Healthy', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(100)),
                      child: const Text('Live', style: TextStyle(color: AppColors.forestDeep, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Total Tracked Carbon', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                Text('${Fmt.kg(totalEmissions)} kg CO₂e',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Registered Users',
                  value: '${users.length}',
                  icon: Icons.people_rounded,
                  color: AppColors.sky,
                  unit: '$activeUsers active',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatTile(
                  label: 'Total Diary Entries',
                  value: '$totalEntries',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.forest,
                  unit: 'activities logged',
                ),
              ),
            ],
          ),
          const SectionHeader('Most active categories'),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aggregated System Emissions', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 14),
                SimpleBarChart(data: barData, height: 180),
              ],
            ),
          ),
          const SectionHeader('Recent System Actions'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, log) in s.auditLogs.take(4).indexed) ...[
                  if (i > 0) const Divider(),
                  ListTile(
                    leading: const Icon(Icons.security_update_good_rounded, color: AppColors.forest),
                    title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('${log.record} (${log.previous} ➔ ${log.next})', style: const TextStyle(fontSize: 12)),
                    trailing: Text(Fmt.ago(log.time),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                  ),
                ],
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
