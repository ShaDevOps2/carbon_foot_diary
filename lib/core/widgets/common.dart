import 'package:material_ui/material_ui.dart';

import '../../domain/models.dart';
import '../theme/app_colors.dart';
import '../utils/format.dart';

/// Rounded card with optional gradient background.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
    this.color,
    this.onTap,
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? color;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (color ?? scheme.surfaceContainerLowest) : null,
        borderRadius: BorderRadius.circular(radius),
        border: gradient == null && color == null
            ? Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7))
            : null,
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: (gradient != null ? AppColors.forest : Colors.black).withValues(alpha: gradient != null ? 0.22 : 0.04),
                  blurRadius: gradient != null ? 24 : 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}

/// Circular tinted icon or realistic photographic thumbnail representing a category or activity.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar(this.category, {super.key, this.size = 48, this.icon, this.imagePath});
  final CategoryType category;
  final double size;
  final IconData? icon;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final effectiveImage = imagePath ?? category.imagePath;
    if (effectiveImage.isNotEmpty) {
      return Semantics(
        label: category.label,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.34),
            child: Image.asset(
              effectiveImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fallback(),
            ),
          ),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Semantics(
      label: category.label,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(size * 0.34),
        ),
        child: Icon(icon ?? category.icon, color: category.color, size: size * 0.5),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Trend chip: lower emissions = good (green), higher = coral.
class TrendChip extends StatelessWidget {
  const TrendChip({super.key, required this.now, required this.prev, this.onDark = false});
  final double now;
  final double prev;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final up = now > prev;
    final color = onDark ? Colors.white : (up ? AppColors.coral : AppColors.success);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withValues(alpha: 0.18) : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 13, color: color),
          const SizedBox(width: 2),
          Text(Fmt.pctChange(now, prev), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.imagePath,
    required this.color,
    this.prev,
    this.now,
    this.unit = 'kg CO₂e',
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? imagePath;
  final Color color;
  final double? now;
  final double? prev;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (imagePath != null)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                        child: Icon(icon ?? Icons.analytics_rounded, size: 18, color: color),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon ?? Icons.analytics_rounded, size: 18, color: color),
                ),
              const Spacer(),
              if (now != null && prev != null) TrendChip(now: now!, prev: prev!),
            ],
          ),
          const SizedBox(height: 14),
          Text(value, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          Text(unit, style: t.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(label, style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class EntryTile extends StatelessWidget {
  const EntryTile({super.key, required this.entry, this.onTap, this.showDate = true});
  final DiaryEntry entry;
  final VoidCallback? onTap;
  final bool showDate;

  String? get _imageForActivity {
    switch (entry.activityId) {
      case 'bus':
        return 'assets/images/activities/bus.png';
      case 'car_petrol':
      case 'car_ev':
      case 'taxi':
        return 'assets/images/activities/car.png';
      case 'train':
        return 'assets/images/activities/train.png';
      case 'bicycle':
        return 'assets/images/activities/bike.png';
      case 'walk':
        return 'assets/images/activities/walking.png';
      case 'flight_dom':
      case 'flight_int':
        return 'assets/images/activities/flight.png';
      case 'grid_elec':
        return 'assets/images/activities/electricity.png';
      case 'aircon':
        return 'assets/images/activities/aircon.png';
      case 'beef':
      case 'lamb':
        return 'assets/images/activities/beef.png';
      case 'chicken':
      case 'fish':
        return 'assets/images/activities/chicken.png';
      case 'plant':
      case 'rice':
        return 'assets/images/activities/plant.png';
      case 'food_waste':
        return 'assets/images/activities/food_waste.png';
      case 'plastic':
        return 'assets/images/activities/plastic.png';
      case 'recycled':
        return 'assets/images/activities/recycled.png';
      case 'shower':
        return 'assets/images/activities/water.png';
      case 'clothing':
      case 'online_order':
      case 'shopping':
        return 'assets/images/activities/shopping.png';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(14),
      radius: 20,
      onTap: onTap,
      child: Row(
        children: [
          Hero(
            tag: 'entry-${entry.id}',
            child: CategoryAvatar(
              entry.category,
              imagePath: _imageForActivity,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.description, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${Fmt.num(entry.quantity)} ${entry.unit}${showDate ? ' · ${Fmt.relativeDay(entry.date)}' : ''}',
                  style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Fmt.kg(entry.emission), style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              Text('kg CO₂e', style: t.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action, this.onAction});
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
            if (action != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(onPressed: onAction, child: Text(action!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Animated number that counts up when its value changes.
class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber(this.value, {super.key, this.style, this.decimals = 1});
  final double value;
  final TextStyle? style;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text(v.toStringAsFixed(decimals), style: style),
    );
  }
}

/// Fade + slide-in for list items.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirm = 'Delete',
  bool destructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      icon: Icon(destructive ? Icons.delete_forever_rounded : Icons.help_outline_rounded,
          color: destructive ? AppColors.coral : AppColors.forest, size: 32),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: AppColors.coral, minimumSize: const Size(100, 44)) : FilledButton.styleFrom(minimumSize: const Size(100, 44)),
          onPressed: () => Navigator.pop(c, true),
          child: Text(confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showSnack(BuildContext context, String message, {IconData icon = Icons.check_circle_rounded}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Row(children: [Icon(icon, color: AppColors.mint), const SizedBox(width: 12), Expanded(child: Text(message))]),
    ));
}

/// Small disclaimer reminding users that values are estimates.
class EstimateNote extends StatelessWidget {
  const EstimateNote({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Values are estimates based on published emission factors, not exact measurements.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
