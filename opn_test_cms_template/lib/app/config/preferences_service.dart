import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {

  // Private constructor, only we can create instances of this class
  // using the getInstance method
  PreferencesService._()
      : storage = _shouldUseSharedPreferences()
          ? null  // Deshabilitado en web y macOS
          : const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  // Helper para determinar si usar SharedPreferences (web o macOS)
  static bool _shouldUseSharedPreferences() {
    if (kIsWeb) return true;
    // Solo evaluar Platform si NO estamos en web
    try {
      return Platform.isMacOS;
    } catch (e) {
      // En web, Platform no está disponible
      return true;
    }
  }

  // Create storage
  final FlutterSecureStorage? storage;

  // Fallback para macOS durante desarrollo
  static SharedPreferences? _prefs;

  static PreferencesService? _instance;

  static Future<PreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = PreferencesService._();

      if (_shouldUseSharedPreferences()) {
        // En web y macOS usamos SharedPreferences
        // Web: Por compatibilidad (usa localStorage internamente)
        // macOS: Para evitar problemas de Keychain en desarrollo
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
    if (_shouldUseSharedPreferences()) {
      return _prefs?.getString(key);
    }
    return storage?.read(key: key);
  }

  Future<bool?> getBool(String key) async {
    if (_shouldUseSharedPreferences()) {
      return _prefs?.getBool(key);
    }
    final value = await storage?.read(key: key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  Future<void> set(String key, String value) async {
    if (_shouldUseSharedPreferences()) {
      await _prefs?.setString(key, value);
    } else {
      await storage?.write(key: key, value: value);
    }
  }

  Future<void> setInt(String key, int value) async {
    if (_shouldUseSharedPreferences()) {
      await _prefs?.setInt(key, value);
    } else {
      await storage?.write(key: key, value: value.toString());
    }
  }

  Future<void> setDouble(String key, double value) async {
    if (_shouldUseSharedPreferences()) {
      await _prefs?.setDouble(key, value);
    } else {
      await storage?.write(key: key, value: value.toString());
    }
  }



  Future<void> setBool(String key, bool value) async {
    if (_shouldUseSharedPreferences()) {
      await _prefs?.setBool(key, value);
    } else {
      await storage?.write(key: key, value: value.toString());
    }
  }

  Future<void> remove(String key) async {
    if (_shouldUseSharedPreferences()) {
      await _prefs?.remove(key);
    } else {
      await storage?.delete(key: key);
    }
  }
}
