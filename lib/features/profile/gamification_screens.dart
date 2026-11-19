import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../data/seed_data.dart';

/// Achievements and badges gallery (FR-13).
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final earned = s.earnedBadges;
    final all = SeedData.achievements;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements & Badges')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
          AppCard(
            gradient: AppColors.sunsetGradient,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Green Journey', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('${s.points} total points',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('${earned.length} of ${all.length} badges unlocked',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), shape: BoxShape.circle),
                  child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 48),
                ),
              ],
            ),
          ),
          const SectionHeader('Badges Gallery'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: all.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: MediaQuery.sizeOf(context).width > 600 ? 220 : 180,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent: 200,
            ),
            itemBuilder: (_, i) {
              final a = all[i];
              final isUnlocked = earned.contains(a.id);
              final badgeImagePath = 'assets/images/badges/${a.id}.png';

              return AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: ClipOval(
                        child: ColorFiltered(
                          colorFilter: isUnlocked
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                              : const ColorFilter.matrix(<double>[
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0,      0,      0,      0.65, 0,
                                ]),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                badgeImagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  decoration: BoxDecoration(
                                    gradient: isUnlocked ? a.gradient : null,
                                    color: isUnlocked ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  ),
                                  child: Icon(
                                    isUnlocked ? a.icon : Icons.lock_outline_rounded,
                                    color: isUnlocked ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                                    size: 32,
                                  ),
                                ),
                              ),
                              if (!isUnlocked)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  child: const Center(
                                    child: Icon(Icons.lock_rounded, color: Colors.white, size: 28),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      a.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          a.description,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 10.5,
                            height: 1.25,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatusPill(
                      label: isUnlocked ? '+${a.points} pts' : 'Locked',
                      color: isUnlocked ? AppColors.forest : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  ),
);
  }
}

/// Community and personal sustainability challenges (FR-14).
class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final challenges = s.challenges;

    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            itemCount: challenges.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final c = challenges[i];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                      decoration: BoxDecoration(gradient: c.gradient, borderRadius: BorderRadius.circular(16)),
                      child: Icon(c.icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title, style: Theme.of(context).textTheme.titleMedium),
                          Text('${c.days} days duration · Reward: ${c.reward}',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(c.description, style: const TextStyle(fontSize: 14, height: 1.4)),
                const SizedBox(height: 14),
                if (c.joined) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress: ${(c.progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      Text(c.requirement, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SoftProgressBar(value: c.progress, color: AppColors.forest, height: 8),
                ] else ...[
                  FilledButton.tonal(
                    onPressed: () {
                      c.joined = true;
                      c.progress = 0.1;
                      s.refresh();
                      showSnack(context, 'Joined ${c.title}!');
                    },
                    child: const Text('Join Challenge'),
                  ),
                ],
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
