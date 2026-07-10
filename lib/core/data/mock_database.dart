import '../models/manifestation_template.dart';
import '../models/wake_up_song.dart';

class MockDatabase {
  static final List<ManifestationTemplate> templates = [
    ManifestationTemplate(
      id: 't_001',
      text: 'I wake up with pure focus, energy, and clear purpose to master my day.',
      category: 'Focus',
      isPremium: false,
      wordCount: 14,
    ),
    ManifestationTemplate(
      id: 't_002',
      text: 'Every step I take today brings me closer to my ultimate financial freedom.',
      category: 'Wealth',
      isPremium: true,
      wordCount: 13,
    ),
  ];

  static final List<WakeUpSong> songs = [
    WakeUpSong(
      id: 's_001',
      title: 'Morning Clarity',
      author: 'Alarmation Originals',
      fileUrl: 'clarity.mp3', // Matches the exact filename in assets/audio/
      isPremium: false,
      category: 'Basic',
      isAsset: true, // Flags it as a bundled file
    ),
    WakeUpSong(
      id: 's_002',
      title: 'Deep Focus Alpha',
      author: 'Alarmation Originals',
      fileUrl: 'focus.mp3', // Matches the exact filename in assets/audio/
      isPremium: true,
      category: 'Pro Focus',
      isAsset: true, // Flags it as a bundled file
    ),
  ];
}