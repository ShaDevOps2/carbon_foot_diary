import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';

/// Full administrator audit trails (NFR-02, 2.3).
class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final logs = s.auditLogs;

    return Scaffold(
      appBar: AppBar(title: const Text('Administrative Audit Log')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: logs.isEmpty
              ? const EmptyState(
                  icon: Icons.history_edu_rounded,
                  title: 'No audit records',
                  message: 'Administrator actions will be recorded here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
              itemCount: logs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final log = logs[i];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppColors.forest.withValues(alpha: 0.15), shape: BoxShape.circle),
                            child: const Icon(Icons.security_rounded, size: 16, color: AppColors.forest),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(log.action, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                          Text(Fmt.ago(log.time),
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Target Record: ${log.record}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Prev: ${log.previous}',
                                style: const TextStyle(color: AppColors.coral, fontSize: 12, fontFamily: 'monospace')),
                          ),
                          const Icon(Icons.arrow_forward_rounded, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text('New: ${log.next}',
                                style: const TextStyle(color: AppColors.forest, fontSize: 12, fontFamily: 'monospace')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Admin ID: ${log.adminId} · Timestamp: ${Fmt.date(log.time)} ${Fmt.time(log.time)}',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
        ),
      ),
    );
  }
}
