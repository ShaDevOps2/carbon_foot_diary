import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';

/// App preferences, theme toggle, units, notification toggles and danger zone (FR-03, FR-15).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();

  void _changePassword() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _oldPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final s = AppScope.read(context);
              if (s.currentUser?.password != _oldPass.text) {
                showSnack(context, 'Current password incorrect');
                return;
              }
              if (Validators.strength(_newPass.text) < 3) {
                showSnack(context, 'Password is too weak');
                return;
              }
              s.currentUser?.password = _newPass.text;
              s.refresh();
              Navigator.pop(c);
              showSnack(context, 'Password changed successfully');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final user = s.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
          const SectionHeader('Display & Units'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  value: s.themeMode == ThemeMode.dark,
                  title: const Text('Dark mode'),
                  secondary: Icon(s.themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                  onChanged: (_) => s.toggleTheme(),
                ),
                const Divider(),
                SwitchListTile(
                  value: user.metric,
                  title: const Text('Metric units'),
                  subtitle: Text(user.metric ? 'Kilometres (km), Kilograms (kg)' : 'Miles (mi), Pounds (lb)'),
                  secondary: const Icon(Icons.straighten_rounded),
                  onChanged: (v) {
                    user.metric = v;
                    s.refresh();
                  },
                ),
              ],
            ),
          ),
          const SectionHeader('Notification Preferences'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  value: s.pushEnabled,
                  title: const Text('Push notifications'),
                  secondary: const Icon(Icons.notifications_active_outlined),
                  onChanged: (v) {
                    s.pushEnabled = v;
                    s.refresh();
                  },
                ),
                const Divider(),
                SwitchListTile(
                  value: s.emailEnabled,
                  title: const Text('Email summaries'),
                  secondary: const Icon(Icons.mail_outline_rounded),
                  onChanged: (v) {
                    s.emailEnabled = v;
                    s.refresh();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.alarm_rounded),
                  title: const Text('Daily reminder time'),
                  trailing: Text(
                    '${s.reminderTime.hour.toString().padLeft(2, '0')}:${s.reminderTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: s.reminderTime);
                    if (t != null) {
                      s.reminderTime = t;
                      s.refresh();
                    }
                  },
                ),
              ],
            ),
          ),
          const SectionHeader('Security & Account'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.password_rounded),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _changePassword,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: AppColors.coral),
                  title: const Text('Delete account', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Permanently erase personal data & entries'),
                  onTap: () async {
                    final ok = await confirmDialog(
                      context,
                      title: 'Delete your account?',
                      message: 'This will erase all your diary history, goals, and points permanently. This action cannot be undone.',
                      confirm: 'Delete Account',
                      destructive: true,
                    );
                    if (ok && context.mounted) {
                      s.deleteAccount();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('CFootNote v1.0.0 (Build 2026.11)\nForest & Mint Edition',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
          ),
        ],
      ),
    ),
  ),
);
  }
}
