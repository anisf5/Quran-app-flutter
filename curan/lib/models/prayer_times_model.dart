class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String hijriDate;
  final String city;

  const PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDate,
    required this.city,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json, String city) {
    final timings = json['data']['timings'] as Map<String, dynamic>;
    final dateData = json['data']['date'] as Map<String, dynamic>;
    final gregorian = dateData['gregorian'] as Map<String, dynamic>;
    final hijri = dateData['hijri'] as Map<String, dynamic>;

    // Strip timezone offset e.g. "05:00 (+03)"  → "05:00"
    String clean(String t) => t.split(' ').first;

    return PrayerTimesModel(
      fajr: clean(timings['Fajr'] as String),
      sunrise: clean(timings['Sunrise'] as String),
      dhuhr: clean(timings['Dhuhr'] as String),
      asr: clean(timings['Asr'] as String),
      maghrib: clean(timings['Maghrib'] as String),
      isha: clean(timings['Isha'] as String),
      date: gregorian['date'] as String? ?? '',
      hijriDate:
          '${hijri['day']} ${(hijri['month'] as Map)['en']} ${hijri['year']}',
      city: city,
    );
  }

  /// Returns the list of named prayers in display order (no Sunrise).
  List<({String name, String nameAr, String time})> get prayers => [
    (name: 'Fajr', nameAr: 'الفجر', time: fajr),
    (name: 'Dhuhr', nameAr: 'الظهر', time: dhuhr),
    (name: 'Asr', nameAr: 'العصر', time: asr),
    (name: 'Maghrib', nameAr: 'المغرب', time: maghrib),
    (name: 'Isha', nameAr: 'العشاء', time: isha),
  ];
}
