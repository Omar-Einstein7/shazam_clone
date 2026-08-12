class Song {
  final String title;
  final String artist;
  final String? album;
  final String? releaseDate;
  final String? coverUrl;
  final String? label;
  final List<String> genres;
  final Duration duration;
  final double? confidence;
  final String? isrc;
  final String? trackUrl;
  final String? source;

  const Song({
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
  });
}
