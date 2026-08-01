import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_complete_project/src/services/internet_connection_service.dart';
import 'package:flutter_complete_project/src/services/dio_service.dart';

Future<void> configureNetworkModule() async {
  final getIt = GetIt.instance;

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: '',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
    ));
    return dio;
  });

  getIt.registerLazySingleton<InternetConnectionService>(
    () => InternetConnectionService(),
  );

  getIt.registerLazySingleton<DioService>(
    () => DioService.instance,
  );
}
