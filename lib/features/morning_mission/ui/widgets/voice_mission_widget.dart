import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neumorphic_styles.dart';

class VoiceMissionWidget extends StatefulWidget {
  final String targetAffirmation;
  final VoidCallback onMissionComplete;

  const VoiceMissionWidget({
    super.key,
    required this.targetAffirmation,
    required this.onMissionComplete,
  });

  @override
  State<VoiceMissionWidget> createState() => _VoiceMissionWidgetState();
}

class _VoiceMissionWidgetState extends State<VoiceMissionWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // NEW: Memory buffer logic
  String _previousText = "";
  String _currentRecognizedText = "";
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Combines saved text with currently spoken text
  String get _fullText => ("$_previousText $_currentRecognizedText").trim();

  double _calculateSimilarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    s1 = s1.toLowerCase().trim();
    s2 = s2.toLowerCase().trim();

    List<int> v0 = List<int>.filled(s2.length + 1, 0);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i <= s2.length; i++) v0[i] = i;

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        int cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost]
            .reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j <= s2.length; j++) v0[j] = v1[j];
    }

    int distance = v1[s2.length];
    int maxLength = s1.length > s2.length ? s1.length : s2.length;
    return 1.0 - (distance / maxLength);
  }

  void _checkAccuracy() {
    double accuracy = _calculateSimilarity(_fullText, widget.targetAffirmation);
    bool meetsThreshold = accuracy >= 0.50; // 50% accuracy to pass
    if (_isUnlocked != meetsThreshold) {
      setState(() => _isUnlocked = meetsThreshold);
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          // When auto-stop happens, save current text to memory buffer
          if (status == 'done' || status == 'notListening') {
            if (mounted) {
              setState(() {
                _isListening = false;
                if (_currentRecognizedText.isNotEmpty) {
                  _previousText =
                      "$_previousText $_currentRecognizedText ".trim();
                  _currentRecognizedText = "";
                }
              });
            }
          }
        },
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _currentRecognizedText = val.recognizedWords;
            _checkAccuracy();
          }),
          listenMode: stt.ListenMode.dictation, // Dictation handles long pauses
          pauseFor: const Duration(seconds: 15), // Waits 15 seconds of silence
          partialResults: true,
        );
      }
    } else {
      // Manual stop: Save text to buffer
      setState(() {
        _isListening = false;
        if (_currentRecognizedText.isNotEmpty) {
          _previousText = "$_previousText $_currentRecognizedText ".trim();
          _currentRecognizedText = "";
        }
      });
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: NeumorphicStyles.convexDecoration(radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic,
                      color: AppColors.accentOrange, size: 20),
                  const SizedBox(width: 8),
                  Text('SPEAK TO UNLOCK',
                      style: AppTypography.interfaceLabel
                          .copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.targetAffirmation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 16,
                    color: AppColors.pureBlack,
                    fontWeight: FontWeight.w600,
                    height: 1.4),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _listen,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 80,
                  height: 80,
                  decoration: _isListening
                      ? NeumorphicStyles.concaveDecoration(radius: 40)
                      : NeumorphicStyles.convexDecoration(radius: 40),
                  child: Center(
                    child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening
                            ? AppColors.accentOrange
                            : AppColors.pureBlack,
                        size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                  _isListening
                      ? 'Listening (15s timeout)...'
                      : 'Tap to start/resume...',
                  style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      color: _isListening
                          ? AppColors.accentOrange
                          : AppColors.textMuted)),
              if (_fullText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '"$_fullText"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, color: AppColors.textDark),
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _isUnlocked ? widget.onMissionComplete : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: _isUnlocked
                ? BoxDecoration(
                    color: AppColors.pureBlack,
                    borderRadius: BorderRadius.circular(20))
                : NeumorphicStyles.concaveDecoration(radius: 20),
            child: Center(
              child: Text(
                _isUnlocked ? 'COMPLETE MISSION' : 'LOCKED (Speak to unlock)',
                style: AppTypography.interfaceLabel.copyWith(
                    color: _isUnlocked ? Colors.white : AppColors.textMuted,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
