import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neumorphic_styles.dart';

class VoiceMissionWidget extends StatelessWidget {
  final String targetAffirmation;
  final bool isUnlocked;
  final VoidCallback onMissionComplete;

  const VoiceMissionWidget({
    super.key,
    required this.targetAffirmation,
    this.isUnlocked = false,
    required this.onMissionComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: NeumorphicStyles.convexDecoration(radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic,
                      color: AppColors.accentOrange, size: 20),
                  const SizedBox(width: 8),
                  Text('SPEAK TO UNLOCK',
                      style: AppTypography.interfaceLabel
                          .copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                targetAffirmation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 16,
                    color: AppColors.pureBlack,
                    fontWeight: FontWeight.w600,
                    height: 1.4),
              ),
              const SizedBox(height: 32),
              Container(
                width: 80,
                height: 80,
                decoration: NeumorphicStyles.convexDecoration(radius: 40),
                child: const Center(
                  child: Icon(Icons.mic_none,
                      color: AppColors.pureBlack, size: 32),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tap to start listening...',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      color: AppColors.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // SOLID BLACK COMPLETION BUTTON
        GestureDetector(
          onTap: isUnlocked ? onMissionComplete : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: isUnlocked
                ? BoxDecoration(
                    color: AppColors.pureBlack,
                    borderRadius: BorderRadius.circular(20),
                  )
                : NeumorphicStyles.concaveDecoration(radius: 20),
            child: Center(
              child: Text(
                isUnlocked ? 'COMPLETE MISSION' : 'LOCKED (Speak to unlock)',
                style: AppTypography.interfaceLabel.copyWith(
                  color: isUnlocked ? Colors.white : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
