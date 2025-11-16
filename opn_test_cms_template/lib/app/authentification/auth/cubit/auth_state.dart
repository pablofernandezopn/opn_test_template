import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import '../model/device_info.dart';
import '../model/user.dart';

part 'auth_state.freezed.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  appAccessError,
}

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    required AuthStatus status,
    @Default(CmsUser.empty) CmsUser user,
    CustomerInfo? purchaseInfo,
    @Default('') String token,
    @Default('') String refreshToken,
    @Default(null) Uri? uri,
    @Default(null) DeviceInfoModel? deviceInfo,
  }) = _AuthState;

  const AuthState._();
}
