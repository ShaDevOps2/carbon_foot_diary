import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import 'export_dialog.dart';

enum PeriodMode { day, week, month, year, custom }

/// Reports and analytics with custom-painted charts and CSV export (FR-08).
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  PeriodMode _mode = PeriodMode.week;
  DateTimeRange? _customRange;

  (DateTime, DateTime, DateTime, DateTime) _resolve(AppState s) {
    final now = DateTime.now();
    final today = AppState.dayOf(now);
    final tomorrow = today.add(const Duration(days: 1));

    switch (_mode) {
      case PeriodMode.day:
        return (today, tomorrow, today.subtract(const Duration(days: 1)), today);
      case PeriodMode.week:
        final w = s.weekStart;
        return (w, w.add(const Duration(days: 7)), w.subtract(const Duration(days: 7)), w);
      case PeriodMode.month:
        final m = s.monthStart;
        final next = DateTime(m.year, m.month + 1);
        final prev = DateTime(m.year, m.month - 1);
        return (m, next, prev, m);
      case PeriodMode.year:
        final y = DateTime(now.year);
        return (y, DateTime(now.year + 1), DateTime(now.year - 1), y);
      case PeriodMode.custom:
        final r = _customRange ?? DateTimeRange(start: today.subtract(const Duration(days: 14)), end: today);
        final len = r.duration.inDays + 1;
        return (r.start, r.end.add(const Duration(days: 1)), r.start.subtract(Duration(days: len)), r.start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final (from, to, prevFrom, prevTo) = _resolve(s);
    final total = s.totalBetween(from, to);
    final prevTotal = s.totalBetween(prevFrom, prevTo);
    final breakdown = s.breakdown(from, to);
    final days = to.difference(from).inDays.clamp(1, 365);
    final dailyAvg = total / days;

    // Daily series for line chart.
    final seriesLen = days.clamp(3, 14);
    final series = [
      for (var i = seriesLen - 1; i >= 0; i--)
        s.totalBetween(to.subtract(Duration(days: i + 1)), to.subtract(Duration(days: i))),
    ];
    final seriesLabels = [
      for (var i = seriesLen - 1; i >= 0; i--)
        Fmt.dateShort(to.subtract(Duration(days: i + 1))),
    ];

    // Category bar data.
    final barData = [
      for (final e in breakdown.entries)
        BarDatum(e.key.label, e.value, e.key.color, icon: e.key.icon),
    ];

    // Find highest emission day.
    var highestDayVal = 0.0;
    for (var d = 0; d < days; d++) {
      final cur = from.add(Duration(days: d));
      final val = s.totalBetween(cur, cur.add(const Duration(days: 1)));
      if (val > highestDayVal) {
        highestDayVal = val;
      }
    }

    final topCategory = breakdown.entries.isEmpty ? null : breakdown.entries.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Insights'),
        actions: [
          IconButton(
            tooltip: 'Export report',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => ExportDialog(
                from: from,
                to: to,
                total: total,
                breakdown: breakdown,
                modeLabel: _mode.name.toUpperCase(),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final m in PeriodMode.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(m.name[0].toUpperCase() + m.name.substring(1)),
                          selected: _mode == m,
                          onSelected: (v) async {
                            if (m == PeriodMode.custom) {
                              final r = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now(),
                                initialDateRange: _customRange,
                              );
                              if (r != null) setState(() { _customRange = r; _mode = m; });
                            } else {
                              setState(() => _mode = m);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                gradient: AppColors.heroGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Total emissions', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                        const Spacer(),
                        TrendChip(now: total, prev: prevTotal, onDark: true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedNumber(
                          total,
                          decimals: 1,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text('kg CO₂e', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('vs ${Fmt.kgShort(prevTotal)} kg in previous period',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Daily average',
                      value: Fmt.kgShort(dailyAvg),
                      icon: Icons.speed_rounded,
                      color: AppColors.sky,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: StatTile(
                      label: 'Peak day',
                      value: Fmt.kgShort(highestDayVal),
                      icon: Icons.trending_up_rounded,
                      color: AppColors.amber,
                    ),
                  ),
                ],
              ),
              if (topCategory != null) ...[
                const SizedBox(height: 14),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CategoryAvatar(topCategory.key, size: 44),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Highest-emission category',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                            Text('${topCategory.key.label} (${Fmt.kgShort(topCategory.value)} kg)',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                      ),
                      Text('${total > 0 ? (topCategory.value / total * 100).toStringAsFixed(0) : 0}%',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: topCategory.key.color)),
                    ],
                  ),
                ),
              ],
              const SectionHeader('Emission trend'),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: TrendLineChart(
                  values: series,
                  labels: seriesLabels,
                  color: AppColors.forest,
                  height: 170,
                ),
              ),
              const SectionHeader('Category breakdown'),
              if (barData.isEmpty)
                const EmptyState(icon: Icons.pie_chart_outline_rounded, title: 'No emissions in this period', message: 'Log some activities to see your category breakdown.')
              else ...[
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      DonutChart(
                        data: barData,
                        size: 180,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(Fmt.kgShort(total), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                            const Text('kg total', style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (final d in barData) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
                              const SizedBox(width: 10),
                              Expanded(child: Text(d.label, style: const TextStyle(fontWeight: FontWeight.w600))),
                              Text('${Fmt.kg(d.value)} kg', style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              Text('${total > 0 ? (d.value / total * 100).toStringAsFixed(0) : 0}%',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category comparison', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 14),
                      SimpleBarChart(data: barData, height: 180),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const EstimateNote(),
            ],
          ),
        ),
      ),
    );
  }
}
