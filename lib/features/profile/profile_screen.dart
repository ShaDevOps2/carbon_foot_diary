import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../data/seed_data.dart';
import '../feedback/feedback_screen.dart';
import '../learn/learn_screens.dart';
import 'edit_profile_screen.dart';
import 'gamification_screens.dart';
import 'legal_screen.dart';
import 'settings_screen.dart';

/// User profile and hub for achievements, challenges, learning, and settings (FR-03).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final user = s.currentUser;
    if (user == null) return const SizedBox.shrink();

    final earned = s.earnedBadges;
    final points = s.points;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
          AppCard(
            gradient: AppColors.heroGradient,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(user.initials,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: t.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(user.email, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text('${user.country} · ${user.metric ? "Metric" : "Imperial"}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit profile',
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: AppColors.amber, size: 24),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, size: 18),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('$points', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                      Text('Green points',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_rounded, color: AppColors.mint, size: 24),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, size: 18),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('${earned.length} / ${SeedData.achievements.length}',
                          style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                      Text('Badges earned',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SectionHeader('Activity & Challenges'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/badges/first_entry.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.military_tech_rounded, color: AppColors.amber),
                      ),
                    ),
                  ),
                  title: const Text('Achievements & Badges'),
                  subtitle: Text('${earned.length} badges unlocked'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/badges/traveller.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.directions_run_rounded, color: AppColors.sky),
                      ),
                    ),
                  ),
                  title: const Text('Active Challenges'),
                  subtitle: Text('${s.challenges.where((c) => c.joined).length} in progress'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen())),
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/activities/plant.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.school_rounded, color: AppColors.forest),
                      ),
                    ),
                  ),
                  title: const Text('Learn & Quizzes'),
                  subtitle: const Text('Carbon guides and quick quizzes'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearnScreen())),
                ),
              ],
            ),
          ),
          const SectionHeader('Support & Legal'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.feedback_outlined),
                  title: const Text('Send Feedback or Report Bug'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Terms of Use & Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.coral, side: const BorderSide(color: AppColors.coral)),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Log out'),
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: 'Log out of CFootNote?',
                message: 'You can log back in at any time with your email and password.',
                confirm: 'Log out',
                destructive: false,
              );
              if (ok) s.logout();
            },
          ),
        ],
      ),
    ),
  ),
);
  }
}
