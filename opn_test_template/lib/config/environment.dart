/// Enum that describe environment type
library;
// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:opn_test_template/config/app_texts.dart';

enum BuildVariant { development, staging, production }

class Environment {
  Environment._internal(BuildVariant buildVariant) {
    _buildVariant = buildVariant;
    _appName = AppTexts.appName; // Nombre de la app
    _supportEmail = 'hola@${AppTexts.domain}';
    _termsUrl = 'https://${AppTexts.domain}/aviso-legal/';

    switch (_buildVariant) {
      case BuildVariant.development:
      // 🔧 Configuración LOCAL de Supabase para desarrollo
      // Edge Functions están corriendo localmente
      const localIp = String.fromEnvironment(
        'LOCAL_IP',
        defaultValue: '127.0.0.1',
      );

      final baseIp = Platform.isAndroid && localIp == '127.0.0.1'
          ? '10.0.2.2'
          : localIp;

      _supabaseUrl = 'http://$baseIp:54321';
      _supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

      _s3AccessKey = '625729a08b95bf1b7ff351a663f3a23c';
      _s3SecretKey = '850181e4652dd023b7a98c58ae0d2d34bd487ee0cc3254aed6eda37307425907';
      _s3Region = 'local';
      _storageUrl = 'http://$baseIp:54321/storage/v1/s3';
      _graphqlUrl = 'http://$baseIp:54321/graphql/v1';
      _databaseUrl = 'postgresql://postgres:postgres@$baseIp:54322/postgres';
        break;

      case BuildVariant.staging:
      case BuildVariant.production:
      // 🚀 Configuración de Supabase en producción
      // ⚠️ DEPRECADO: Mover a FlavorConfig
      // Estas credenciales son del flavor guardia_civil y deben moverse a flavors/guardia_civil/config.json
        _supabaseUrl = 'https://YOUR_SUPABASE_PROJECT.supabase.co';
        _supabaseKey = 'YOUR_SUPABASE_ANON_KEY';

        // Las credenciales de S3 y otros servicios se configuran según producción
        _s3AccessKey = null;
        _s3SecretKey = null;
        _s3Region = null;
        _storageUrl = null;
        _graphqlUrl = null;
        _databaseUrl = null;
        break;
    }
  }

  factory Environment.init(BuildVariant buildVariant) {
    _instance = Environment._internal(buildVariant);
    return _instance!;
  }

  late final BuildVariant _buildVariant;
  BuildVariant get buildVariant => _buildVariant;

  late String _appName;
  String get appName => _appName;

  late String _termsUrl;
  String get termsUrl => _termsUrl;

  late String _supportEmail;
  String get supportEmail => _supportEmail;

  late String _supabaseUrl;
  String get supabaseUrl => _supabaseUrl;

  late String _supabaseKey;
  String get supabaseKey => _supabaseKey;

  // 🆕 Propiedades para configuración local
  late String? _s3AccessKey;
  String? get s3AccessKey => _s3AccessKey;

  late String? _s3SecretKey;
  String? get s3SecretKey => _s3SecretKey;

  late String? _s3Region;
  String? get s3Region => _s3Region;

  late String? _storageUrl;
  String? get storageUrl => _storageUrl;

  late String? _graphqlUrl;
  String? get graphqlUrl => _graphqlUrl;

  late String? _databaseUrl;
  String? get databaseUrl => _databaseUrl;

  static Environment? _instance;

  static Environment get instance {
    if (_instance == null) {
      throw Exception('You should init Environment before get instance');
    }
    return _instance!;
  }

  // 🛠️ Helper para saber si estamos en modo local
  bool get isLocal => _buildVariant == BuildVariant.development;

  // 📊 Helper para obtener información del entorno actual
  String get environmentName {
    switch (_buildVariant) {
      case BuildVariant.development:
        return 'Development (Local)';
      case BuildVariant.staging:
        return 'Staging';
      case BuildVariant.production:
        return 'Production';
    }
  }

  // 🔍 Helper para debugging de conexión
  void logConnectionInfo() {
    if (kDebugMode) {
      print('');
      print('🌐 ===== Supabase Connection Info =====');
      print('   Environment: $environmentName');
      print('   URL: $supabaseUrl');
      print('   Platform: ${Platform.operatingSystem}');
      print('   Is Local: $isLocal');
      if (isLocal) {
        print('   Storage URL: $_storageUrl');
        print('   GraphQL URL: $_graphqlUrl');
        print('');
        print('   💡 Tips:');
        print('      - Emulador Android: Usa 10.0.2.2 (automático)');
        print('      - Simulador iOS: Usa 127.0.0.1 (automático)');
        print('      - Dispositivo físico: Ejecuta con');
        print('        flutter run --dart-define=LOCAL_IP=TU_IP_LOCAL');
        print('');
        print('   🔧 Para encontrar tu IP local:');
        print('      Windows: ipconfig');
        print('      Mac/Linux: ifconfig | grep inet');
      }
      print('=====================================');
      print('');
    }
  }
}