import 'package:flutter_complete_project/src/features/home/domain/entities/song.dart';
import 'package:flutter_complete_project/src/features/home/domain/repo/song_repository.dart';

/// Use case: recognize the song contained in a recorded audio file.
class RecognizeSong {
  RecognizeSong({required SongRepository repository})
      : _repository = repository;

  final SongRepository _repository;

  Future<Song> call(String audioPath) => _repository.recognizeSong(audioPath);
}