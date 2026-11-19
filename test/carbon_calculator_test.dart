import 'package:carbon_foot_diary/domain/carbon_calculator.dart';
import 'package:carbon_foot_diary/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarbonCalculator calculations', () {
    test('standard formula matches specification example (20 km petrol car)', () {
      // If a petrol car has an emission factor of 0.18 kg CO2e per km:
      // 20 * 0.18 = 3.6 kg CO2e
      final emission = CarbonCalculator.calculate(
        quantity: 20,
        unit: 'km',
        factor: 0.18,
      );
      expect(emission, closeTo(3.6, 0.001));
    });

    test('splits emissions by number of carpool passengers', () {
      final emission = CarbonCalculator.calculate(
        quantity: 20,
        unit: 'km',
        factor: 0.18,
        passengers: 2,
      );
      expect(emission, closeTo(1.8, 0.001));
    });

    test('doubles distance for round trips', () {
      final emission = CarbonCalculator.calculate(
        quantity: 100,
        unit: 'km',
        factor: 0.25,
        roundTrip: true,
      );
      expect(emission, closeTo(50.0, 0.001));
    });

    test('applies renewable energy percentage deduction', () {
      // 100 kWh @ 0.58 kg/kWh with 50% renewable -> 100 * 0.58 * 0.5 = 29.0
      final emission = CarbonCalculator.calculate(
        quantity: 100,
        unit: 'kWh',
        factor: 0.58,
        renewablePercent: 50,
      );
      expect(emission, closeTo(29.0, 0.001));
    });

    test('unit conversion: miles to km', () {
      // 10 mi * 1.609344 = 16.09344 km
      final base = CarbonCalculator.toBaseUnit(10, 'mi');
      expect(base, closeTo(16.093, 0.01));
    });
  });

  group('Goal status evaluation', () {
    test('returns completed when period ended and under target', () {
      final status = CarbonCalculator.goalStatus(
        actual: 45,
        target: 50,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 7),
        now: DateTime(2026, 1, 8),
      );
      expect(status, GoalStatus.completed);
    });

    test('returns aboveTarget when actual exceeds target', () {
      final status = CarbonCalculator.goalStatus(
        actual: 55,
        target: 50,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 7),
        now: DateTime(2026, 1, 4),
      );
      expect(status, GoalStatus.aboveTarget);
    });
  });
}
