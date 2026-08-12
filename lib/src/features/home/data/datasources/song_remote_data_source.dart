import 'package:dio/dio.dart';
import 'package:flutter_complete_project/core/constants/api_constants.dart';
import 'package:flutter_complete_project/src/features/home/data/datasources/song_providers.dart';
import 'package:flutter_complete_project/src/features/home/data/model/song_model.dart';
import 'package:flutter_complete_project/src/utils/utils.dart';

/// AudD provider: recognizes songs through https://audd.io/.
///
/// AudD covers the global (Western) catalog well but has weaker coverage for
/// Arabic/regional tracks, which is why it sits in front of [AcrCloudProvider]
/// in the provider chain.
class SongRemoteDataSource implements SongProvider {
  SongRemoteDataSource._();
  static final SongRemoteDataSource instance = SongRemoteDataSource._();

  /// Dedicated client — used instead of `AppConfig.dio`, which stays
  /// uninitialized because `AppConfig.init()` is disabled in `main.dart`.
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  @override
  FutureEither<SongModel> recognizeSong(String audioPath) {
    return runTask(() async {
      final token = ApiConstants.auddApiToken;
      if (token.isEmpty || token == 'your-audd-api-token') {
        throw const UnknownFailure(
          'Song recognition is not configured yet. '
          'Add your AudD API token and try again.',
        );
      }

      final formData = FormData.fromMap({
        'api_token': token,
        'return': ApiConstants.auddReturnFields,
        'file': await MultipartFile.fromFile(audioPath),
      });

      final response = await _dio.post(
        ApiConstants.auddBaseUrl,
        data: formData,
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const UnknownFailure('Unexpected response from the server.');
      }

      final status = data['status'];
      final result = data['result'];
      if (status != 'success' || result is! Map<String, dynamic>) {
        final errorMessage =
            (data['error'] as Map<String, dynamic>?)?['error_message'];
        throw UnknownFailure(
          errorMessage?.toString() ??
              'No song could be recognized. Please try again.',
        );
      }

      return SongModel.fromJson(result);
    }, requiresNetwork: true);
  }
}