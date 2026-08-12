/// A recognized song with the metadata returned by a recognition provider
/// (AudD / ACRCloud). Fields are best-effort: providers expose different
/// subsets, so most optional fields may be null.
class SongModel {
  const SongModel({
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

  final String title;
  final String artist;
  final String? album;
  final String? releaseDate;

  /// Best-available album artwork URL (apple_music/deezer/spotify artwork).
  final String? coverUrl;

  /// Record label, when the provider exposes it.
  final String? label;

  /// Genres attached to the track (AudD `apple_music.genres`, ACRCloud
  /// `genres`/`external_metadata`).
  final List<String> genres;

  /// Track length. ACRCloud returns `duration_ms`; AudD exposes it indirectly
  /// through provider keys, so it can be zero when unknown.
  final Duration duration;

  /// Provider match score (0–100). ACRCloud (`score`), AudD may omit it.
  final double? confidence;

  /// International Standard Recording Code, when available.
  final String? isrc;

  /// Total duration formatting helper.
  String get durationLabel {
    if (duration == Duration.zero) return '—';
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Primary link to play/listen to the track (store page or stream URL).
  final String? trackUrl;

  /// Which provider produced this result (AudD / ACRCloud / Custom).
  final String? source;

  /// Parses the AudD `result` object (AudD exposes `apple_music.genres`,
  /// `label`, `isrc`, and `tracks`/`url` style info in provider blocks).
  factory SongModel.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as String?) ?? 'Unknown Title';
    final artist = (json['artist'] as String?) ?? 'Unknown Artist';
    final album = json['album'] as String?;
    final releaseDate = json['release_date'] as String?;
    final label = json['label'] as String?;
    final isrc = json['isrc'] as String? ?? json['ISRC'] as String?;

    final appleMusic = json['apple_music'] as Map<String, dynamic>?;
    final deezer = json['deezer'] as Map<String, dynamic>?;
    final spotify = json['spotify'] as Map<String, dynamic>?;

    String? coverUrl;
    if (appleMusic != null) {
      final artworkUrl =
          ((appleMusic['artwork'] as Map<String, dynamic>?)?['url'] as String?) ?? '';
      // Replace {w}/{h} placeholders returned by AudD artwork.
      coverUrl = artworkUrl
          .replaceAll('{w}', '600')
          .replaceAll('{h}', '600');
    }
    coverUrl ??= (deezer?['album'] as Map<String, dynamic>?)?['cover_xl']
            as String? ??
        (deezer?['cover_xl'] as String?);
    coverUrl ??= (spotify?['album'] as Map<String, dynamic>?)?['images']
            is List &&
        ((spotify?['album'] as Map<String, dynamic>?)!['images'] as List)
            .isNotEmpty
        ? (((spotify?['album'] as Map<String, dynamic>?)!['images'] as List)
                .first as Map<String, dynamic>)['url'] as String?
        : null;

    // Genres arrive as a flat list under apple_music.
    List<String> genres = [];
    final rawGenres = appleMusic?['genres'];
    if (rawGenres is List) {
      genres = rawGenres.whereType<String>().toList();
    } else if (rawGenres is String && rawGenres.isNotEmpty) {
      genres = [rawGenres];
    }

    // Duration can be found in the Deezer keys (seconds) or Apple dictionary.
    Duration duration = Duration.zero;
    final deezerDuration = deezer?['duration'];
    final seconds = deezerDuration is num ? deezerDuration.toInt() : null;
    if (seconds != null && seconds > 0) {
      duration = Duration(seconds: seconds);
    }

    // AudD `result` has no single canonical "listen" URL; fall back to the
    // metalink / Deezer link / Apple URL.
    String? trackUrl =
        (json['song_link'] as String?) ??
        (json['url'] as String?) ??
        (deezer?['link'] as String?) ??
        ((deezer?['share'] as Map<String, dynamic>?)?['link'] as String?);
    if (trackUrl == null && appleMusic?['url'] is String) {
      trackUrl = appleMusic!['url'] as String;
    }

    return SongModel(
      title: title,
      artist: artist,
      album: album,
      releaseDate: releaseDate,
      coverUrl: coverUrl,
      label: label,
      genres: genres,
      duration: duration,
      isrc: isrc,
      trackUrl: trackUrl,
      source: 'AudD',
    );
  }

  /// Parses the `metadata.music[0]` item returned by the ACRCloud
  /// Identification API.
  factory SongModel.fromAcrCloudJson(Map<String, dynamic> json) {
    final title = (json['title'] as String?) ?? 'Unknown Title';
    final artistNames = (json['artists'] as List<dynamic>?)
            ?.map((a) {
              if (a is Map<String, dynamic>) return a['name'] as String? ?? '';
              return a?.toString() ?? '';
            })
            .where((name) => name.isNotEmpty)
            .toList() ??
        [];
    final artist = artistNames.isEmpty ? 'Unknown Artist' : artistNames.join(', ');
    final album = (json['album'] as Map<String, dynamic>?)?['name'] as String?;
    final releaseDate = json['release_date'] as String?;

    final external = (json['external_metadata'] as Map<String, dynamic>?) ?? {};
    final apple = (external['apple'] as Map<String, dynamic>?)?['artwork']
            as Map<String, dynamic>?;
    final spotifyImages =
        ((external['spotify'] as Map<String, dynamic>?)?['album']
            as Map<String, dynamic>?)?['images'] as List?;

    String? coverUrl;
    if (apple?['url'] is String) {
      coverUrl = (apple!['url'] as String)
          .replaceAll('{w}', '600')
          .replaceAll('{h}', '600');
    }
    if ((coverUrl == null || coverUrl.isEmpty) &&
        spotifyImages != null &&
        spotifyImages.isNotEmpty &&
        spotifyImages.first is Map<String, dynamic>) {
      coverUrl = (spotifyImages.first as Map<String, dynamic>)['url'] as String?;
    }

    // Genres: ACRCloud can return a flat array or a `music_genres` list of
    // maps with a `genre` key.
    List<String> genres = [];
    final rawGenres = json['genres'];
    if (rawGenres is List) {
      genres = rawGenres.map((g) {
        if (g is Map<String, dynamic>) return g['name'] as String? ?? '';
        return g?.toString() ?? '';
      }).where((name) => name.isNotEmpty).toList();
    } else if (json['music_genres'] is List) {
      genres = (json['music_genres'] as List)
          .map((g) => g is Map<String, dynamic> ? g['genre'] as String? ?? '' : '')
          .where((name) => name.isNotEmpty)
          .toList();
    } else if (rawGenres is String && rawGenres.isNotEmpty) {
      genres = [rawGenres];
    }

    // ACRCloud `score` is a percentage (e.g. 88.5).
    final rawScore = json['score'];
    final confidence =
        rawScore is num ? rawScore.toDouble() : rawScore is String ? double.tryParse(rawScore) : null;

    // Duration: `duration_ms` (v1) or `duration_in_milliseconds`.
    Duration duration = Duration.zero;
    final rawMs = json['duration_ms'] ?? json['duration_in_milliseconds'];
    if (rawMs is num && rawMs > 0) {
      duration = Duration(milliseconds: rawMs.toInt());
    } else if (json['duration'] is num) {
      duration = Duration(milliseconds: (json['duration'] as num).toInt());
    }

    // Listen link: prefer Spotify track URL, then Deezer, then Apple.
    String? trackUrl;
    final externalSpotify = external['spotify'] as Map<String, dynamic>?;
    final externalDeezer = external['deezer'] as Map<String, dynamic>?;
    if (externalSpotify?['track'] is Map<String, dynamic>) {
      final t = externalSpotify!['track'] as Map<String, dynamic>;
      trackUrl = t['url'] as String?;
    }
    trackUrl ??= (externalSpotify?['track'] as Map<String, dynamic>?)?['id'] is String
        ? 'https://open.spotify.com/track/${(externalSpotify!['track'] as Map<String, dynamic>)['id']}'
        : null;
    trackUrl ??= (externalDeezer?['track'] as Map<String, dynamic>?)?['id'] is num
        ? 'https://www.deezer.com/track/${(externalDeezer!['track'] as Map<String, dynamic>)['id']}'
        : null;
    if (trackUrl == null && external['apple'] is Map<String, dynamic>) {
      trackUrl = (external['apple'] as Map<String, dynamic>)['url'] as String?;
    }
    if (trackUrl == null && external['youtube'] is Map<String, dynamic>) {
      trackUrl = (external['youtube'] as Map<String, dynamic>)['url'] as String?;
    }

    return SongModel(
      title: title,
      artist: artist,
      album: album,
      releaseDate: releaseDate,
      coverUrl: coverUrl,
      label: json['label'] as String?,
      genres: genres,
      duration: duration,
      confidence: confidence,
      isrc: json['isrc'] as String?,
      trackUrl: trackUrl,
      source: 'ACRCloud',
    );
  }

  /// Parses an item of the `metadata.custom_files` array returned by the
  /// ACRCloud Identification API (content matching against a bucket you
  /// uploaded yourself). Custom metadata keys are defined by you in the
  /// ACRCloud console, so artist/album/artwork are matched by common names.
  factory SongModel.fromAcrCloudCustomFile(Map<String, dynamic> json) {
    final title = (json['title'] as String?) ?? 'Unknown Title';

    String artist = 'Unknown Artist';
    String? album;
    String? coverUrl;
    String? releaseDate;

    json.forEach((key, value) {
      if (value is! String || value.isEmpty) return;
      final lowerKey = key.toLowerCase();
      if (artist == 'Unknown Artist' &&
          (lowerKey.contains('artist') || lowerKey.contains('singer'))) {
        artist = value;
      }
      if (album == null &&
          (lowerKey == 'album' || lowerKey.contains('album_name'))) {
        album = value;
      }
      if (releaseDate == null &&
          (lowerKey == 'release_date' || lowerKey.contains('released'))) {
        releaseDate = value;
      }
      if (coverUrl == null &&
          (lowerKey.contains('cover') ||
              lowerKey.contains('artwork') ||
              lowerKey.contains('image') ||
              lowerKey.contains('img_url'))) {
        coverUrl = value;
      }
    });

    return SongModel(
      title: title,
      artist: artist,
      album: album,
      releaseDate: releaseDate,
      coverUrl: coverUrl,
      source: 'Custom Library',
    );
  }
}