import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neumorphic_styles.dart';

class TypingMissionWidget extends StatefulWidget {
  final String targetAffirmation;
  final VoidCallback onMissionComplete;

  const TypingMissionWidget({
    super.key,
    required this.targetAffirmation,
    required this.onMissionComplete,
  });

  @override
  State<TypingMissionWidget> createState() => _TypingMissionWidgetState();
}

class _TypingMissionWidgetState extends State<TypingMissionWidget> {
  final TextEditingController _textController = TextEditingController();
  bool isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_checkAccuracy);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    s1 = s1.toLowerCase().trim();
    s2 = s2.toLowerCase().trim();

    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i <= s2.length; i++) v0[i] = i;

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost]
            .reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j <= s2.length; j++) v0[j] = v1[j];
    }

    int distance = v1[s2.length];
    int maxLength = s1.length > s2.length ? s1.length : s2.length;
    return 1.0 - (distance / maxLength);
  }

  void _checkAccuracy() {
    double accuracy =
        _calculateSimilarity(_textController.text, widget.targetAffirmation);
    bool meetsThreshold = accuracy >= 0.50;

    if (isUnlocked != meetsThreshold) {
      setState(() {
        isUnlocked = meetsThreshold;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: NeumorphicStyles.convexDecoration(radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_document,
                      color: AppColors.accentOrange, size: 20),
                  const SizedBox(width: 8),
                  Text('TYPE TO UNLOCK',
                      style: AppTypography.interfaceLabel
                          .copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.targetAffirmation,
                style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 16,
                    color: AppColors.pureBlack,
                    fontWeight: FontWeight.w600,
                    height: 1.4),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _textController,
                style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 16,
                    color: AppColors.pureBlack),
                decoration: InputDecoration(
                  hintText: 'Type the affirmation here...',
                  hintStyle:
                      TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppColors.pureBlack.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // SOLID BLACK COMPLETION BUTTON
        GestureDetector(
          onTap: isUnlocked ? widget.onMissionComplete : null,
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
                isUnlocked ? 'COMPLETE MISSION' : 'LOCKED (Type 50% to unlock)',
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
