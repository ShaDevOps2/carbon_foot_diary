import 'package:material_ui/material_ui.dart';

import '../core/theme/app_colors.dart';
import '../domain/models.dart';

/// Illustrative seed catalogue. Values are indicative estimates only and
/// should be replaced with a documented, region-appropriate dataset.
abstract final class SeedData {
  static const activities = <Activity>[
    // Transport (per km)
    Activity(id: 'car_petrol', category: CategoryType.transport, name: 'Petrol car', unit: 'km', icon: Icons.directions_car_rounded, hint: 'e.g. 20 km commute'),
    Activity(id: 'car_ev', category: CategoryType.transport, name: 'Electric vehicle', unit: 'km', icon: Icons.electric_car_rounded, hint: 'e.g. 15 km'),
    Activity(id: 'motorcycle', category: CategoryType.transport, name: 'Motorcycle', unit: 'km', icon: Icons.two_wheeler_rounded, hint: 'e.g. 10 km'),
    Activity(id: 'bus', category: CategoryType.transport, name: 'Bus', unit: 'km', icon: Icons.directions_bus_rounded, hint: 'e.g. 12 km'),
    Activity(id: 'train', category: CategoryType.transport, name: 'Train / LRT', unit: 'km', icon: Icons.train_rounded, hint: 'e.g. 18 km'),
    Activity(id: 'taxi', category: CategoryType.transport, name: 'Taxi / ride-share', unit: 'km', icon: Icons.local_taxi_rounded, hint: 'e.g. 8 km'),
    Activity(id: 'bicycle', category: CategoryType.transport, name: 'Bicycle', unit: 'km', icon: Icons.pedal_bike_rounded, hint: 'Zero tailpipe emissions'),
    Activity(id: 'walk', category: CategoryType.transport, name: 'Walking', unit: 'km', icon: Icons.directions_walk_rounded, hint: 'Zero tailpipe emissions'),
    Activity(id: 'flight_dom', category: CategoryType.transport, name: 'Domestic flight', unit: 'km', icon: Icons.flight_rounded, hint: 'e.g. KUL → PEN 330 km'),
    Activity(id: 'flight_int', category: CategoryType.transport, name: 'International flight', unit: 'km', icon: Icons.flight_takeoff_rounded, hint: 'e.g. KUL → SIN 300 km'),
    // Electricity
    Activity(id: 'grid_elec', category: CategoryType.electricity, name: 'Grid electricity', unit: 'kWh', icon: Icons.bolt_rounded, hint: 'Check your meter or bill'),
    Activity(id: 'aircon', category: CategoryType.electricity, name: 'Air-conditioning', unit: 'kWh', icon: Icons.ac_unit_rounded, hint: '1 h ≈ 1 kWh'),
    // Food (per serving)
    Activity(id: 'beef', category: CategoryType.food, name: 'Beef meal', unit: 'serving', icon: Icons.lunch_dining_rounded, hint: '1 serving ≈ 150 g'),
    Activity(id: 'lamb', category: CategoryType.food, name: 'Lamb meal', unit: 'serving', icon: Icons.kebab_dining_rounded, hint: '1 serving ≈ 150 g'),
    Activity(id: 'chicken', category: CategoryType.food, name: 'Chicken meal', unit: 'serving', icon: Icons.set_meal_rounded, hint: '1 serving ≈ 150 g'),
    Activity(id: 'fish', category: CategoryType.food, name: 'Fish meal', unit: 'serving', icon: Icons.phishing_rounded, hint: '1 serving ≈ 150 g'),
    Activity(id: 'rice', category: CategoryType.food, name: 'Rice', unit: 'serving', icon: Icons.rice_bowl_rounded, hint: '1 bowl'),
    Activity(id: 'plant', category: CategoryType.food, name: 'Plant-based meal', unit: 'serving', icon: Icons.eco_rounded, hint: '1 plate'),
    Activity(id: 'dairy', category: CategoryType.food, name: 'Dairy products', unit: 'serving', icon: Icons.local_drink_rounded, hint: '1 glass / 30 g cheese'),
    Activity(id: 'delivery', category: CategoryType.food, name: 'Food delivery', unit: 'order', icon: Icons.delivery_dining_rounded, hint: 'Packaging + transport'),
    Activity(id: 'food_waste', category: CategoryType.food, name: 'Food waste', unit: 'kg', icon: Icons.no_food_rounded, hint: 'Weight of food thrown away'),
    // Waste
    Activity(id: 'general_waste', category: CategoryType.waste, name: 'General waste', unit: 'kg', icon: Icons.delete_rounded, hint: '1 bag ≈ 5 kg'),
    Activity(id: 'plastic', category: CategoryType.waste, name: 'Plastic waste', unit: 'kg', icon: Icons.local_mall_rounded, hint: 'Bottles, bags, packaging'),
    Activity(id: 'ewaste', category: CategoryType.waste, name: 'Electronic waste', unit: 'kg', icon: Icons.devices_other_rounded, hint: 'Phones, cables, batteries'),
    Activity(id: 'recycled', category: CategoryType.waste, name: 'Recycled waste', unit: 'kg', icon: Icons.recycling_rounded, hint: 'Recorded separately'),
    // Water
    Activity(id: 'shower', category: CategoryType.water, name: 'Shower', unit: 'min', icon: Icons.shower_rounded, hint: 'Heated water'),
    Activity(id: 'laundry', category: CategoryType.water, name: 'Laundry load', unit: 'cycle', icon: Icons.local_laundry_service_rounded, hint: '1 load'),
    Activity(id: 'dishwasher', category: CategoryType.water, name: 'Dishwasher', unit: 'cycle', icon: Icons.kitchen_rounded, hint: '1 cycle'),
    // Shopping
    Activity(id: 'clothing', category: CategoryType.shopping, name: 'New clothing', unit: 'item', icon: Icons.checkroom_rounded, hint: 'e.g. 1 T-shirt'),
    Activity(id: 'electronics', category: CategoryType.shopping, name: 'Electronics', unit: 'item', icon: Icons.phone_iphone_rounded, hint: 'e.g. 1 phone'),
    Activity(id: 'online_order', category: CategoryType.shopping, name: 'Online order', unit: 'parcel', icon: Icons.local_shipping_rounded, hint: 'Delivery & packaging'),
    Activity(id: 'second_hand', category: CategoryType.shopping, name: 'Second-hand item', unit: 'item', icon: Icons.autorenew_rounded, hint: 'Much lower impact'),
    // Fuel
    Activity(id: 'lpg', category: CategoryType.fuel, name: 'LPG', unit: 'kg', icon: Icons.propane_tank_rounded, hint: '1 tank ≈ 14 kg'),
    Activity(id: 'natural_gas', category: CategoryType.fuel, name: 'Natural gas', unit: 'kWh', icon: Icons.gas_meter_rounded, hint: 'From gas bill'),
    Activity(id: 'firewood', category: CategoryType.fuel, name: 'Firewood', unit: 'kg', icon: Icons.forest_rounded, hint: 'Weight burned'),
    Activity(id: 'kerosene', category: CategoryType.fuel, name: 'Kerosene', unit: 'L', icon: Icons.oil_barrel_rounded, hint: 'Litres used'),
  ];

