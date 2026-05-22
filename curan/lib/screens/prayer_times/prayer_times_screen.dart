import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/prayer_times_provider.dart';
import '../../models/prayer_times_model.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerTimesProvider>().loadPrayerTimes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      body: Stack(
        children: [
          // Ambient background
          Positioned(
            top: -100,
            right: -80,
            child: _orb(const Color(0xFF00BFA6), 300),
          ),
          Positioned(
            bottom: -80,
            left: -100,
            child: _orb(const Color(0xFF1A237E), 280),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مواقيت الصلاة',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Prayer Times',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white38,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.explore_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.qibla),
                      ),
                      Consumer<PrayerTimesProvider>(
                        builder: (_, p, __) => IconButton(
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: p.isLoading
                              ? null
                              : () => context
                                    .read<PrayerTimesProvider>()
                                    .loadPrayerTimes(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Consumer<PrayerTimesProvider>(
                    builder: (_, provider, __) {
                      if (provider.isLoading) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Fetching prayer times...',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        );
                      }

                      if (provider.error != null ||
                          provider.prayerTimes == null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_off_rounded,
                                  size: 56,
                                  color: Colors.white24,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Could not get prayer times',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Enable location access for accurate times',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => context
                                      .read<PrayerTimesProvider>()
                                      .loadPrayerTimes(),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final pt = provider.prayerTimes!;
                      return _buildContent(context, pt);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, PrayerTimesModel pt) {
    final now = TimeOfDay.now();
    final nextPrayer = _getNextPrayer(pt, now);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        children: [
          // Date card
          _glassCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pt.date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white12,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hijri',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pt.hijriDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Next prayer highlight
          if (nextPrayer != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      color: Colors.black,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Prayer',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${nextPrayer.name} — ${nextPrayer.nameAr}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    nextPrayer.time,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),

          // All prayer times
          ...pt.prayers.map(
            (p) => _PrayerRow(prayer: p, isNext: p == nextPrayer),
          ),
        ],
      ),
    );
  }

  ({String name, String nameAr, String time})? _getNextPrayer(
    PrayerTimesModel pt,
    TimeOfDay now,
  ) {
    for (final p in pt.prayers) {
      final parts = p.time.split(':');
      if (parts.length < 2) continue;
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      if (h > now.hour || (h == now.hour && m > now.minute)) {
        return p;
      }
    }
    return pt.prayers.first; // wrap to Fajr next day
  }

  Widget _glassCard({required Widget child}) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        padding: const EdgeInsets.all(18),
        child: child,
      ),
    ),
  );

  Widget _orb(Color color, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(0.12),
    ),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(color: Colors.transparent),
    ),
  );
}

// ── Prayer Row ────────────────────────────────────────────────────────
class _PrayerRow extends StatelessWidget {
  final ({String name, String nameAr, String time}) prayer;
  final bool isNext;

  const _PrayerRow({required this.prayer, required this.isNext});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isNext
            ? cs.primary.withOpacity(0.10)
            : Colors.white.withOpacity(0.04),
        border: Border.all(
          color: isNext ? cs.primary.withOpacity(0.35) : Colors.white12,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              prayer.nameAr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isNext ? cs.primary : Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            prayer.name,
            style: TextStyle(
              fontSize: 14,
              color: isNext ? cs.tertiary : Colors.white54,
              fontWeight: isNext ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            prayer.time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isNext ? Colors.white : Colors.white70,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (isNext) ...[
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: cs.primary),
          ],
        ],
      ),
    );
  }
}
