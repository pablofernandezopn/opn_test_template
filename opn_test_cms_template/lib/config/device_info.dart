import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:universal_io/io.dart';

bool get isWeb => kIsWeb;

bool get isMobileDevice =>
    (defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android) &&
      !kIsWeb;

bool get isDesktopDevice =>
    !isWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

bool get isMobileDeviceOrWeb => isWeb || isMobileDevice;

bool get isMobileDeviceAndWeb => isWeb && isMobileDevice;

bool get isDesktopDeviceOrWeb => isWeb || isDesktopDevice;

class FormFactor {
  static double desktop = 900;
  static double tablet = 600;
  static double handset = 300;
}

enum ScreenType { desktop, tablet, handset, watch }

ScreenType getFormFactor(BuildContext context) {
  // Use .shortestSide to detect device type regardless of orientation
  final deviceWidth = MediaQuery.of(context).size.width;
  if (deviceWidth > FormFactor.desktop) return ScreenType.desktop;
  if (deviceWidth > FormFactor.tablet) return ScreenType.tablet;
  if (deviceWidth > FormFactor.handset) return ScreenType.handset;
  return ScreenType.watch;
}


double getResponsiveScreenWidth(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if ((kIsWeb || isDesktopDevice) && screenWidth > 800) {
    return 800;
  }

  return screenWidth;
}
