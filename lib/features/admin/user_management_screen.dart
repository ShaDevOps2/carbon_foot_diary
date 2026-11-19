import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../domain/models.dart';

/// Admin user accounts management and status review (FR-17).
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final q = _search.text.trim().toLowerCase();
    final users = s.users.where((u) {
      if (q.isEmpty) return true;
      return u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final u = users[i];
                final isSuspended = u.status == AccountStatus.suspended;

                return AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(u.initials, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                if (u.role == UserRole.admin) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.forest, borderRadius: BorderRadius.circular(6)),
                                    child: const Text('ADMIN', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(u.email, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('Joined ${Fmt.date(u.createdAt)} · ${u.country}',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Actions',
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (val) {
                          if (val == 'toggle_status') {
                            s.setUserStatus(u, isSuspended ? AccountStatus.active : AccountStatus.suspended);
                          } else if (val == 'toggle_role') {
                            s.setUserRole(u, u.role == UserRole.admin ? UserRole.user : UserRole.admin);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'toggle_status',
                            child: Text(isSuspended ? 'Activate Account' : 'Suspend Account'),
                          ),
                          PopupMenuItem(
                            value: 'toggle_role',
                            child: Text(u.role == UserRole.admin ? 'Demote to User' : 'Promote to Admin'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
