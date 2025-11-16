import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {

  // Private constructor, only we can create instances of this class
  // using the getInstance method
  PreferencesService._()
      : storage = Platform.isMacOS
          ? null  // Deshabilitado en macOS para evitar problemas de firmado en desarrollo
          : const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  // Create storage
  final FlutterSecureStorage? storage;

  // Fallback para macOS durante desarrollo
  static SharedPreferences? _prefs;

  static PreferencesService? _instance;

  static Future<PreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = PreferencesService._();

      if (Platform.isMacOS) {
        // En macOS usamos SharedPreferences para evitar problemas de Keychain
        _prefs = await SharedPreferences.getInstance();
      } else {
        // En iOS/Android usamos FlutterSecureStorage
        await _instance!.set('migration', 'false');
        final old = await SharedPreferences.getInstance();

        // migrate "notifications_accepted"
        await _instance!.set(
          'notifications_accepted',
          (old.getBool('notifications_accepted') ?? false).toString(),
        );

        await _instance!.set('migration', 'true');
      }
    }

    return _instance!;
  }

  Future<String?> get(String key) async {
    if (Platform.isMacOS) {
      return _prefs?.getString(key);
    }
    return storage?.read(key: key);
  }

  Future<void> set(String key, String value) async {
    if (Platform.isMacOS) {
      await _prefs?.setString(key, value);
    } else {
      await storage?.write(key: key, value: value);
    }
  }

  Future<void> remove(String key) async {
    if (Platform.isMacOS) {
      await _prefs?.remove(key);
    } else {
      await storage?.delete(key: key);
    }
  }

  // ==========================================
  // 📝 MÉTODOS TIPADOS
  // ==========================================

  /// Lee un String desde las preferencias
  Future<String?> getString(String key) async {
    return get(key);
  }

  /// Guarda un String en las preferencias
  Future<void> setString(String key, String value) async {
    await set(key, value);
  }

  /// Lee un int desde las preferencias
  /// Retorna null si la clave no existe o el valor no es un entero válido
  Future<int?> getInt(String key) async {
    final value = await get(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  /// Guarda un int en las preferencias
  Future<void> setInt(String key, int value) async {
    await set(key, value.toString());
  }

  /// Lee un bool desde las preferencias
  /// Retorna null si la clave no existe o el valor no es un booleano válido
  Future<bool?> getBool(String key) async {
    final value = await get(key);
    if (value == null) return null;
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
    return null;
  }

  /// Guarda un bool en las preferencias
  Future<void> setBool(String key, bool value) async {
    await set(key, value.toString());
  }

  /// Lee un double desde las preferencias
  /// Retorna null si la clave no existe o el valor no es un double válido
  Future<double?> getDouble(String key) async {
    final value = await get(key);
    if (value == null) return null;
    return double.tryParse(value);
  }

  /// Guarda un double en las preferencias
  Future<void> setDouble(String key, double value) async {
    await set(key, value.toString());
  }

  /// Lee una lista de Strings desde las preferencias
  /// Retorna null si la clave no existe
  /// Los elementos se separan por coma
  Future<List<String>?> getStringList(String key) async {
    final value = await get(key);
    if (value == null || value.isEmpty) return null;
    return value.split(',');
  }

  /// Guarda una lista de Strings en las preferencias
  /// Los elementos se unen con coma
  Future<void> setStringList(String key, List<String> values) async {
    await set(key, values.join(','));
  }

  /// Verifica si existe una clave en las preferencias
  Future<bool> containsKey(String key) async {
    final value = await get(key);
    return value != null;
  }

  /// Limpia todas las preferencias
  Future<void> clear() async {
    if (Platform.isMacOS) {
      await _prefs?.clear();
    } else {
      await storage?.deleteAll();
    }
  }
}
