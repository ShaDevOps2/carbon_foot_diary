import 'package:material_ui/material_ui.dart';

import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';

/// In-app notification centre (FR-15).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final notifications = s.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.any((n) => !n.read))
            TextButton(
              onPressed: () {
                for (final n in notifications) {
                  n.read = true;
                }
                s.refresh();
              },
              child: const Text('Mark all read'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: notifications.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No notifications',
                  message: 'Reminders and updates will appear here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final n = notifications[i];
                return AppCard(
                  color: n.read ? null : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  onTap: () {
                    n.read = true;
                    s.refresh();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: n.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(n.icon, color: n.color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(n.title,
                                      style: TextStyle(
                                          fontWeight: n.read ? FontWeight.w600 : FontWeight.w800,
                                          fontSize: 15)),
                                ),
                                if (!n.read)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(left: 6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(n.message, style: const TextStyle(fontSize: 13, height: 1.4)),
                            const SizedBox(height: 8),
                            Text(Fmt.ago(n.time),
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                          ],
                        ),
                      ),
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
