import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/config/monetization_config.dart';

class MediaGuardException implements Exception {
  const MediaGuardException(this.userMessage);
  final String userMessage;

  @override
  String toString() => userMessage;
}

class EncodedVoicePayload {
  const EncodedVoicePayload({
    required this.base64Data,
    required this.mimeType,
    required this.byteLength,
    required this.durationSeconds,
  });

  final String base64Data;
  final String mimeType;
  final int byteLength;
  final int durationSeconds;
}

class EncodedImagePayload {
  const EncodedImagePayload({
    required this.base64Data,
    required this.mimeType,
    required this.byteLength,
  });

  final String base64Data;
  final String mimeType;
  final int byteLength;
}

abstract interface class MediaCaptureService {
  Future<bool> startVoiceRecording();
  Future<EncodedVoicePayload?> stopVoiceRecording({
    required int durationSeconds,
  });
  Future<void> cancelVoiceRecording();
  Future<EncodedImagePayload?> pickAndCompressImage(ImageSource source);
  Future<void> dispose();
}

/// Enforces `.agents/skills/karrito-media-guard/SKILL.md`:
/// - Voice: M4A/AAC-LC at 48 kbps, rejected client-side if > 60 s or > 500 KB.
/// - Images: compressed to max 1024 px longest side, JPEG quality 75%.
class KarritoMediaCaptureService implements MediaCaptureService {
  KarritoMediaCaptureService({AudioRecorder? recorder, ImagePicker? picker})
    : _recorder = recorder ?? AudioRecorder(),
      _picker = picker ?? ImagePicker();

  final AudioRecorder _recorder;
  final ImagePicker _picker;
  String? _currentRecordingPath;

  /// Pure validation rule required by `karrito-media-guard`.
  static void validateVoiceLimits({
    required int durationSeconds,
    required int byteLength,
  }) {
    if (durationSeconds > MonetizationConfig.maxVoiceDurationSeconds) {
      throw const MediaGuardException(
        'El audio supera el máximo de 60 segundos. Grabá un dictado más corto e intentá de nuevo.',
      );
    }
    if (byteLength <= 0) {
      throw const MediaGuardException(
        'No escuchamos audio en la grabación. Acercate al micrófono y probá de nuevo.',
      );
    }
    if (byteLength > MonetizationConfig.maxVoiceBytes) {
      throw const MediaGuardException(
        'El audio pesa más de 500 KB. Grabá un dictado más corto para procesarlo.',
      );
    }
  }

  @override
  Future<bool> startVoiceRecording() async {
    final allowed = await _recorder.hasPermission();
    if (!allowed) {
      throw const MediaGuardException(
        'Necesitamos permiso de micrófono para dictar productos. Habilitalo en los ajustes de tu teléfono.',
      );
    }

    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}${Platform.pathSeparator}karrito_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _currentRecordingPath = path;

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: MonetizationConfig.voiceBitRateBps,
        sampleRate: MonetizationConfig.voiceSampleRateHz,
        numChannels: 1,
      ),
      path: path,
    );
    return true;
  }

  @override
  Future<EncodedVoicePayload?> stopVoiceRecording({
    required int durationSeconds,
  }) async {
    final recordedPath = await _recorder.stop() ?? _currentRecordingPath;
    _currentRecordingPath = null;
    if (recordedPath == null || recordedPath.isEmpty) {
      return null;
    }

    final file = File(recordedPath);
    try {
      if (!await file.exists()) {
        return null;
      }
      final bytes = await file.readAsBytes();
      validateVoiceLimits(
        durationSeconds: durationSeconds,
        byteLength: bytes.length,
      );
      return EncodedVoicePayload(
        base64Data: base64Encode(bytes),
        mimeType: 'audio/m4a',
        byteLength: bytes.length,
        durationSeconds: durationSeconds,
      );
    } finally {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Karrito temp audio cleanup skipped: $e');
      }
    }
  }

  @override
  Future<void> cancelVoiceRecording() async {
    final path = _currentRecordingPath;
    _currentRecordingPath = null;
    try {
      await _recorder.cancel();
    } catch (_) {
      // Ignore cancel errors if already stopped.
    }
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Ignore cleanup errors.
      }
    }
  }

  @override
  Future<EncodedImagePayload?> pickAndCompressImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: MonetizationConfig.maxImageDimensionPx.toDouble(),
      maxHeight: MonetizationConfig.maxImageDimensionPx.toDouble(),
      imageQuality: MonetizationConfig.imageJpegQuality,
    );
    if (picked == null) {
      return null;
    }

    Uint8List? compressed;
    try {
      compressed = await FlutterImageCompress.compressWithFile(
        picked.path,
        minWidth: MonetizationConfig.maxImageDimensionPx,
        minHeight: MonetizationConfig.maxImageDimensionPx,
        quality: MonetizationConfig.imageJpegQuality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
    } catch (e) {
      debugPrint('Karrito FlutterImageCompress fallback to picked bytes: $e');
      compressed = await picked.readAsBytes();
    }

    if (compressed == null || compressed.isEmpty) {
      throw const MediaGuardException(
        'No pudimos leer esa imagen. Probá sacar otra foto o elegir otra captura.',
      );
    }

    return EncodedImagePayload(
      base64Data: base64Encode(compressed),
      mimeType: 'image/jpeg',
      byteLength: compressed.length,
    );
  }

  @override
  Future<void> dispose() async {
    await cancelVoiceRecording();
    try {
      await _recorder.dispose();
    } catch (_) {
      // Ignore dispose errors.
    }
  }
}
