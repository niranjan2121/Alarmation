import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/neumorphic_styles.dart';
import '../../../core/models/alarm_model.dart';
import 'add_alarm_sheet.dart';

class AlarmHomeScreen extends StatefulWidget {
  const AlarmHomeScreen({super.key});

  @override
  State<AlarmHomeScreen> createState() => _AlarmHomeScreenState();
}

class _AlarmHomeScreenState extends State<AlarmHomeScreen> {
  List<AlarmModel> myAlarms = [];
  final List<String> dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // Calculates exact next ring time for scheduling AND priority sorting
  DateTime _calculateNextRingTime(
      DateTime selectedTime, List<bool> activeDays) {
    DateTime now = DateTime.now();
    DateTime candidate = DateTime(
        now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);

    // If it's a one-time alarm (no days selected)
    if (!activeDays.contains(true)) {
      return candidate.isBefore(now)
          ? candidate.add(const Duration(days: 1))
          : candidate;
    }

    // Check if today is active and time hasn't passed
    int currentDayIndex = candidate.weekday - 1;
    if (activeDays[currentDayIndex] == true && candidate.isAfter(now))
      return candidate;

    // Search the next 7 days for the closest active day
    for (int i = 1; i <= 7; i++) {
      candidate = candidate.add(const Duration(days: 1));
      if (activeDays[candidate.weekday - 1] == true) return candidate;
    }
    return candidate;
  }

  // Sorts the list so the closest upcoming active alarm is first
  void _sortAlarms() {
    myAlarms.sort((a, b) {
      if (a.isActive && !b.isActive) return -1;
      if (!a.isActive && b.isActive) return 1;
      return _calculateNextRingTime(a.time, a.activeDays)
          .compareTo(_calculateNextRingTime(b.time, b.activeDays));
    });
  }

  // Uses the NEW Package Syntax
  Future<void> _scheduleNativeAlarm(AlarmModel alarm) async {
    final ringTime = _calculateNextRingTime(alarm.time, alarm.activeDays);
    String audioPath =
        alarm.isAsset ? 'assets/audio/${alarm.songPath}' : alarm.songPath;

    final alarmSettings = AlarmSettings(
      id: alarm.id,
      dateTime: ringTime,
      assetAudioPath: audioPath,
      loopAudio: true,
      vibrate: alarm.vibrate,
      warningNotificationOnKill: true,
      androidFullScreenIntent: true,
      volumeSettings: const VolumeSettings.fixed(volume: 0.8), // New Syntax
      notificationSettings: NotificationSettings(
        // New Syntax
        title: 'Alarmation',
        body: 'Wake up! Mission required: ${alarm.missionSteps} steps',
        stopButton: 'Start Mission',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neumorphicBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Alarm',
                      style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pureBlack)),
                  Container(
                      decoration: BoxDecoration(
                          color: AppColors.pureBlack,
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.grid_view_rounded,
                          color: Colors.white, size: 20)),
                ],
              ),
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: NeumorphicStyles.convexDecoration(radius: 150),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: AppColors.pureBlack,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5))
                          ]),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 180,
                child: myAlarms.isEmpty
                    ? const Center(
                        child: Text("No Alarms Set",
                            style: TextStyle(color: AppColors.textMuted)))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        itemCount: myAlarms.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: _buildDynamicAlarmCard(myAlarms[index], index),
                        ),
                      ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: NeumorphicStyles.convexDecoration(radius: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.calendar_today,
                            color: AppColors.pureBlack),
                        onPressed: () {}),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                          color: AppColors.pureBlack,
                          borderRadius: BorderRadius.circular(30)),
                      child: Text('${myAlarms.length}/15 Alarms',
                          style: const TextStyle(
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColors.pureBlack),
                      onPressed: () async {
                        // 15 ALARM LIMIT CHECK
                        if (myAlarms.length >= 15) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Maximum limit of 15 alarms reached.'),
                                backgroundColor: AppColors.pureBlack),
                          );
                          return;
                        }

                        final newAlarm = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddAlarmSheet(),
                        );

                        if (newAlarm != null && newAlarm is AlarmModel) {
                          setState(() {
                            myAlarms.add(newAlarm);
                            _sortAlarms();
                          });
                          await _scheduleNativeAlarm(newAlarm);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicAlarmCard(AlarmModel alarm, int index) {
    String hour = alarm.time.hour.toString().padLeft(2, '0');
    String minute = alarm.time.minute.toString().padLeft(2, '0');

    return GestureDetector(
      // EDIT EXISTING ALARM
      onTap: () async {
        final updatedAlarm = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AddAlarmSheet(existingAlarm: alarm),
        );

        if (updatedAlarm != null && updatedAlarm is AlarmModel) {
          setState(() {
            myAlarms[index] = updatedAlarm;
            _sortAlarms();
          });
          if (updatedAlarm.isActive) {
            await _scheduleNativeAlarm(updatedAlarm);
          } else {
            await Alarm.stop(updatedAlarm.id);
          }
        }
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: NeumorphicStyles.convexDecoration(radius: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async {
                setState(() {
                  myAlarms[index].isActive = !myAlarms[index].isActive;
                  _sortAlarms();
                });

                if (myAlarms[index].isActive) {
                  await _scheduleNativeAlarm(myAlarms[index]);
                } else {
                  await Alarm.stop(myAlarms[index].id);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      alarm.isActive ? AppColors.pureBlack : Colors.transparent,
                  border: Border.all(color: AppColors.pureBlack, width: 2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  alarm.isActive ? 'ON' : 'OFF',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color:
                          alarm.isActive ? Colors.white : AppColors.pureBlack),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (dayIndex) {
                    return Text(
                      dayLabels[dayIndex],
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: alarm.activeDays[dayIndex]
                            ? AppColors.accentOrange
                            : AppColors.textMuted.withOpacity(0.4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  '$hour:$minute',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 32,
                      color: alarm.isActive
                          ? AppColors.pureBlack
                          : AppColors.textMuted,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
