import 'package:equatable/equatable.dart';

/// A recognized song returned by a successful listening session.
class ShazamResult extends Equatable {
  const ShazamResult({
    required this.title,
    required this.artist,
  });

  final String title;
  final String artist;

  @override
  List<Object?> get props => [title, artist];
}

/// The lifecycle states of the "listening" flow.
///
/// - [ShazamIdle]      — button waiting, no ripples.
/// - [ShazamListening] — ripples running for the full listening window.
/// - [ShazamSuccess]   — a song was recognized, navigates to its details.
/// - [ShazamError]     — window ended without a result, shows an error dialog.
sealed class ShazamState extends Equatable {
  const ShazamState();

  @override
  List<Object?> get props => [];
}

class ShazamIdle extends ShazamState {
  const ShazamIdle();

  @override
  List<Object?> get props => [];
}

class ShazamListening extends ShazamState {
  const ShazamListening();

  @override
  List<Object?> get props => [];
}

class ShazamSuccess extends ShazamState {
  const ShazamSuccess(this.result);

  final ShazamResult result;

  @override
  List<Object?> get props => [result];
}

class ShazamError extends ShazamState {
  const ShazamError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}