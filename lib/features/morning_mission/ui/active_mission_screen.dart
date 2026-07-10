import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/neumorphic_styles.dart';
import 'widgets/typing_mission_widget.dart';
import 'widgets/voice_mission_widget.dart';

class ActiveMissionScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const ActiveMissionScreen({super.key, required this.alarmSettings});

  @override
  State<ActiveMissionScreen> createState() => _ActiveMissionScreenState();
}

class _ActiveMissionScreenState extends State<ActiveMissionScreen> {
  bool isMissionActive = false;
  bool isPenaltyRinging = false;
  bool isSuccessScreen = false; // Added for the "Yay!" animation

  Timer? _systemTimer;
  DateTime? _targetEndTime;
  int remainingSeconds = 240;

  bool isTypingMode = true;
  int currentSteps = 0;
  int targetSteps = 30;
  final String targetAffirmation =
      "I am awake, focused, and ready to conquer my day.";

  @override
  void initState() {
    super.initState();
    _startInitialRingingTimeout();
  }

  @override
  void dispose() {
    _systemTimer?.cancel();
    super.dispose();
  }

  void _startInitialRingingTimeout() {
    _targetEndTime = DateTime.now().add(const Duration(minutes: 4));
    _systemTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _targetEndTime == null) return;
      final remaining = _targetEndTime!.difference(DateTime.now()).inSeconds;
      setState(() {
        if (remaining <= 0) {
          timer.cancel();
          _autoKillAlarmPermanently();
        } else {
          remainingSeconds = remaining;
        }
      });
    });
  }

  Future<void> _startMission() async {
    _systemTimer?.cancel();
    setState(() {
      isMissionActive = true;
      isPenaltyRinging = false;
    });

    // Enforce strict silence during the mission
    await Alarm.stop(widget.alarmSettings.id);

    _targetEndTime = DateTime.now().add(const Duration(minutes: 5));
    _systemTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _targetEndTime == null) return;
      final remaining = _targetEndTime!.difference(DateTime.now()).inSeconds;
      setState(() {
        if (remaining <= 0) {
          timer.cancel();
          _triggerFinalPenaltyRing();
        } else {
          remainingSeconds = remaining;
        }
      });
    });
  }

  Future<void> _triggerFinalPenaltyRing() async {
    _systemTimer?.cancel();
    setState(() {
      isMissionActive = false;
      isPenaltyRinging = true;
    });

    final penaltySettings = AlarmSettings(
      id: widget.alarmSettings.id,
      dateTime: DateTime.now(),
      assetAudioPath: widget.alarmSettings.assetAudioPath,
      loopAudio: widget.alarmSettings.loopAudio,
      vibrate: widget.alarmSettings.vibrate,
      volumeSettings: widget.alarmSettings.volumeSettings,
      notificationSettings: widget.alarmSettings.notificationSettings,
      androidFullScreenIntent: widget.alarmSettings.androidFullScreenIntent,
    );
    await Alarm.set(alarmSettings: penaltySettings);

    _targetEndTime = DateTime.now().add(const Duration(minutes: 4));
    _systemTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _targetEndTime == null) return;
      final remaining = _targetEndTime!.difference(DateTime.now()).inSeconds;
      setState(() {
        if (remaining <= 0) {
          timer.cancel();
          _autoKillAlarmPermanently();
        } else {
          remainingSeconds = remaining;
        }
      });
    });
  }

  Future<void> _autoKillAlarmPermanently() async {
    _systemTimer?.cancel();
    await Alarm.stop(widget.alarmSettings.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _completeMission() async {
    if (currentSteps < targetSteps) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete your required steps first!'),
            backgroundColor: AppColors.pureBlack),
      );
      return;
    }

    _systemTimer?.cancel();
    await Alarm.stop(widget.alarmSettings.id);

    // Trigger Success Screen
    setState(() {
      isMissionActive = false;
      isSuccessScreen = true;
    });

    // Delay to show the Yay! screen before closing
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context);
    });
  }

  String get formattedTime {
    int minutes = remainingSeconds ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, String> _getFormattedClockTime() {
    int rawHour = widget.alarmSettings.dateTime.hour;
    String period = rawHour >= 12 ? 'PM' : 'AM';
    int displayHourNum = rawHour % 12;
    if (displayHourNum == 0) displayHourNum = 12;
    String displayHour = displayHourNum.toString().padLeft(2, '0');
    String displayMinute =
        widget.alarmSettings.dateTime.minute.toString().padLeft(2, '0');
    return {'time': '$displayHour:$displayMinute', 'period': period};
  }

  @override
  Widget build(BuildContext context) {
    // 1. Success Screen Overlay
    if (isSuccessScreen) {
      return Scaffold(
        backgroundColor: AppColors.neumorphicBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("🎉", style: TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              Text(
                "Yay! Mission Completed!",
                style: AppTypography.alarmHeader.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 2. Standard Restored UI
    String headerText = 'WAKE UP';
    if (isMissionActive) headerText = 'MISSION ACTIVE';
    if (isPenaltyRinging) headerText = 'PENALTY RINGING';
    final clockData = _getFormattedClockTime();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.neumorphicBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  headerText,
                  style: AppTypography.interfaceLabel.copyWith(
                    color: (isMissionActive || isPenaltyRinging)
                        ? AppColors.accentOrange
                        : AppColors.pureBlack,
                    letterSpacing: 3.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: NeumorphicStyles.convexDecoration(radius: 32),
                  child: Column(
                    children: [
                      Text(
                        isMissionActive ? formattedTime : clockData['time']!,
                        style: AppTypography.alarmHeader.copyWith(fontSize: 64),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMissionActive
                            ? 'REMAINING TO COMPLETE'
                            : clockData['period']!,
                        style: AppTypography.interfaceLabel.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                if (!isMissionActive) ...[
                  GestureDetector(
                    onTap: _startMission,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration:
                          NeumorphicStyles.concaveDecoration(radius: 20),
                      child: Center(
                        child: Text(
                          'START MISSION',
                          style: AppTypography.interfaceLabel.copyWith(
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppColors.pureBlack.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.pureBlack.withOpacity(0.05))),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppColors.accentOrange, size: 16),
                            const SizedBox(width: 8),
                            Text(
                                isPenaltyRinging
                                    ? 'FINAL WARNING'
                                    : 'MISSION RULES',
                                style: AppTypography.interfaceLabel.copyWith(
                                    color: AppColors.accentOrange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isPenaltyRinging
                              ? 'Complete the mission now. Remaining silent past the countdown will turn the alarm off permanently to safeguard device hardware.'
                              : 'Start and complete the mission (Affirmations & Steps) to stop the alarm.\n\nFailing to complete it within the 5-minute timer will trigger the alarm again.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 13,
                              color: AppColors.textDark,
                              height: 1.6,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // RESTORED STEP WIDGET WITH TICKMARK
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (currentSteps < targetSteps) currentSteps += 5;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: NeumorphicStyles.convexDecoration(radius: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                  currentSteps >= targetSteps
                                      ? Icons.check_circle
                                      : Icons.directions_walk,
                                  color: currentSteps >= targetSteps
                                      ? Colors.green
                                      : AppColors.accentOrange,
                                  size: 28),
                              const SizedBox(width: 12),
                              Text('MANDATORY STEPS',
                                  style: AppTypography.interfaceLabel
                                      .copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(
                            '$currentSteps / $targetSteps',
                            style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 18,
                                color: currentSteps >= targetSteps
                                    ? Colors.green
                                    : AppColors.pureBlack,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // OPTIONAL SKIP BUTTON FOR THOSE WHO CANNOT WALK
                  if (currentSteps < targetSteps) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentSteps = targetSteps;
                        });
                      },
                      child: const Text(
                        "I can't walk right now (Skip)",
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: NeumorphicStyles.concaveDecoration(radius: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isTypingMode = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: isTypingMode
                                  ? NeumorphicStyles.convexDecoration(
                                      radius: 24)
                                  : const BoxDecoration(),
                              child: Center(
                                child: Text('Type',
                                    style: AppTypography.interfaceLabel
                                        .copyWith(
                                            color: isTypingMode
                                                ? AppColors.pureBlack
                                                : AppColors.textMuted,
                                            fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => isTypingMode = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: !isTypingMode
                                  ? NeumorphicStyles.convexDecoration(
                                      radius: 24)
                                  : const BoxDecoration(),
                              child: Center(
                                child: Text('Speak',
                                    style: AppTypography.interfaceLabel
                                        .copyWith(
                                            color: !isTypingMode
                                                ? AppColors.pureBlack
                                                : AppColors.textMuted,
                                            fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  isTypingMode
                      ? TypingMissionWidget(
                          targetAffirmation: targetAffirmation,
                          onMissionComplete: _completeMission,
                        )
                      : VoiceMissionWidget(
                          targetAffirmation: targetAffirmation,
                          onMissionComplete: _completeMission,
                        ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
