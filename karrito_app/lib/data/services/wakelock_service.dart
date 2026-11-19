import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

abstract interface class WakelockService {
  Future<void> setEnabled(bool enabled);
}

class PlatformWakelockService implements WakelockService {
  @override
  Future<void> setEnabled(bool enabled) async {
    try {
      await WakelockPlus.toggle(enable: enabled);
    } catch (error) {
      debugPrint('Karrito WakelockService ignored error: $error');
    }
  }
}
