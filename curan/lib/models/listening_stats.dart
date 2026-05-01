class ListeningStats {
  final Duration totalListeningTime;
  final Map<String, Duration> monthlyListening;
  final List<TrackPlayCount> topTracks;

  ListeningStats({
    required this.totalListeningTime,
    required this.monthlyListening,
    required this.topTracks,
  });

  factory ListeningStats.empty() {
    return ListeningStats(
      totalListeningTime: Duration.zero,
      monthlyListening: {},
      topTracks: [],
    );
  }

  ListeningStats copyWith({
    Duration? totalListeningTime,
    Map<String, Duration>? monthlyListening,
    List<TrackPlayCount>? topTracks,
  }) {
    return ListeningStats(
      totalListeningTime: totalListeningTime ?? this.totalListeningTime,
      monthlyListening: monthlyListening ?? this.monthlyListening,
      topTracks: topTracks ?? this.topTracks,
    );
  }
}

class TrackPlayCount {
  final String trackId;
  final String trackTitle;
  final int playCount;
  final Duration totalListened;

  TrackPlayCount({
    required this.trackId,
    required this.trackTitle,
    required this.playCount,
    required this.totalListened,
  });

  Map<String, dynamic> toMap() {
    return {
      'trackId': trackId,
      'trackTitle': trackTitle,
      'playCount': playCount,
      'totalListened': totalListened.inSeconds,
    };
  }

  factory TrackPlayCount.fromMap(Map<String, dynamic> map) {
    return TrackPlayCount(
      trackId: map['trackId'] as String,
      trackTitle: map['trackTitle'] as String,
      playCount: map['playCount'] as int,
      totalListened: Duration(seconds: map['totalListened'] as int),
    );
  }
}