  static const _values = <String, double>{
    'car_petrol': 0.18, 'car_ev': 0.05, 'motorcycle': 0.11, 'bus': 0.10,
    'train': 0.035, 'taxi': 0.21, 'bicycle': 0, 'walk': 0,
    'flight_dom': 0.25, 'flight_int': 0.15,
    'grid_elec': 0.58, 'aircon': 0.58,
    'beef': 7.7, 'lamb': 5.8, 'chicken': 1.4, 'fish': 1.3, 'rice': 0.4,
    'plant': 0.5, 'dairy': 0.6, 'delivery': 0.9, 'food_waste': 2.5,
    'general_waste': 0.45, 'plastic': 0.6, 'ewaste': 1.0, 'recycled': 0.02,
    'shower': 0.09, 'laundry': 0.6, 'dishwasher': 0.7,
    'clothing': 8.0, 'electronics': 60.0, 'online_order': 0.7, 'second_hand': 0.8,
    'lpg': 2.94, 'natural_gas': 0.18, 'firewood': 0.02, 'kerosene': 2.54,
  };

  static List<EmissionFactor> factors() => [
        for (final a in activities)
          EmissionFactor(
            id: 'ef_${a.id}',
            activityId: a.id,
            value: _values[a.id] ?? 0,
            unit: 'kg CO₂e / ${a.unit}',
            region: a.id == 'grid_elec' || a.id == 'aircon' ? 'Malaysia' : 'Global',
            source: a.category == CategoryType.food
                ? 'Poore & Nemecek (2018), Our World in Data'
                : a.id == 'grid_elec' || a.id == 'aircon'
                    ? 'Grid factor (illustrative), Energy Commission MY'
                    : 'DESNZ/DEFRA GHG Conversion Factors 2025',
          ),
      ];

