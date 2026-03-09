import 'package:just_audio/just_audio.dart';
import 'package:spotiflac_android/services/platform_bridge.dart';

// ... existing imports ...

class PlaybackController extends Notifier<PlaybackState> {
  // 1. Initialize the audio player
  final AudioPlayer _player = AudioPlayer();

  @override
  PlaybackState build() => const PlaybackState();

  Future<void> playTrackList(List<Track> tracks, {int startIndex = 0}) async {
    if (tracks.isEmpty) return;

    final orderedTracks = _orderedTracksFromStartIndex(tracks, startIndex);
    final track = orderedTracks.first;

    // 2. Check for offline file first
    final resolvedPath = await _resolveTrackPath(track);
    
    if (resolvedPath != null) {
      _log.d('Playing offline file: $resolvedPath');
      await _player.setFilePath(resolvedPath);
      _player.play();
      return;
    }

    // 3. NEW: If no offline file, stream it online!
    _log.d('Local file not found. Fetching online stream for: "${track.name}"');
    
    try {
      // We will create this method in PlatformBridge next
      final streamUrl = await PlatformBridge.getStreamUrl(
        trackName: track.name, 
        artistName: track.artistName,
      );

      if (streamUrl != null && streamUrl.isNotEmpty) {
        await _player.setUrl(streamUrl);
        _player.play();
      } else {
        throw Exception('Could not find online stream URL.');
      }
    } catch (e) {
      _log.e('Streaming failed: $e');
    }
  }
  
  // ... keep existing _resolveTrackPath and other helper methods ...
}
