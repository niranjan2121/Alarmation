import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/neumorphic_styles.dart';
import '../../../core/data/mock_database.dart';


class TemplateSelectionScreen extends StatelessWidget {
  final String currentTemplateId;

  const TemplateSelectionScreen({
    super.key,
    required this.currentTemplateId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neumorphicBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.pureBlack, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Select Affirmation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pureBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balances the back button
                ],
              ),
            ),

            // List of Templates
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: MockDatabase.templates.length,
                itemBuilder: (context, index) {
                  final template = MockDatabase.templates[index];
                  final isSelected = template.id == currentTemplateId;

                  return GestureDetector(
                    onTap: () {
                      // Returns the selected template back to the previous screen immediately
                      Navigator.pop(context, template);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: isSelected
                          ? NeumorphicStyles.concaveDecoration(radius: 16)
                          : NeumorphicStyles.convexDecoration(radius: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      template.category.toUpperCase(),
                                      style:
                                          AppTypography.interfaceLabel.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.accentOrange
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                    if (template.isPremium) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: AppColors.pureBlack,
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: const Text('PRO',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  template.text,
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 14,
                                    color: isSelected
                                        ? AppColors.pureBlack
                                        : AppColors.textMuted,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: AppColors.accentOrange),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
