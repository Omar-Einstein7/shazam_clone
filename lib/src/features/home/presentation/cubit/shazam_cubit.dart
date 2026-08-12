import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_project/src/features/home/data/datasources/audio_local_data_source.dart';
import 'package:flutter_complete_project/src/features/home/domain/entities/song.dart';
import 'package:flutter_complete_project/src/features/home/domain/usecases/recognize_song.dart';
import 'package:flutter_complete_project/src/features/home/presentation/cubit/shazam_state.dart';
import 'package:flutter_complete_project/src/utils/utils.dart';

/// Orchestrates the Shazam-style listening flow.
///
/// - [startListening] requests microphone permission, records audio and keeps
///   the ripples running for the whole [listenDuration] window before emitting
///   a result.
/// - [onRecognized] runs the recognition (through [RecognizeSong]) and emits
///   [ShazamSuccess] (with the saved audio path) or [ShazamError].
/// - [resetListening] returns to the idle state so the user can tap again.
class ShazamCubit extends Cubit<ShazamState> {
  ShazamCubit({
    this.listenDuration = const Duration(seconds: 12),
    RecognizeSong? recognizeSong,
    AudioLocalDataSource? audioDataSource,
  })  : _recognizeSong = recognizeSong,
        _audioDataSource = audioDataSource ?? AudioLocalDataSource.instance,
        super(const ShazamIdle());

  /// How long the ripple waves keep running after a tap (matches the
  /// recording window).
  final Duration listenDuration;

  /// Optional recognizer. When null, a mock result is emitted so the UI can be
  /// tested without a configured AudD token.
  final RecognizeSong? _recognizeSong;

  final AudioLocalDataSource _audioDataSource;

  bool get isRippling => state is ShazamListening;

  /// Starts a recording session and, once the window ends, recognizes.
  Future<void> startListening() async {
    if (state is ShazamListening) return;

    emit(const ShazamListening());

    final result = await _audioDataSource.record(duration: listenDuration);
    if (isClosed) return;

    result.fold(
      (failure) {
        AppLogger.error('Recording failed: ${failure.message}');
        emit(ShazamError(failure.message));
      },
      (audioPath) {
        AppLogger.info('Recording saved at: $audioPath');
        onRecognized(audioPath: audioPath);
      },
    );
  }

  /// Runs the recognition and emits success (with saved audio path) or error.
  Future<void> onRecognized({String? audioPath}) async {
    final recognizeSong = _recognizeSong;
    try {
      final ShazamResult result;
      if (recognizeSong == null) {
        result = const ShazamResult(
          title: 'Mocked Song',
          artist: 'Demo Artist',
        );
      } else {
        final Song song = await recognizeSong(audioPath ?? '');
        result = ShazamResult(
          title: song.title,
          artist: song.artist,
          album: song.album,
          releaseDate: song.releaseDate,
          coverUrl: song.coverUrl,
          label: song.label,
          genres: song.genres,
          duration: song.duration,
          confidence: song.confidence,
          isrc: song.isrc,
          trackUrl: song.trackUrl,
          source: song.source,
        );
      }
      if (isClosed) return;
      emit(ShazamSuccess(result.copyWith(audioPath: audioPath)));
    } catch (error) {
      if (isClosed) return;
      AppLogger.error('Recognition failed: $error');
      emit(
        ShazamError(
          error is Failure
              ? error.message
              : 'No song could be recognized. Please try again.',
        ),
      );
    }
  }

  /// Returns to the idle state so the user can tap again.
  void resetListening() {
    if (isClosed) return;
    emit(const ShazamIdle());
  }
}