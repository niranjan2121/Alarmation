import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart'; // Import Alarm
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/neumorphic_styles.dart';
import '../../alarm_clock/ui/alarm_home_screen.dart';
import '../../manifestation/ui/affirmation_library_screen.dart';
import '../../morning_mission/ui/active_mission_screen.dart'; // Import Mission Screen

class MainNavigationRoot extends StatefulWidget {
  const MainNavigationRoot({super.key});

  @override
  State<MainNavigationRoot> createState() => _MainNavigationRootState();
}

class _MainNavigationRootState extends State<MainNavigationRoot> {
  int _currentIndex = 0;
  static StreamSubscription<AlarmSettings>? ringSubscription;

  final List<Widget> _screens = [
    const AlarmHomeScreen(),
    const AffirmationLibraryScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // LISTEN FOR THE ALARM TRIGGER
    ringSubscription ??= Alarm.ringStream.stream.listen((alarmSettings) {
      // When the alarm rings, force navigate to the Active Mission Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ActiveMissionScreen(alarmSettings: alarmSettings),
        ),
      );
    });
  }

  @override
  void dispose() {
    ringSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neumorphicBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        decoration: NeumorphicStyles.convexDecoration(radius: 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: AppColors.neumorphicBackground,
            elevation: 0,
            currentIndex: _currentIndex,
            selectedItemColor: AppColors.accentOrange,
            unselectedItemColor: AppColors.textMuted,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time_filled),
                label: 'Alarm',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome),
                label: 'Manifest',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
