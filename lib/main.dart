import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:alarm/alarm.dart'; // Import the alarm package
import 'core/theme/app_theme.dart';
import 'features/navigation/ui/main_navigation_root.dart';

void main() async {
  // Ensure native bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the native alarm engine
  await Alarm.init();

  runApp(const AlarmationApp());
}

class AlarmationApp extends StatelessWidget {
  const AlarmationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarmation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        if (kIsWeb) {
          return Scaffold(
            backgroundColor: const Color(0xFF1E1E1E),
            body: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: SizedBox(width: 400, height: 850, child: child),
              ),
            ),
          );
        }
        return child!;
      },
      home: const MainNavigationRoot(),
    );
  }
}
