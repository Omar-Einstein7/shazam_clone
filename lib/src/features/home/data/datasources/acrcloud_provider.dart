import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_complete_project/core/constants/api_constants.dart';
import 'package:flutter_complete_project/src/features/home/data/datasources/song_providers.dart';
import 'package:flutter_complete_project/src/features/home/data/model/song_model.dart';
import 'package:flutter_complete_project/src/utils/utils.dart';

/// ACRCloud provider: recognizes a recorded audio clip via the ACRCloud
/// Identification API (protocol v1).
///
/// ACRCloud's index covers regional (incl. Arabic) catalog much better than
/// AudD, so it is tried first. It also returns matches against any custom
/// bucket you uploaded (see `custom_files` handling below).
class AcrCloudProvider implements SongProvider {
  AcrCloudProvider._();
  static final AcrCloudProvider instance = AcrCloudProvider._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  @override
  FutureEither<SongModel> recognizeSong(String audioPath) {
    return runTask(() async {
      final accessKey = ApiConstants.acrCloudAccessKey;
      final accessSecret = ApiConstants.acrCloudAccessSecret;
      if (accessKey.isEmpty || accessKey == 'your-acrcloud-access-key') {
        throw const UnknownFailure(
          'Song recognition is not configured yet. '
          'Add your ACRCloud credentials and try again.',
        );
      }

      final file = File(audioPath);
      final timestamp =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

      final signature = _signInSignature(
        httpMethod: 'POST',
        httpUri: ApiConstants.acrCloudIdentifyPath,
        accessKey: accessKey,
        accessSecret: accessSecret,
        dataType: ApiConstants.acrCloudDataType,
        signatureVersion: ApiConstants.acrCloudSignatureVersion,
        timestamp: timestamp,
      );

      final formData = FormData.fromMap({
        'sample': await MultipartFile.fromFile(audioPath),
        'sample_bytes': file.lengthSync(),
        'access_key': accessKey,
        'data_type': ApiConstants.acrCloudDataType,
        'signature_version': ApiConstants.acrCloudSignatureVersion,
        'signature': signature,
        'timestamp': timestamp,
      });

      final response = await _dio.post(
        '${ApiConstants.acrCloudHost}${ApiConstants.acrCloudIdentifyPath}',
        data: formData,
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const UnknownFailure('Unexpected response from the server.');
      }

      final status = data['status'] as Map<String, dynamic>?;
      final code = status?['code'];
      if (code != 0) {
        final msg = status?['msg']?.toString();
        throw UnknownFailure(msg ?? 'No song could be recognized.');
      }

      final music = (data['metadata'] as Map<String, dynamic>?)?['music'];
      if (music is List && music.isNotEmpty) {
        final first = music.first;
        if (first is Map<String, dynamic>) {
          return SongModel.fromAcrCloudJson(first);
        }
      }

      final customFiles =
          (data['metadata'] as Map<String, dynamic>?)?['custom_files'];
      if (customFiles is List && customFiles.isNotEmpty) {
        final first = customFiles.first;
        if (first is Map<String, dynamic>) {
          return SongModel.fromAcrCloudCustomFile(first);
        }
      }

      throw const UnknownFailure('No song could be recognized.');
    }, requiresNetwork: true);
  }

  /// Builds the base64 HMAC-SHA1 signature required by ACRCloud protocol v1.
  static String _signInSignature({
    required String httpMethod,
    required String httpUri,
    required String accessKey,
    required String accessSecret,
    required String dataType,
    required String signatureVersion,
    required String timestamp,
  }) {
    final stringToSign =
        '$httpMethod\n$httpUri\n$accessKey\n$dataType\n$signatureVersion\n$timestamp';

    final hmac = Hmac(sha1, utf8.encode(accessSecret));
    final digest = hmac.convert(utf8.encode(stringToSign)).bytes;
    return base64.encode(digest);
  }
}