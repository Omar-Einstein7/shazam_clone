import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_complete_project/src/features/home/presentation/cubit/shazam_state.dart';

/// Orchestrates the Shazam-style listening flow.
///
/// - [startListening]: transitions to [ShazamListening] and keeps the ripples
///   running for the whole [listenDuration] window before emitting a result.
/// - [onRecognized]: performs the mock recognition and emits [ShazamSuccess]
///   or [ShazamError]. Override in tests.
/// - [reset]: returns to the idle state so the user can tap again.
class ShazamCubit extends Cubit<ShazamState> {
  ShazamCubit({
    this.listenDuration = const Duration(seconds: 10),
    Future<ShazamResult> Function()? recognition,
  })  : _recognition =
            recognition ?? _defaultRecognition,
        super(const ShazamIdle());

  /// How long the ripple waves keep running after a tap.
  final Duration listenDuration;

  final Future<ShazamResult> Function() _recognition;

  Timer? _timer;

  bool get isRippling => state is ShazamListening;

  /// Starts the ripple window and, once it ends, runs the recognition.
  void startListening() {
    if (state is ShazamListening) return;
    _timer?.cancel();

    emit(const ShazamListening());

    _timer = Timer(listenDuration, () => onRecognized());
  }

  /// Runs [recognition] and emits success (with result) or error.
  Future<void> onRecognized() async {
    try {
      final result = await _recognition();
      if (isClosed) return;
      emit(ShazamSuccess(result));
    } catch (_) {
      if (isClosed) return;
      emit(
        const ShazamError(
          'No song could be recognized. Please try again.',
        ),
      );
    }
  }

  /// Simulated recognition: honors [mockSucceeds] for a demo success.
  static Future<ShazamResult> _defaultRecognition() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return ShazamResult(
      title: kIsWeb ? 'URL' : 'Mocked Song',
      artist: 'Demo Artist',
    );
  }

  void resetListening() {
    _timer?.cancel();
    if (isClosed) return;
    emit(const ShazamIdle());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}