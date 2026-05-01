import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_model.dart';

class PrayerTimesService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static const String _cacheKey = 'prayer_times_cache';
  static const String _cacheDateKey = 'prayer_times_cache_date';

  /// Fetch prayer times: use GPS coordinates when available,
  /// fall back to cached data if offline.
  Future<PrayerTimesModel?> fetchPrayerTimes() async {
    try {
      final position = await _determinePosition();
      final today = _todayString();

      // Check cache for today
      final prefs = await SharedPreferences.getInstance();
      final cachedDate = prefs.getString(_cacheDateKey);
      if (cachedDate == today) {
        final cachedJson = prefs.getString(_cacheKey);
        if (cachedJson != null) {
          return PrayerTimesModel.fromJson(
            json.decode(cachedJson) as Map<String, dynamic>,
            'My Location',
          );
        }
      }

      final url = Uri.parse(
        '$_baseUrl/timings?latitude=${position.latitude}'
        '&longitude=${position.longitude}&method=2',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        // Cache today's result
        await prefs.setString(_cacheKey, response.body);
        await prefs.setString(_cacheDateKey, today);
        return PrayerTimesModel.fromJson(data, 'My Location');
      }
    } catch (e) {
      // Try returning cached value even if stale
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        return PrayerTimesModel.fromJson(
          json.decode(cachedJson) as Map<String, dynamic>,
          'Cached',
        );
      }
    }
    return null;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 8),
      ),
    );
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