  static const achievements = <Achievement>[
    Achievement(id: 'first', name: 'First Entry', description: 'Logged your very first activity', points: 10, icon: Icons.edit_note_rounded, gradient: AppColors.mintGradient),
    Achievement(id: 'streak7', name: '7-Day Streak', description: 'Logged activities 7 days in a row', points: 50, icon: Icons.local_fire_department_rounded, gradient: AppColors.sunsetGradient),
    Achievement(id: 'traveller', name: 'Low-Carbon Traveller', description: '5 trips by bike, foot or train', points: 40, icon: Icons.pedal_bike_rounded, gradient: AppColors.oceanGradient),
    Achievement(id: 'energy', name: 'Energy Saver', description: 'Cut electricity 10% week-on-week', points: 40, icon: Icons.bolt_rounded, gradient: AppColors.sunsetGradient),
    Achievement(id: 'waste', name: 'Waste Reducer', description: 'Recycled 5 times in a month', points: 40, icon: Icons.recycling_rounded, gradient: AppColors.violetGradient),
    Achievement(id: 'goal', name: 'Goal Achiever', description: 'Completed a reduction goal', points: 60, icon: Icons.emoji_events_rounded, gradient: AppColors.heroGradient),
  ];

  static List<Challenge> challenges() => [
        Challenge(id: 'c1', title: 'Car-Free Week', description: 'Swap car trips for walking, cycling or public transport for 7 days.', requirement: 'No petrol-car entries for 7 days', days: 7, reward: 'Low-Carbon Traveller', icon: Icons.no_crash_rounded, gradient: AppColors.oceanGradient, joined: true, progress: 0.57),
        Challenge(id: 'c2', title: 'Meat-Free Days', description: 'Enjoy plant-based meals for 3 days this week.', requirement: '3 days with no beef or lamb', days: 7, reward: '+60 pts', icon: Icons.eco_rounded, gradient: AppColors.mintGradient, joined: true, progress: 0.33),
        Challenge(id: 'c3', title: 'Power Down', description: 'Reduce household electricity by 15% compared to last week.', requirement: '-15% kWh vs last week', days: 7, reward: 'Energy Saver', icon: Icons.power_settings_new_rounded, gradient: AppColors.sunsetGradient),
        Challenge(id: 'c4', title: 'Zero Food Waste', description: 'Plan meals and avoid throwing away food for 5 days.', requirement: 'No food-waste entries for 5 days', days: 5, reward: 'Waste Reducer', icon: Icons.no_food_rounded, gradient: AppColors.violetGradient),
        Challenge(id: 'c5', title: 'Reusable Hero', description: 'Use reusable bags, bottles and containers every day.', requirement: 'Log 0 plastic waste for 7 days', days: 7, reward: '+50 pts', icon: Icons.shopping_basket_rounded, gradient: AppColors.heroGradient),
      ];

