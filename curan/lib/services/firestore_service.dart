import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listening_stats.dart';
import '../models/track_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFavorite(String userId, TrackModel track) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(track.id)
        .set({
      'id': track.id,
      'title': track.title,
      'audioUrl': track.audioUrl,
      'category': track.category,
      'trackNumber': track.trackNumber,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String userId, String trackId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(trackId)
        .delete();
  }

  Stream<List<TrackModel>> getFavoritesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TrackModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future<List<TrackModel>> getFavorites(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return TrackModel.fromMap(doc.data());
    }).toList();
  }

  Future<bool> isFavorite(String userId, String trackId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(trackId)
        .get();

    return doc.exists;
  }

  Future<void> recordListeningTime({
    required String userId,
    required Duration duration,
    required TrackModel track,
  }) async {
    final batch = _firestore.batch();
    final today = _formatDate(DateTime.now());
    final currentMonth = _formatMonth(DateTime.now());

    final statsRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('listening_stats')
        .doc('totals');

    final statsDoc = await statsRef.get();

    if (statsDoc.exists) {
      final data = statsDoc.data()!;
      final currentTotal = data['totalListeningSeconds'] as int? ?? 0;

      batch.update(statsRef, {
        'totalListeningSeconds': currentTotal + duration.inSeconds,
      });

      final dailyData = Map<String, dynamic>.from(data['dailyListening'] ?? {});
      final currentDaily = dailyData[today] as int? ?? 0;
      dailyData[today] = currentDaily + duration.inSeconds;

      batch.update(statsRef, {
        'dailyListening': dailyData,
      });

      final monthlyData =
          Map<String, dynamic>.from(data['monthlyListening'] ?? {});
      final currentMonthly = monthlyData[currentMonth] as int? ?? 0;
      monthlyData[currentMonth] = currentMonthly + duration.inSeconds;

      batch.update(statsRef, {
        'monthlyListening': monthlyData,
      });

      final trackCounts =
          List<Map<String, dynamic>>.from(data['trackPlayCounts'] ?? []);
      final trackIndex =
          trackCounts.indexWhere((t) => t['trackId'] == track.id);

      if (trackIndex != -1) {
        trackCounts[trackIndex]['playCount'] =
            (trackCounts[trackIndex]['playCount'] as int) + 1;
        trackCounts[trackIndex]['totalListened'] =
            (trackCounts[trackIndex]['totalListened'] as int) +
                duration.inSeconds;
      } else {
        trackCounts.add({
          'trackId': track.id,
          'trackTitle': track.title,
          'playCount': 1,
          'totalListened': duration.inSeconds,
        });
      }

      batch.update(statsRef, {
        'trackPlayCounts': trackCounts,
      });
    } else {
      batch.set(statsRef, {
        'totalListeningSeconds': duration.inSeconds,
        'dailyListening': {today: duration.inSeconds},
        'monthlyListening': {currentMonth: duration.inSeconds},
        'trackPlayCounts': [
          {
            'trackId': track.id,
            'trackTitle': track.title,
            'playCount': 1,
            'totalListened': duration.inSeconds,
          }
        ],
      });
    }

    await batch.commit();
  }

  Future<ListeningStats> getListeningStats(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('listening_stats')
        .doc('totals')
        .get();

    if (!doc.exists) {
      return ListeningStats.empty();
    }

    final data = doc.data()!;

    final totalSeconds = data['totalListeningSeconds'] as int? ?? 0;
    final dailyData = Map<String, dynamic>.from(data['dailyListening'] ?? {});
    final trackCounts =
        List<Map<String, dynamic>>.from(data['trackPlayCounts'] ?? []);

    final monthlyMap = <String, Duration>{};
    for (final entry in dailyData.entries) {
      final date = DateTime.tryParse(entry.key);
      if (date != null) {
        final monthKey = _formatMonth(date);
        final current = monthlyMap[monthKey]?.inSeconds ?? 0;
        monthlyMap[monthKey] =
            Duration(seconds: current + (entry.value as int));
      }
    }

    final topTracks = trackCounts
        .map((t) => TrackPlayCount.fromMap(t))
        .toList()
      ..sort((a, b) => b.totalListened.compareTo(a.totalListened));

    return ListeningStats(
      totalListeningTime: Duration(seconds: totalSeconds),
      monthlyListening: monthlyMap,
      topTracks: topTracks.take(10).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatMonth(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }
}
