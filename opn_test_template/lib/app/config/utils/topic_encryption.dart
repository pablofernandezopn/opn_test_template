import 'dart:convert';

class TopicEncryption {
  static const _secret = 'opn_template_secret';

  static String encode(int topicId) {
    final payload = '$topicId|$_secret';
    return base64Url.encode(utf8.encode(payload));
  }

  static int? decode(String token) {
    try {
      final decoded = utf8.decode(base64Url.decode(token));
      final parts = decoded.split('|');
      if (parts.length != 2) return null;
      if (parts[1] != _secret) return null;
      return int.tryParse(parts[0]);
    } catch (_) {
      return null;
    }
  }
}