  static const tips = <Tip>[
    Tip(title: 'What is a carbon footprint?', body: 'Your carbon footprint is the total greenhouse gases caused by your activities, expressed as kilograms of CO₂ equivalent (kg CO₂e). It combines CO₂, methane and other gases into one comparable number.\n\nCFootNote estimates your footprint by multiplying what you did (for example kilometres driven) by an emission factor from a published dataset. These are estimates — not exact measurements — but they are great for spotting patterns and progress.', category: CategoryType.custom, minutes: 3, icon: Icons.public_rounded),
    Tip(title: 'Ride smarter, not harder', body: 'Transport is often the largest slice of a personal footprint. Combining errands into one trip, car-pooling, and using LRT, MRT or buses for regular commutes can cut transport emissions significantly.\n\nFor short trips under 3 km, walking or cycling is often just as fast once parking is considered.', category: CategoryType.transport, minutes: 2, icon: Icons.directions_bus_rounded),
    Tip(title: 'Cool your home efficiently', body: 'Setting air-conditioning to 24–25 °C instead of 20 °C can reduce its energy use noticeably. Use fans to circulate air, close curtains during the hottest hours, and clean filters monthly.\n\nWhen replacing appliances, look for higher energy-efficiency star ratings.', category: CategoryType.electricity, minutes: 2, icon: Icons.ac_unit_rounded),
    Tip(title: 'Eat more plants, waste less', body: 'Beef and lamb have much higher emissions per serving than chicken, fish or plant-based meals. You don\'t need to go fully vegetarian — swapping a few meals each week helps.\n\nPlanning meals and storing leftovers properly also reduces food waste, which produces methane in landfills.', category: CategoryType.food, minutes: 3, icon: Icons.eco_rounded),
    Tip(title: 'Recycling right', body: 'Rinse containers, keep paper dry, and separate plastics, glass and metal according to your local council guidelines. Contaminated recycling often ends up in landfill.\n\nRemember: reducing and reusing comes before recycling.', category: CategoryType.waste, minutes: 2, icon: Icons.recycling_rounded),
    Tip(title: 'Shorter, cooler showers', body: 'Heating water uses energy. Cutting a shower from 10 to 5 minutes and running full laundry loads at lower temperatures saves both water and emissions.', category: CategoryType.water, minutes: 1, icon: Icons.shower_rounded),
    Tip(title: 'Buy less, choose well', body: 'Manufacturing new products — especially electronics and fast fashion — carries a large hidden footprint. Repairing, buying second-hand, and choosing durable items keeps that footprint low.', category: CategoryType.shopping, minutes: 2, icon: Icons.shopping_bag_rounded),
  ];

  static const quiz = <QuizQuestion>[
    QuizQuestion('Which meal usually has the highest emissions per serving?', ['Chicken', 'Beef', 'Lentils', 'Rice'], 1, 'Beef typically produces several times more emissions per serving than chicken or plant proteins.'),
    QuizQuestion('What does "CO₂e" stand for?', ['Carbon dioxide equivalent', 'Carbon emission estimate', 'CO₂ energy', 'Carbon output exchange'], 0, 'CO₂e expresses different greenhouse gases as an equivalent amount of CO₂.'),
    QuizQuestion('Which is generally the lowest-carbon way to travel 2 km?', ['Taxi', 'Motorcycle', 'Walking', 'Bus'], 2, 'Walking and cycling have essentially zero direct emissions.'),
    QuizQuestion('Setting your air-con from 20 °C to 25 °C will…', ['Increase energy use', 'Make no difference', 'Reduce energy use', 'Damage the unit'], 2, 'Each degree warmer reduces the cooling load and energy use.'),
    QuizQuestion('Why does food waste in landfill matter?', ['It produces methane', 'It is heavy', 'It attracts birds', 'It doesn\'t matter'], 0, 'Decomposing food without oxygen releases methane, a potent greenhouse gas.'),
  ];
}
