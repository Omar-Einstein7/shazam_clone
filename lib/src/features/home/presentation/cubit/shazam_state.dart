import 'package:equatable/equatable.dart';

/// A recognized song returned by a successful listening session.
class ShazamResult extends Equatable {
  const ShazamResult({
    required this.title,
    required this.artist,
    this.album,
    this.releaseDate,
    this.coverUrl,
    this.label,
    this.genres = const [],
    this.duration = Duration.zero,
    this.confidence,
    this.isrc,
    this.trackUrl,
    this.source,
    this.audioPath,
  });

  final String title;
  final String artist;
  final String? album;
  final String? releaseDate;

  /// Album artwork URL returned by the recognition provider.
  final String? coverUrl;

  /// Record label, when the provider exposes it.
  final String? label;

  /// Genres attached to the recognized track.
  final List<String> genres;

  /// Track length recognized by the provider.
  final Duration duration;

  /// Provider match score (0–100) when available.
  final double? confidence;

  /// International Standard Recording Code, when available.
  final String? isrc;

  /// Primary listen/play link (store or streaming page).
  final String? trackUrl;

  /// Which provider produced this result (AudD / ACRCloud / Custom).
  final String? source;

  /// Total duration formatting helper (e.g. `3:45`), or `—` when unknown.
  String get durationLabel {
    if (duration == Duration.zero) return '—';
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// The file path where the recorded audio clip was saved.
  final String? audioPath;

  ShazamResult copyWith({
    String? title,
    String? artist,
    String? album,
    String? releaseDate,
    String? coverUrl,
    String? label,
    List<String>? genres,
    Duration? duration,
    double? confidence,
    String? isrc,
    String? trackUrl,
    String? source,
    String? audioPath,
  }) {
    return ShazamResult(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      releaseDate: releaseDate ?? this.releaseDate,
      coverUrl: coverUrl ?? this.coverUrl,
      label: label ?? this.label,
      genres: genres ?? this.genres,
      duration: duration ?? this.duration,
      confidence: confidence ?? this.confidence,
      isrc: isrc ?? this.isrc,
      trackUrl: trackUrl ?? this.trackUrl,
      source: source ?? this.source,
      audioPath: audioPath ?? this.audioPath,
    );
  }

  @override
  List<Object?> get props => [
        title,
        artist,
        album,
        releaseDate,
        coverUrl,
        label,
        genres,
        duration,
        confidence,
        isrc,
        trackUrl,
        source,
        audioPath,
      ];
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