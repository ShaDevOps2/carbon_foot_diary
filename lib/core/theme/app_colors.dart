import 'package:material_ui/material_ui.dart';

/// CFootNote "Forest & Mint" design tokens.
abstract final class AppColors {
  // Brand
  static const forest = Color(0xFF1E6B4E);
  static const forestDeep = Color(0xFF0F3D2C);
  static const mint = Color(0xFF3DDC97);
  static const mintSoft = Color(0xFFCFF5E3);
  static const sky = Color(0xFF4FA3F7);
  static const sand = Color(0xFFF7F6F1);
  static const ink = Color(0xFF14201A);
  static const inkSoft = Color(0xFF5C6B64);

  // Semantic
  static const amber = Color(0xFFFFB547);
  static const coral = Color(0xFFF0605D);
  static const success = Color(0xFF2BB673);

  // Dark surfaces
  static const darkBg = Color(0xFF0B120F);
  static const darkCard = Color(0xFF15201B);

  // Category accents
  static const transport = Color(0xFF4FA3F7);
  static const electricity = Color(0xFFFFB547);
  static const food = Color(0xFFF28C5B);
  static const waste = Color(0xFF8D7BF0);
  static const water = Color(0xFF3EC6E0);
  static const shopping = Color(0xFFE66FA8);
  static const fuel = Color(0xFFC9785A);
  static const custom = Color(0xFF7A8C84);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F3D2C), Color(0xFF1E6B4E), Color(0xFF2FA878)],
  );

  static const mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3DDC97), Color(0xFF1E9E6E)],
  );

  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC46B), Color(0xFFF28C5B)],
  );

  static const oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6FC3FF), Color(0xFF3A7BD5)],
  );

  static const violetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB39DFF), Color(0xFF7B61E8)],
  );
}
