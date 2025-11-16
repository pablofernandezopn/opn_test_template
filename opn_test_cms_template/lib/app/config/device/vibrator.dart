
import 'package:vibration/vibration.dart';
import '../preferences_service.dart';

class CustomVibrator {

  CustomVibrator(this._prefs);
  bool _isVibrating = false;
  bool _hasCustomVibration = false;
  bool _isVibrationEnabled = false;
  final PreferencesService _prefs;

  Future<void> init() async {
    _isVibrating = await Vibration.hasVibrator();
    _hasCustomVibration = await Vibration.hasCustomVibrationsSupport() ;
    final enabled = await _prefs.get('vibration_enabled') ?? 'false';
    _isVibrationEnabled = enabled == 'true';
  }

  Future<void> vibrate({int duration = 100, List<int>? pattern}) async {
    if (!_isVibrating || !_isVibrationEnabled) return;
    if (_hasCustomVibration) {
      await Vibration.vibrate(pattern: pattern ?? [duration], duration: duration);
    } else {
      await Vibration.vibrate();
    }
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _isVibrationEnabled = enabled;
    await _prefs.set('vibration_enabled', enabled ? 'true' : 'false');
  }

  bool isEnable() {
    return _isVibrationEnabled;
  }
}
