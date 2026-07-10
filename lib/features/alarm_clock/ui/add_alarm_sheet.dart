import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/neumorphic_styles.dart';
import '../../../core/models/manifestation_template.dart';
import '../../../core/models/wake_up_song.dart';
import '../../../core/data/mock_database.dart';
import '../../../core/models/alarm_model.dart';
import '../../morning_mission/ui/mission_configuration_screen.dart';
import 'song_selection_screen.dart';

class AddAlarmSheet extends StatefulWidget {
  final AlarmModel? existingAlarm;

  const AddAlarmSheet({super.key, this.existingAlarm});

  @override
  State<AddAlarmSheet> createState() => _AddAlarmSheetState();
}

class _AddAlarmSheetState extends State<AddAlarmSheet> {
  DateTime selectedTime = DateTime.now();
  bool isVibrationOn = true;
  List<bool> selectedDays = [true, true, true, true, true, false, false];
  final List<String> dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  int steps = 30;
  ManifestationTemplate currentTemplate = MockDatabase.templates.first;
  WakeUpSong currentSong = MockDatabase.songs.first;

  @override
  void initState() {
    super.initState();
    if (widget.existingAlarm != null) {
      selectedTime = widget.existingAlarm!.time;
      isVibrationOn = widget.existingAlarm!.vibrate;
      selectedDays = List.from(widget.existingAlarm!.activeDays);
      steps = widget.existingAlarm!.missionSteps;

      try {
        currentSong = MockDatabase.songs
            .firstWhere((s) => s.fileUrl == widget.existingAlarm!.songPath);
      } catch (e) {
        currentSong = MockDatabase.songs.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.neumorphicBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                  color: AppColors.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10))),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: AppTypography.interfaceLabel)),
                Text(widget.existingAlarm != null ? 'Edit Alarm' : 'New Alarm',
                    style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pureBlack)),
                TextButton(
                  onPressed: () {
                    final uniqueId = widget.existingAlarm?.id ??
                        (DateTime.now().millisecondsSinceEpoch % 10000);

                    final newAlarm = AlarmModel(
                      id: uniqueId,
                      time: selectedTime,
                      activeDays: selectedDays,
                      isActive: widget.existingAlarm?.isActive ?? true,
                      songPath: currentSong.fileUrl,
                      isAsset: currentSong.isAsset,
                      missionSteps: steps,
                      templateCategory: currentTemplate.category,
                      vibrate: isVibrationOn,
                    );

                    Navigator.pop(context, newAlarm);
                  },
                  child: Text('Save',
                      style: AppTypography.interfaceLabel.copyWith(
                          color: AppColors.accentOrange,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontSize: 32,
                          color: AppColors.pureBlack,
                          fontWeight: FontWeight.bold))),
              child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selectedTime,
                  onDateTimeChanged: (DateTime newTime) =>
                      setState(() => selectedTime = newTime)),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                bool isActive = selectedDays[index];
                return GestureDetector(
                  onTap: () => setState(
                      () => selectedDays[index] = !selectedDays[index]),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: isActive
                        ? NeumorphicStyles.concaveDecoration(radius: 20)
                            .copyWith(color: AppColors.pureBlack)
                        : NeumorphicStyles.convexDecoration(radius: 20),
                    child: Center(
                      child: Text(
                        dayLabels[index],
                        style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? AppColors.accentOrange
                                : AppColors.textMuted),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildSettingRow(
                    title: 'Mission',
                    value: '${currentTemplate.category} ($steps)',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MissionConfigurationScreen(
                                initialSteps: steps,
                                initialTemplate: currentTemplate)),
                      );
                      if (result != null) {
                        setState(() {
                          steps = result['steps'];
                          currentTemplate = result['template'];
                        });
                      }
                    }),
                const SizedBox(height: 16),
                _buildSettingRow(
                    title: 'Sound',
                    value: currentSong.title,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SongSelectionScreen(
                                currentSongId: currentSong.id)),
                      );
                      if (result != null && result is WakeUpSong)
                        setState(() => currentSong = result);
                    }),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: NeumorphicStyles.convexDecoration(radius: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Vibration',
                          style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                      CupertinoSwitch(
                          activeColor: AppColors.pureBlack,
                          value: isVibrationOn,
                          onChanged: (bool value) =>
                              setState(() => isVibrationOn = value)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
      {required String title,
      required String value,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: NeumorphicStyles.convexDecoration(radius: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
            Row(children: [
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14,
                      color: AppColors.textMuted)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.textMuted)
            ]),
          ],
        ),
      ),
    );
  }
}
