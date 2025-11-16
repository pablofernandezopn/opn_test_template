import 'package:freezed_annotation/freezed_annotation.dart';

part 'wp_exception.g.dart';

@JsonSerializable()
class WpException implements Exception {
  WpException({
    required this.status,
    required this.reason,
    required this.errorMsg,
    required this.errorData,
  });

  factory WpException.fromJson(Map<String, dynamic> json) =>
      _$WpExceptionFromJson(json);

  Map<String, dynamic> toJson() => _$WpExceptionToJson(this);

  final int status;
  final String errorMsg;
  final String? reason;
  final String? errorData;

  bool get isInvalidCredentials =>
      status == 403 ||
      reason?.toLowerCase().contains('invalid_credentials') == true;

  bool get isServerError => status >= 500;
}
