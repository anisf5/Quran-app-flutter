import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/listening_stats.dart';

class StatsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  ListeningStats _stats = ListeningStats.empty();
  bool _isLoading = false;
  String? _errorMessage;

  ListeningStats get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStats(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _firestoreService.getListeningStats(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load stats';
      notifyListeners();
    }
  }

  Future<void> recordListening({
    required String userId,
    required Duration duration,
    required dynamic track,
  }) async {
    try {
      await _firestoreService.recordListeningTime(
        userId: userId,
        duration: duration,
        track: track,
      );
      // Reload stats after recording
      await loadStats(userId);
    } catch (e) {
      debugPrint('Failed to record listening time: $e');
    }
  }

  double getMonthlyProgress(String userId, double monthlyGoalHours) {
    final currentMonth = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    final monthlyDuration = _stats.monthlyListening[currentMonth] ?? Duration.zero;
    final monthlyHours = monthlyDuration.inMinutes / 60;
    return (monthlyHours / monthlyGoalHours).clamp(0.0, 1.0);
  }
}
