import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class AffirmationLibraryScreen extends StatelessWidget {
  const AffirmationLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neumorphicBackground,
      body: SafeArea(
        child: Center(
          child: Text(
            'Manifestation Library\n(Coming Next)',
            textAlign: TextAlign.center,
            style: AppTypography.interfaceLabel.copyWith(
              fontSize: 20,
              color: AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
