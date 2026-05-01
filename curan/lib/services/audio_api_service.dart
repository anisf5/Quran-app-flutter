import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/track_model.dart';
import '../models/playlist_category.dart';

class AudioApiService {
  static const String baseUrl = 'https://www.mp3quran.net/api/v3';

  Future<List<PlaylistCategory>> fetchPlaylists() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reciters?language=eng'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parsePlaylists(data);
      }
    } catch (e) {
      debugPrint('Failed to fetch playlists: $e');
    }

    return _getDefaultPlaylists();
  }

  Future<List<TrackModel>> fetchTracksForCategory(String categoryId) async {
    // This isn't needed with v3 as we build tracks locally from the moshaf.
    // In case called, we just return empty as a fallback.
    return [];
  }

  Future<String?> fetchAudioUrl(String trackId) async {
    // We already provide the direct audioUrl in the TrackModel.
    // Returning null implies no async fetch needed.
    return null;
  }

  List<PlaylistCategory> _parsePlaylists(dynamic data) {
    if (data == null || data['reciters'] == null) return _getDefaultPlaylists();

    final List<dynamic> reciters = data['reciters'];

    return reciters
        .map((reciter) {
          final reciterName = reciter['name'] ?? 'Unknown Reciter';
          final reciterId = reciter['id']?.toString() ?? '';

          final List<dynamic> moshafList = reciter['moshaf'] ?? [];
          if (moshafList.isEmpty) {
            return PlaylistCategory(
              id: reciterId,
              name: reciterName,
              tracks: [],
            );
          }

          final moshaf = moshafList.first;
          final serverUrl = moshaf['server'] as String? ?? '';
          final surahListStr = moshaf['surah_list'] as String? ?? '';

          final surahIds = surahListStr
              .split(',')
              .where((e) => e.isNotEmpty)
              .map((e) => int.tryParse(e) ?? 0)
              .where((e) => e > 0)
              .toList();

          final tracks = surahIds.map((surahNum) {
            final paddedNum = surahNum.toString().padLeft(3, '0');
            final cleanServer = serverUrl.endsWith('/')
                ? serverUrl
                : '$serverUrl/';

            return TrackModel(
              id: '${reciterId}_$surahNum',
              title: 'Surah ${_getSurahName(surahNum)}',
              audioUrl: '$cleanServer$paddedNum.mp3',
              category: reciterName,
              trackNumber: surahNum,
            );
          }).toList();

          return PlaylistCategory(
            id: reciterId,
            name: reciterName,
            tracks: tracks,
          );
        })
        .where((cat) => cat.tracks.isNotEmpty)
        .toList();
  }

  List<PlaylistCategory> _getDefaultPlaylists() {
    return [
      PlaylistCategory(
        id: 'default_mishary',
        name: 'Mishary Rashid Alafasy',
        tracks: List.generate(
          114,
          (index) => TrackModel(
            id: 'surah_${index + 1}',
            title: 'Surah ${_getSurahName(index + 1)}',
            audioUrl:
                'https://server8.mp3quran.net/afs/${(index + 1).toString().padLeft(3, '0')}.mp3',
            category: 'Mishary Rashid Alafasy',
            trackNumber: index + 1,
          ),
        ),
      ),
      PlaylistCategory(
        id: 'default_sudais',
        name: 'Abdurrahman As-Sudais',
        tracks: List.generate(
          114,
          (index) => TrackModel(
            id: 'sudais_${index + 1}',
            title: 'Surah ${_getSurahName(index + 1)}',
            audioUrl:
                'https://server11.mp3quran.net/sds/${(index + 1).toString().padLeft(3, '0')}.mp3',
            category: 'Abdurrahman As-Sudais',
            trackNumber: index + 1,
          ),
        ),
      ),
    ];
  }

  String _getSurahName(int number) {
    const names = [
      'Al-Fatiha',
      'Al-Baqarah',
      'Aal-E-Imran',
      'An-Nisa',
      'Al-Maidah',
      'Al-Anam',
      'Al-Araf',
      'Al-Anfal',
      'At-Tawbah',
      'Yunus',
      'Hud',
      'Yusuf',
      'Ar-Rad',
      'Ibrahim',
      'Al-Hijr',
      'An-Nahl',
      'Al-Isra',
      'Al-Kahf',
      'Maryam',
      'Ta-Ha',
      'Al-Anbiya',
      'Al-Hajj',
      'Al-Muminun',
      'An-Nur',
      'Al-Furqan',
      'Ash-Shuara',
      'An-Naml',
      'Al-Qasas',
      'Al-Ankabut',
      'Ar-Rum',
      'Luqman',
      'As-Sajdah',
      'Al-Ahzab',
      'Saba',
      'Fatir',
      'Ya-Sin',
      'As-Saffat',
      'Sad',
      'Az-Zumar',
      'Ghafir',
      'Fussilat',
      'Ash-Shura',
      'Az-Zukhruf',
      'Ad-Dukhan',
      'Al-Jathiyah',
      'Al-Ahqaf',
      'Muhammad',
      'Al-Fath',
      'Al-Hujurat',
      'Qaf',
      'Adh-Dhariyat',
      'At-Tur',
      'An-Najm',
      'Al-Qamar',
      'Ar-Rahman',
      'Al-Waqiah',
      'Al-Hadid',
      'Al-Mujadila',
      'Al-Hashr',
      'Al-Mumtahinah',
      'As-Saff',
      'Al-Jumuah',
      'Al-Munafiqun',
      'At-Taghabun',
      'At-Talaq',
      'At-Tahrim',
      'Al-Mulk',
      'Al-Qalam',
      'Al-Haqqah',
      'Al-Maarij',
      'Nuh',
      'Al-Jinn',
      'Al-Muzzammil',
      'Al-Muddathir',
      'Al-Qiyamah',
      'Al-Insan',
      'Al-Mursalat',
      'An-Naba',
      'An-Naziat',
      'Abasa',
      'At-Takwir',
      'Al-Infitar',
      'Al-Mutaffifin',
      'Al-Inshiqaq',
      'Al-Buruj',
      'At-Tariq',
      'Al-Ala',
      'Al-Ghashiyah',
      'Al-Fajr',
      'Al-Balad',
      'Ash-Shams',
      'Al-Lail',
      'Ad-Duha',
      'Ash-Sharh',
      'At-Tin',
      'Al-Alaq',
      'Al-Qadr',
      'Al-Bayyinah',
      'Az-Zalzalah',
      'Al-Adiyat',
      'Al-Qariah',
      'At-Takathur',
      'Al-Asr',
      'Al-Humazah',
      'Al-Fil',
      'Quraish',
      'Al-Maun',
      'Al-Kawthar',
      'Al-Kafirun',
      'An-Nasr',
      'Al-Lahab',
      'Al-Ikhlas',
      'Al-Falaq',
      'An-Nas',
    ];
    if (number >= 1 && number <= 114) {
      return names[number - 1];
    }
    return number.toString();
  }
}
