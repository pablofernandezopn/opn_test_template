import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IpService {
  /// Obtiene la IP pública del usuario desde un servicio externo
  static Future<String> getPublicIp() async {
    try {
      // Intentar con ipify (servicio confiable y rápido)
      final response = await http.get(
        Uri.parse('https://api.ipify.org?format=json'),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ip'] as String;
      }
    } catch (e) {
      // Si falla ipify, intentar con otro servicio
      try {
        final response = await http.get(
          Uri.parse('https://api64.ipify.org?format=json'),
        ).timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['ip'] as String;
        }
      } catch (e2) {
        // Si también falla, devolver IP local o desconocida
        return await _getLocalIp();
      }
    }

    return 'unknown';
  }

  /// Obtiene la IP local como fallback
  static Future<String> _getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      if (interfaces.isNotEmpty && interfaces.first.addresses.isNotEmpty) {
        return interfaces.first.addresses.first.address;
      }
    } catch (e) {
      // Ignorar error
    }

    return 'localhost';
  }

  /// Obtiene la IP con un valor por defecto si falla
  static Future<String> getIpOrDefault([String defaultIp = 'unknown']) async {
    try {
      return await getPublicIp();
    } catch (e) {
      return defaultIp;
    }
  }
}