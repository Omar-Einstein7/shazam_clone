import 'package:flutter_complete_project/src/features/home/data/datasources/acrcloud_provider.dart';
import 'package:flutter_complete_project/src/features/home/data/datasources/audio_local_data_source.dart';
import 'package:flutter_complete_project/src/features/home/data/datasources/multi_song_provider.dart';
import 'package:flutter_complete_project/src/features/home/data/datasources/song_providers.dart';
import 'package:flutter_complete_project/src/features/home/data/datasources/song_remote_data_source.dart';
import 'package:flutter_complete_project/src/features/home/data/repo/song_repository_impl.dart';
import 'package:flutter_complete_project/src/features/home/domain/repo/song_repository.dart';
import 'package:flutter_complete_project/src/features/home/domain/usecases/recognize_song.dart';
import 'package:flutter_complete_project/src/features/home/presentation/cubit/shazam_cubit.dart';
import 'package:get_it/get_it.dart';

/// Registers the home feature dependencies (cubits, services).
Future<void> configureHomeModule() async {
  final getIt = GetIt.instance;

  getIt.registerLazySingleton<AudioLocalDataSource>(
    () => AudioLocalDataSource.instance,
  );

  // Recognition providers, tried in order. ACRCloud covers regional (incl.
  // Arabic) catalog and your uploaded custom bucket; AudD is the fallback for
  // the global catalog.
  getIt.registerLazySingleton<SongProvider>(
    () => MultiSongProvider(
      providers: [
        AcrCloudProvider.instance,
        SongRemoteDataSource.instance,
      ],
    ),
  );

  getIt.registerLazySingleton<SongRepository>(
    () => SongRepositoryImpl(songProvider: getIt<SongProvider>()),
  );

  getIt.registerLazySingleton<RecognizeSong>(
    () => RecognizeSong(repository: getIt<SongRepository>()),
  );

  getIt.registerLazySingleton<ShazamCubit>(
    () => ShazamCubit(
      audioDataSource: getIt<AudioLocalDataSource>(),
      recognizeSong: getIt<RecognizeSong>(),
    ),
  );
}