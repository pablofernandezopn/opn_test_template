


class DeviceInfoModel {

  DeviceInfoModel({
    this.numberVersion,
    this.buildNumber,
    this.deprecated = false,
    this.newsMessage,
    this.active = false,
  });

  // Factory constructor to create an instance from JSON
  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return DeviceInfoModel(
      numberVersion: json['version'] as String?,
      buildNumber: json['build_number'] as String?,
      newsMessage: json['news_message'] as String? ,
      active: json['active'] as bool? ?? false,
    );
  }
  final String? numberVersion;
  final String? buildNumber;
  final bool deprecated;
  final String? newsMessage;
  final bool? active;


  // Method to copy an instance
  DeviceInfoModel copyWith({
    String? numberVersion,
    String? buildNumber,
    bool? deprecated,
    String? newsMessage,
  }) {
    return DeviceInfoModel(
      numberVersion: numberVersion ?? this.numberVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      deprecated: deprecated ?? this.deprecated,
      newsMessage: newsMessage ?? this.newsMessage,

    );
  }
}