import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/common.dart';
import '../../data/app_state.dart';
import '../../domain/models.dart';
import '../diary/add_entry_screens.dart';

/// Personalized recommendations page (FR-11).
class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final recs = s.recommendations;

    return Scaffold(
      appBar: AppBar(title: const Text('Recommendations')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              AppCard(
                gradient: AppColors.heroGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.mint, size: 32),
                    const SizedBox(height: 12),
                    Text('Personalized tips', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('These suggestions adapt as you log more diary entries, highlighting the highest-impact opportunities for you.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              for (final (i, rec) in recs.indexed) ...[
                FadeSlideIn(
                  index: i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RecommendationCard(rec: rec),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const EstimateNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key, required this.rec, this.compact = false});
  final Recommendation rec;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final isHigh = rec.impact.contains('High');
    final impactColor = isHigh ? AppColors.coral : AppColors.forest;

    if (compact) {
      return AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryAvatar(rec.category, size: 36),
                const Spacer(),
                StatusPill(label: rec.impact, color: impactColor),
              ],
            ),
            const SizedBox(height: 10),
            Text(rec.title, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(rec.body,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryAvatar(rec.category, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec.category.label,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text(rec.title, style: t.titleMedium),
                  ],
                ),
              ),
              StatusPill(label: rec.impact, color: impactColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(rec.body, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Log alternative'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ActivityFormScreen(category: rec.category)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
