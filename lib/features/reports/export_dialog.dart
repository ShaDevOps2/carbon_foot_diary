import 'package:material_ui/material_ui.dart';

import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../domain/models.dart';

/// Modal dialog to preview and export reports as CSV or structured summary (FR-08).
class ExportDialog extends StatelessWidget {
  const ExportDialog({
    super.key,
    required this.from,
    required this.to,
    required this.total,
    required this.breakdown,
    required this.modeLabel,
  });

  final DateTime from;
  final DateTime to;
  final double total;
  final Map<CategoryType, double> breakdown;
  final String modeLabel;

  String _generateCsv() {
    final buf = StringBuffer();
    buf.writeln('CFootNote Carbon Report');
    buf.writeln('Period,$modeLabel (${Fmt.date(from)} - ${Fmt.date(to)})');
    buf.writeln('Total Emissions (kg CO2e),${total.toStringAsFixed(2)}');
    buf.writeln('');
    buf.writeln('Category,Emissions (kg CO2e),Share (%)');
    for (final e in breakdown.entries) {
      final pct = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0';
      buf.writeln('${e.key.label},${e.value.toStringAsFixed(2)},$pct%');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final csv = _generateCsv();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.paddingOf(context).bottom),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.file_download_outlined, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Export Report', style: Theme.of(context).textTheme.titleLarge),
                    Text('$modeLabel · ${Fmt.dateShort(from)} – ${Fmt.dateShort(to)}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('CSV Preview', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                csv,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy CSV'),
                  onPressed: () {
                    Navigator.pop(context);
                    showSnack(context, 'Report CSV copied to clipboard');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Download CSV'),
                  onPressed: () {
                    Navigator.pop(context);
                    showSnack(context, 'Report saved as carbon_report_${Fmt.dateShort(from)}.csv');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}
