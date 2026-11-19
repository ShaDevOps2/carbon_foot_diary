import 'package:material_ui/material_ui.dart';

import '../core/theme/app_colors.dart';

/// Emission categories supported by CFootNote.
enum CategoryType {
  transport('Transport', Icons.directions_car_filled_rounded, AppColors.transport,
      'Car, bus, train, flights and more', 'assets/images/categories/transport.png'),
  electricity('Electricity', Icons.bolt_rounded, AppColors.electricity,
      'Household electricity in kWh', 'assets/images/categories/electricity.png'),
  food('Food & Diet', Icons.restaurant_rounded, AppColors.food,
      'Meals, servings and food waste', 'assets/images/categories/food.png'),
  waste('Waste', Icons.delete_outline_rounded, AppColors.waste,
      'General, plastic, recycled and more', 'assets/images/categories/waste.png'),
  water('Water', Icons.water_drop_rounded, AppColors.water,
      'Showers, laundry and dishwashing', 'assets/images/categories/water.png'),
  shopping('Shopping', Icons.shopping_bag_rounded, AppColors.shopping,
      'Clothing, electronics, deliveries', 'assets/images/categories/shopping.png'),
  fuel('Cooking Fuel', Icons.local_fire_department_rounded, AppColors.fuel,
      'LPG, natural gas, firewood', 'assets/images/categories/fuel.png'),
  custom('Custom', Icons.tune_rounded, AppColors.custom,
      'Your own activity and factor', 'assets/images/categories/custom.png');

  const CategoryType(this.label, this.icon, this.color, this.description, this.imagePath);
  final String label;
  final IconData icon;
  final Color color;
  final String description;
  final String imagePath;
}

enum UserRole { user, admin }

enum AccountStatus { active, suspended, pendingDeletion }

enum GoalPeriod { daily, weekly, monthly }

enum GoalStatus {
  onTrack('On track', AppColors.success, Icons.check_circle_rounded),
  atRisk('At risk', AppColors.amber, Icons.warning_amber_rounded),
  aboveTarget('Above target', AppColors.coral, Icons.trending_up_rounded),
  completed('Completed', AppColors.forest, Icons.emoji_events_rounded);

  const GoalStatus(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.country = 'Malaysia',
    this.metric = true,
    this.role = UserRole.user,
    this.status = AccountStatus.active,
    DateTime? createdAt,
    this.householdSize = 3,
    this.residence = 'Apartment / Condominium',
    this.vehicle = 'Petrol car',
    this.diet = 'Mixed diet',
    this.workMode = 'Hybrid (part remote)',
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  String name;
  String email;
  String password; // Demo only — a real backend stores a bcrypt/Argon2id hash.
  String country;
  bool metric;
  UserRole role;
  AccountStatus status;
  final DateTime createdAt;
  int householdSize;
  String residence;
  String vehicle;
  String diet;
  String workMode;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }
}

class Activity {
  const Activity({
    required this.id,
    required this.category,
    required this.name,
    required this.unit,
    required this.icon,
    this.hint = '',
  });

  final String id;
  final CategoryType category;
  final String name;
  final String unit;
  final IconData icon;
  final String hint;
}

class EmissionFactor {
  EmissionFactor({
    required this.id,
    required this.activityId,
    required this.value,
    required this.unit,
    this.region = 'Global',
    this.source = 'DESNZ/DEFRA GHG Conversion Factors 2025',
    this.year = 2025,
    this.version = 1,
    DateTime? effectiveDate,
    this.active = true,
    DateTime? updatedAt,
  })  : effectiveDate = effectiveDate ?? DateTime(2025, 1, 1),
        updatedAt = updatedAt ?? DateTime(2025, 6, 1);

  final String id;
  final String activityId;
  double value;
  final String unit;
  String region;
  String source;
  int year;
  int version;
  DateTime effectiveDate;
  bool active;
  DateTime updatedAt;
}

class DiaryEntry {
  DiaryEntry({
    required this.id,
    required this.userId,
    required this.activityId,
    required this.category,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.factorId,
    required this.factorValue,
    required this.factorVersion,
    required this.emission,
    required this.date,
    this.notes = '',
    this.isUserFactor = false,
    this.avoided = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String userId;
  String activityId;
  CategoryType category;
  String description;
  double quantity;
  String unit;
  String factorId;
  double factorValue;
  int factorVersion;
  double emission;
  double avoided;
  DateTime date;
  String notes;
  bool isUserFactor;
  final DateTime createdAt;
  DateTime updatedAt;
}

class Goal {
  Goal({
    required this.id,
    required this.name,
    required this.period,
    required this.baseline,
    required this.target,
    required this.start,
    required this.end,
    this.category,
  });

  final String id;
  String name;
  GoalPeriod period;
  CategoryType? category;
  double baseline;
  double target;
  DateTime start;
  DateTime end;
}

class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.icon,
    required this.gradient,
  });

  final String id;
  final String name;
  final String description;
  final int points;
  final IconData icon;
  final Gradient gradient;
}

class Challenge {
  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.requirement,
    required this.days,
    required this.reward,
    required this.icon,
    required this.gradient,
    this.joined = false,
    this.progress = 0,
  });

  final String id;
  final String title;
  final String description;
  final String requirement;
  final int days;
  final String reward;
  final IconData icon;
  final Gradient gradient;
  bool joined;
  double progress;
}

class AppNotification {
  AppNotification({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.time,
    this.read = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime time;
  bool read;
}

class FeedbackItem {
  FeedbackItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.subject,
    required this.description,
    DateTime? createdAt,
    this.status = 'Open',
    this.response = '',
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String? userId;
  final String type;
  final String subject;
  final String description;
  final DateTime createdAt;
  String status;
  String response;
}

class AuditLog {
  AuditLog({
    required this.adminId,
    required this.action,
    required this.record,
    required this.previous,
    required this.next,
    DateTime? time,
  }) : time = time ?? DateTime.now();

  final String adminId;
  final String action;
  final String record;
  final String previous;
  final String next;
  final DateTime time;
}

class Tip {
  const Tip({
    required this.title,
    required this.body,
    required this.category,
    required this.minutes,
    required this.icon,
  });

  final String title;
  final String body;
  final CategoryType category;
  final int minutes;
  final IconData icon;
}

class Recommendation {
  const Recommendation({
    required this.title,
    required this.body,
    required this.category,
    required this.impact,
  });

  final String title;
  final String body;
  final CategoryType category;
  final String impact;
}

class QuizQuestion {
  const QuizQuestion(this.question, this.options, this.answer, this.explain);
  final String question;
  final List<String> options;
  final int answer;
  final String explain;
}
