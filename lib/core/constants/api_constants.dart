import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized API constants that can be overridden per environment.
abstract final class ApiConstants {
  /// AudD recognition endpoint. Empty token means AudD is not configured yet.
  static String get auddBaseUrl =>
      dotenv.get('AUDD_BASE_URL', fallback: 'https://api.audd.io/');

  static String get auddApiToken => dotenv.get('AUDD_API_TOKEN', fallback: '');

  /// Extra metadata AudD should return alongside the match.
  static const String auddReturnFields = 'apple_music,spotify,deezer';

  /// ACRCloud identification endpoint (region-specific host).
  static String get acrCloudHost =>
      dotenv.get('ACRCLOUD_HOST', fallback: 'https://identify-eu-west-1.acrcloud.com');

  static const String acrCloudIdentifyPath = '/v1/identify';
  static const String acrCloudDataType = 'audio';
  static const String acrCloudSignatureVersion = '1';

  static String get acrCloudAccessKey =>
      dotenv.get('ACRCLOUD_ACCESS_KEY', fallback: '');

  static String get acrCloudAccessSecret =>
      dotenv.get('ACRCLOUD_ACCESS_SECRET', fallback: '');
}