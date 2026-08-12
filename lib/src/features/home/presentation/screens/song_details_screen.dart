import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_complete_project/src/features/home/presentation/cubit/shazam_state.dart';
import 'package:flutter_complete_project/src/shared/widgets/neumorphic.dart';
import 'package:url_launcher/url_launcher.dart';

/// Details screen for a recognized song, shown after a successful session.
///
/// Matches the home screen's blue gradient
/// (#008EFF → #006AFF → #004EFF) and layers a fresh Neumorphic treatment on
/// top: frosted blue surfaces with tinted light/dark soft shadows.
class SongDetailsScreen extends StatelessWidget {
  const SongDetailsScreen({super.key, required this.result});

  final ShazamResult result;

  static const _surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF008EFF),
      Color(0xFF006AFF),
      Color(0xFF004EFF),
    ],
  );

  static const _glassColor = Color(0x29FFFFFF); // white at ~16%
  static const _shadowLight = Color(0x99FFFFFF); // white at ~60%
  static const _shadowDark = Color(0x7A0039B8); // deep blue at ~48%
  static const _accentColor = Color(0xFF22C55E);
  static const _textColor = Color(0xFFFFFFFF);
  static const _mutedTextColor = Color(0xB3FFFFFF); // white at ~70%

  Future<void> _openTrackUrl(BuildContext context) async {
    final url = result.trackUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the track link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        
        
        elevation: 0,
        flexibleSpace: const FlexibleSpaceBar(
          background: DecoratedBox(
            decoration: BoxDecoration(gradient: _surfaceGradient),
          ),
        ),
        foregroundColor: _textColor,
        title: const Text(
          'Song Details',
          style: TextStyle(
            color: _textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _surfaceGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _BuildArtwork(result: result),
              const SizedBox(height: 36),
              Text(
                result.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.artist,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              _BuildActionRow(
                result: result,
                onListen: () => _openTrackUrl(context),
              ),
              const SizedBox(height: 32),
              _BuildInfoPanel(result: result),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Raised neumorphic disc holding the artwork, with a music-note fallback.
class _BuildArtwork extends StatelessWidget {
  const _BuildArtwork({required this.result});

  final ShazamResult result;

  @override
  Widget build(BuildContext context) {
    const size = 200.0;
    final url = result.coverUrl;

    final Widget artwork;
    if (url == null || url.isEmpty) {
      artwork = const Icon(
        Icons.music_note_rounded,
        color: Colors.white70,
        size: 80,
      );
    } else {
      artwork = ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, _) => const Icon(
            Icons.music_note_rounded,
            color: Colors.white54,
            size: 72,
          ),
          errorWidget: (context, _, error) => const Icon(
            Icons.music_note_rounded,
            color: Colors.white70,
            size: 72,
          ),
        ),
      );
    }

    return NeumorphicCircle(
      raised: true,
      size: size + 28,
      color: SongDetailsScreen._glassColor,
      shadowLight: SongDetailsScreen._shadowLight,
      shadowDark: SongDetailsScreen._shadowDark,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: artwork,
      ),
    );
  }
}

/// Play button (raised) + back button (inset) sitting side by side.
class _BuildActionRow extends StatelessWidget {
  const _BuildActionRow({required this.result, required this.onListen});

  final ShazamResult result;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NeumorphicCircle(
          size: 76,
          raised: true,
          color: SongDetailsScreen._glassColor,
          shadowLight: SongDetailsScreen._shadowLight,
          shadowDark: SongDetailsScreen._shadowDark,
          child: IconButton(
            onPressed: onListen,
            iconSize: 34,
            tooltip: 'Listen to this track',
            icon: const Icon(
              Icons.play_arrow_rounded,
              color: SongDetailsScreen._accentColor,
            ),
          ),
        ),
        const SizedBox(width: 28),
        NeumorphicCircle(
          size: 76,
          raised: false,
          color: SongDetailsScreen._glassColor,
          shadowLight: SongDetailsScreen._shadowLight,
          shadowDark: SongDetailsScreen._shadowDark,
          child: IconButton(
            onPressed: () {
              final sc = context.findAncestorStateOfType<NavigatorState>();
              sc?.maybePop();
            },
            iconSize: 30,
            tooltip: 'Go back',
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Inset (debossed) panel showing every bit of metadata the provider returned.
class _BuildInfoPanel extends StatelessWidget {
  const _BuildInfoPanel({required this.result});

  final ShazamResult result;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String)>[
      if (result.album != null) ('Album', result.album!),
      if (result.releaseDate != null) ('Released', result.releaseDate!),
      if (result.label != null) ('Label', result.label!),
      if (result.duration > Duration.zero) ('Length', result.durationLabel),
      if (result.confidence != null)
        ('Match', '${result.confidence!.toStringAsFixed(1)}%'),
      if (result.isrc != null) ('ISRC', result.isrc!),
      if (result.source != null) ('Source', result.source!),
      if (result.genres.isNotEmpty)
        ('Genres', result.genres.map((g) => g.trim()).where((g) => g.isNotEmpty).join(' · ')),
    ];

    if (entries.isEmpty) return const SizedBox.shrink();

    return NeumorphicBox(
      raised: false,
      radius: 24,
      padding: const EdgeInsets.all(20),
      color: SongDetailsScreen._glassColor,
      shadowLight: SongDetailsScreen._shadowLight,
      shadowDark: SongDetailsScreen._shadowDark,
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 20,
                color: Colors.white12,
                thickness: 1,
              ),
            _InfoRow(label: entries[i].$1, value: entries[i].$2),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: SongDetailsScreen._mutedTextColor,
              fontSize: 13,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: const TextStyle(
              color: SongDetailsScreen._textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}