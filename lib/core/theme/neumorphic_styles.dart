import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NeumorphicStyles {
  // Reusable card design style (Convex / Protruding)
  static BoxDecoration convexDecoration({double radius = 24}) {
    return BoxDecoration(
      color: AppColors.neumorphicBackground,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: AppColors.lightShadow,
          offset: Offset(-10, -10),
          blurRadius: 20,
        ),
        BoxShadow(
          color: AppColors.darkShadow,
          offset: Offset(10, 10),
          blurRadius: 20,
        ),
      ],
    );
  }

  // Reusable clicked/pressed style (Concave / Inset effect natively)
  static BoxDecoration concaveDecoration({double radius = 24}) {
    return BoxDecoration(
      color: AppColors.neumorphicBackground,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [
        BoxShadow(
          color: AppColors.darkShadow,
          offset: Offset(-5, -5),
          blurRadius: 12,
        ),
        BoxShadow(
          color: AppColors.lightShadow,
          offset: Offset(5, 5),
          blurRadius: 12,
        ),
      ],
    );
  }
}
