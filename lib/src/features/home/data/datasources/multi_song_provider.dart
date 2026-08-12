import 'package:flutter_complete_project/src/features/home/data/datasources/song_providers.dart';
import 'package:flutter_complete_project/src/features/home/data/model/song_model.dart';
import 'package:flutter_complete_project/src/utils/utils.dart';
import 'package:fpdart/fpdart.dart';

/// Tries each [SongProvider] in order and returns the first successful match.
///
/// If every provider fails to identify the clip, returns a [Failure] with a
/// generic "not recognized" message so the UI shows the standard error dialog
/// instead of leaking provider-specific config errors.
class MultiSongProvider implements SongProvider {
  MultiSongProvider({required List<SongProvider> providers})
      : _providers = List.unmodifiable(providers);

  final List<SongProvider> _providers;

  @override
  FutureEither<SongModel> recognizeSong(String audioPath) async {
    String? lastMessage;

    for (final provider in _providers) {
      final result = await provider.recognizeSong(audioPath);

      final song = result.fold(
        (failure) {
          lastMessage = failure.message;
          return null;
        },
        (model) => model,
      );

      if (song != null) {
        AppLogger.info('Song recognized via ${provider.runtimeType}.');
        return right(song);
      }

      AppLogger.info(
        'Provider ${provider.runtimeType} could not recognize the song; trying next.',
      );
    }

    return left(
      UnknownFailure(
        'No song could be recognized. Please try again.'
        '${lastMessage == null ? '' : ' $lastMessage'}',
      ),
    );
  }
}