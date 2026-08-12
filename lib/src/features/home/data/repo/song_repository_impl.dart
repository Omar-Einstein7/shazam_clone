import 'package:flutter_complete_project/src/features/home/data/datasources/song_providers.dart';
import 'package:flutter_complete_project/src/features/home/data/model/song_model.dart';
import 'package:flutter_complete_project/src/features/home/domain/entities/song.dart';
import 'package:flutter_complete_project/src/features/home/domain/repo/song_repository.dart';

/// Recognizes songs through the injected [SongProvider] (typically a
/// [MultiSongProvider] that falls back across AudD / ACRCloud).
class SongRepositoryImpl implements SongRepository {
  SongRepositoryImpl({required SongProvider songProvider})
      : _songProvider = songProvider;

  final SongProvider _songProvider;

  @override
  Future<Song> recognizeSong(String audioPath) async {
    final result = await _songProvider.recognizeSong(audioPath);

    return result.fold(
      (failure) => throw failure,
      (model) => _toEntity(model),
    );
  }

  Song _toEntity(SongModel model) {
    return Song(
      title: model.title,
      artist: model.artist,
      album: model.album,
      releaseDate: model.releaseDate,
      coverUrl: model.coverUrl,
      label: model.label,
      genres: model.genres,
      duration: model.duration,
      confidence: model.confidence,
      isrc: model.isrc,
      trackUrl: model.trackUrl,
      source: model.source,
    );
  }
}