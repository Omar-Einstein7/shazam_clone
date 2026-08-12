import 'package:flutter_complete_project/src/features/home/data/model/song_model.dart';
import 'package:flutter_complete_project/src/utils/utils.dart';

/// A recognition backend that can turn a recorded audio file into a [SongModel].
///
/// Implementations should return a `Right` when a song was recognized and a
/// `Left(Failure)` when the provider could not identify anything (so the caller
/// can fall back to the next provider).
abstract class SongProvider {
  FutureEither<SongModel> recognizeSong(String audioPath);
}