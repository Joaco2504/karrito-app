import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract interface class SoundFeedbackService {
  Future<void> playItemCheckedFeedback();
  Future<void> dispose();
}

/// Plays a crisp local offline check-pop sound alongside light haptic feedback
/// when the user marks an item as bought in the shopping list.
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

  @override
  Future<void> playItemCheckedFeedback() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Ignore on headless test platforms.
    }

    try {
      await _ensureConfigured();
      await _player.stop();
      await _player.play(AssetSource(_checkAssetPath), volume: 0.72);
    } catch (e) {
      debugPrint('Karrito check sound playback skipped: $e');
    }
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
