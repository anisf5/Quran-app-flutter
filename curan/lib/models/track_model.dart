class TrackModel {
  final String id;
  final String title;
  final String audioUrl;
  final String? category;
  final Duration? duration;
  final int? trackNumber;

  TrackModel({
    required this.id,
    required this.title,
    required this.audioUrl,
    this.category,
    this.duration,
    this.trackNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'audioUrl': audioUrl,
      'category': category,
      'duration': duration?.inSeconds,
      'trackNumber': trackNumber,
    };
  }

  factory TrackModel.fromMap(Map<String, dynamic> map) {
    return TrackModel(
      id: map['id'] as String,
      title: map['title'] as String,
      audioUrl: map['audioUrl'] as String,
      category: map['category'] as String?,
      duration: map['duration'] != null
          ? Duration(seconds: map['duration'] as int)
          : null,
      trackNumber: map['trackNumber'] as int?,
    );
  }

  TrackModel copyWith({
    String? id,
    String? title,
    String? audioUrl,
    String? category,
    Duration? duration,
    int? trackNumber,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      trackNumber: trackNumber ?? this.trackNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TrackModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
