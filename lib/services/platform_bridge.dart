static Future<String?> getStreamUrl({
    required String trackName,
    required String artistName,
  }) async {
    try {
      final result = await _channel.invokeMethod('getStreamUrl', {
        'query': '$trackName $artistName',
      });
      return result as String?;
    } catch (e) {
      _log.e('Failed to get stream URL: $e');
      return null;
    }
  }
