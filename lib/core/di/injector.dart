import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'modules/network_module.dart';
import 'modules/storage_module.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<Logger>(() => Logger());

  await configureNetworkModule();

  await configureStorageModule();
}
