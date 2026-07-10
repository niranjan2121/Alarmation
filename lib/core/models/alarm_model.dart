class AlarmModel {
  final int id; 
  DateTime time;
  List<bool> activeDays; 
  bool isActive;
  final String songPath;
  final bool isAsset;
  final int missionSteps;
  final String templateCategory;
  final bool vibrate;

  AlarmModel({
    required this.id,
    required this.time,
    required this.activeDays,
    this.isActive = true,
    required this.songPath,
    required this.isAsset,
    required this.missionSteps,
    required this.templateCategory,
    this.vibrate = true,
  });
}