import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

abstract interface class SoundFeedbackService {
  Future<void> playItemCheckedFeedback({
    bool playSound = true,
    bool triggerVibration = true,
  });
  Future<void> dispose();
}

/// Plays a crisp local offline check-pop sound (`PlayerMode.lowLatency`) and
/// configurable tactile vibration (`Vibration.vibrate(duration: 35)` with
/// `HapticFeedback.mediumImpact()` fallback) when checking off a shopping item.
class AudioplayersSoundService implements SoundFeedbackService {
  AudioplayersSoundService({AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  static const String _checkAssetPath = 'sounds/check_pop.wav';

  final AudioPlayer _player;
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    _configured = true;
    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.lowLatency);
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Karrito sound audio context setup skipped: $e');
    }
  }

  Future<void> _triggerVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator) {
        await Vibration.vibrate(duration: 35);
        return;
      }
    } catch (_) {
      // Fall through to Flutter haptic feedback on unsupported/headless devices.
    }
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {
      // Ignore on headless test platforms.
    }
  }

  Future<void> _playCheckSound() async {
    try {
      await _ensureConfigured();
      await _player.stop();
      await _player.play(
        AssetSource(_checkAssetPath),
        volume: 0.85,
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      debugPrint('Karrito check sound playback skipped: $e');
    }
  }

  @override
  Future<void> playItemCheckedFeedback({
    bool playSound = true,
    bool triggerVibration = true,
  }) async {
    if (!playSound && !triggerVibration) return;
    await Future.wait<void>(<Future<void>>[
      if (triggerVibration) _triggerVibration(),
      if (playSound) _playCheckSound(),
    ]);
  }

  @override
  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (_) {
      // Ignore dispose errors.
    }
  }
}
