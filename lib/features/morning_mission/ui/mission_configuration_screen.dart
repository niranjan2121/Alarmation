import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/neumorphic_styles.dart';
import '../../../core/data/mock_database.dart';
import '../../../core/models/manifestation_template.dart';
import '../../manifestation/ui/template_selection_screen.dart';

class MissionConfigurationScreen extends StatefulWidget {
  final int initialSteps;
  final ManifestationTemplate? initialTemplate;

  const MissionConfigurationScreen({
    super.key,
    required this.initialSteps,
    this.initialTemplate,
  });

  @override
  State<MissionConfigurationScreen> createState() =>
      _MissionConfigurationScreenState();
}

class _MissionConfigurationScreenState
    extends State<MissionConfigurationScreen> {
  late int stepCount;
  late ManifestationTemplate selectedTemplate;

  @override
  void initState() {
    super.initState();
    stepCount = widget.initialSteps;
    selectedTemplate = widget.initialTemplate ?? MockDatabase.templates.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neumorphicBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.pureBlack, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Configure Mission',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureBlack,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'steps': stepCount,
                        'template': selectedTemplate,
                      });
                    },
                    child: Text(
                      'Done',
                      style: AppTypography.interfaceLabel.copyWith(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  Text('REQUIRED STEPS',
                      style: AppTypography.interfaceLabel
                          .copyWith(fontSize: 12, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: NeumorphicStyles.convexDecoration(radius: 20),
                    child: Column(
                      children: [
                        Text(
                          '$stepCount',
                          style:
                              AppTypography.alarmHeader.copyWith(fontSize: 48),
                        ),
                        Slider(
                          activeColor: AppColors.accentOrange,
                          inactiveColor: AppColors.darkShadow,
                          value: stepCount.toDouble(),
                          min: 10,
                          max: 100,
                          divisions: 9,
                          onChanged: (value) {
                            setState(() {
                              stepCount = value.toInt();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text('AFFIRMATION TEMPLATE',
                      style: AppTypography.interfaceLabel
                          .copyWith(fontSize: 12, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TemplateSelectionScreen(
                            currentTemplateId: selectedTemplate.id,
                          ),
                        ),
                      );

                      if (result != null && result is ManifestationTemplate) {
                        setState(() {
                          selectedTemplate = result;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: NeumorphicStyles.convexDecoration(radius: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedTemplate.category.toUpperCase(),
                                  style: AppTypography.interfaceLabel.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedTemplate.text,
                                  style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 14,
                                    color: AppColors.pureBlack,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: AppColors.textMuted, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
