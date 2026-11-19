import 'models.dart';

/// Pure calculation logic (FR-05): emission = activity data × emission factor.
abstract final class CarbonCalculator {
  /// Converts [quantity] in [unit] to the factor's base unit.
  static double toBaseUnit(double quantity, String unit) {
    switch (unit) {
      case 'mi':
        return quantity * 1.609344;
      case 'lb':
        return quantity * 0.45359237;
      case 'gal':
        return quantity * 3.785411784;
      case 'g':
        return quantity / 1000;
      case 'min':
        return quantity / 60;
      default:
        return quantity;
    }
  }

  /// Calculates kg CO₂e.
  static double calculate({
    required double quantity,
    required String unit,
    required double factor,
    int passengers = 1,
    bool roundTrip = false,
    double renewablePercent = 0,
  }) {
    if (quantity <= 0 || factor < 0) return 0;
    var result = toBaseUnit(quantity, unit) * factor;
    if (passengers > 1) result /= passengers;
    if (roundTrip) result *= 2;
    if (renewablePercent > 0) {
      result *= (1 - (renewablePercent.clamp(0, 100) / 100));
    }
    return result;
  }

  static GoalStatus goalStatus({
    required double actual,
    required double target,
    required DateTime start,
    required DateTime end,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    if (actual > target) return GoalStatus.aboveTarget;
    if (today.isAfter(end)) return GoalStatus.completed;
    final total = end.difference(start).inHours.clamp(1, 1 << 30);
    final elapsed = today.difference(start).inHours.clamp(1, total);
    final projected = actual / elapsed * total;
    if (projected > target * 0.9) return GoalStatus.atRisk;
    return GoalStatus.onTrack;
  }
}
