import 'package:package_info_plus/package_info_plus.dart';

class ApplicationConfig {
  static double currentVersion = 1.0;
}

getInfo() {
  PackageInfo packageInfo = PackageInfo.fromPlatform() as PackageInfo;
  String version = packageInfo.version;
  String code = packageInfo.buildNumber;
}
