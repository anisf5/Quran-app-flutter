import 'track_model.dart';

class PlaylistCategory {
  final String id;
  final String name;
  final List<TrackModel> tracks;

  PlaylistCategory({
    required this.id,
    required this.name,
    required this.tracks,
  });
}
