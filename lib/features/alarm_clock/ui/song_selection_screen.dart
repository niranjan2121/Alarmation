import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart'; // Audio Engine
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/neumorphic_styles.dart';
import '../../../core/data/mock_database.dart';
import '../../../core/models/wake_up_song.dart';

class SongSelectionScreen extends StatefulWidget {
  final String currentSongId;

  const SongSelectionScreen({super.key, required this.currentSongId});

  @override
  State<SongSelectionScreen> createState() => _SongSelectionScreenState();
}

class _SongSelectionScreenState extends State<SongSelectionScreen> {
  // Initialize the audio player engine
  final AudioPlayer _audioPlayer = AudioPlayer();
  String?
      _currentlyPlayingId; // Keeps track of what song is currently previewing

  @override
  void dispose() {
    // CRITICAL: Stop the music and destroy the player when leaving the screen!
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePreview(WakeUpSong song) async {
    if (_currentlyPlayingId == song.id) {
      // If tapping the same song, stop it
      await _audioPlayer.stop();
      setState(() => _currentlyPlayingId = null);
    } else {
      // If tapping a new song, stop old one and play new one
      await _audioPlayer.stop();

      // Determine where the file lives (App Asset vs User's Phone Storage)
      Source audioSource = song.isAsset
          ? AssetSource('audio/${song.fileUrl}')
          : DeviceFileSource(song.fileUrl);

      await _audioPlayer.play(audioSource);
      setState(() => _currentlyPlayingId = song.id);
    }
  }

  Future<void> _pickLocalFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.audio);

    if (result != null) {
      final localSong = WakeUpSong(
        id: 'local_${result.files.single.name}',
        title: result.files.single.name.replaceAll('.mp3', ''),
        author: 'From Device',
        fileUrl: result.files.single.path ?? '',
        isPremium: false,
        category: 'Local',
        isAsset: false, // Flags that it is NOT a bundled asset
      );

      if (context.mounted) {
        Navigator.pop(context, localSong);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neumorphicBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
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
                      'Select Sound',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pureBlack),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Select From Device Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: GestureDetector(
                onTap: () => _pickLocalFile(context),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: NeumorphicStyles.convexDecoration(radius: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppColors.pureBlack,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.folder_open,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Choose from Device',
                          style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pureBlack),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: AppColors.textMuted, size: 16),
                    ],
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Text(
                'ALARMATION LIBRARY',
                style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.bold),
              ),
            ),

            // List of Database Songs
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: MockDatabase.songs.length,
                itemBuilder: (context, index) {
                  final song = MockDatabase.songs[index];
                  final isSelected = song.id == widget.currentSongId;
                  final isPlaying = song.id ==
                      _currentlyPlayingId; // Check if this specific song is previewing

                  return GestureDetector(
                    onTap: () => Navigator.pop(
                        context, song), // Tapping the row selects the song
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
                                      song.category.toUpperCase(),
                                      style:
                                          AppTypography.interfaceLabel.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.accentOrange
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                    if (song.isPremium) ...[
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
                                  song.title,
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 16,
                                    color: isSelected
                                        ? AppColors.pureBlack
                                        : AppColors.textMuted,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(song.author,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted)),
                                const SizedBox(height: 12),

                                // ACTIVE PREVIEW BUTTON
                                GestureDetector(
                                  onTap: () => _togglePreview(
                                      song), // Tapping the preview button plays/stops it
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isPlaying
                                          ? AppColors.accentOrange
                                              .withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: isPlaying
                                              ? AppColors.accentOrange
                                              : AppColors.textMuted
                                                  .withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                            isPlaying
                                                ? Icons.stop_circle
                                                : Icons.play_circle_fill,
                                            color: isPlaying
                                                ? AppColors.accentOrange
                                                : AppColors.textMuted,
                                            size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          isPlaying ? 'Stop' : 'Preview',
                                          style: TextStyle(
                                            fontFamily: 'Satoshi',
                                            fontSize: 12,
                                            color: isPlaying
                                                ? AppColors.accentOrange
                                                : AppColors.textMuted,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
