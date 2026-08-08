import 'package:flutter_complete_project/src/features/home/presentation/cubit/shazam_cubit.dart';
import 'package:get_it/get_it.dart';

/// Registers the home feature dependencies (cubits, services).
Future<void> configureHomeModule() async {
  final getIt = GetIt.instance;

  getIt.registerLazySingleton<ShazamCubit>(
    () => ShazamCubit(),
  );
}