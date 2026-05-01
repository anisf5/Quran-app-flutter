import 'package:flutter/foundation.dart';
import '../models/prayer_times_model.dart';
import '../services/prayer_times_service.dart';

class PrayerTimesProvider extends ChangeNotifier {
  final PrayerTimesService _service = PrayerTimesService();

  PrayerTimesModel? _prayerTimes;
  bool _isLoading = false;
  String? _error;

  PrayerTimesModel? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPrayerTimes() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prayerTimes = await _service.fetchPrayerTimes();
      if (_prayerTimes == null) {
        _error = 'Could not fetch prayer times';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
