import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with SingleTickerProviderStateMixin {
  static const _kaabaLat = 21.4225;
  static const _kaabaLon = 39.8262;

  static const _smoothAlpha = 0.08;
  static const _headingFilter = 0.5;

  double _smoothX = 0;
  double _smoothY = 0;
  double _smoothHeading = 0;
  double _qiblaDirection = 0;
  Position? _position;
  bool _isQiblaAligned = false;
  bool _isLoading = true;
  bool _noSensor = false;
  String? _error;
  String? _buildException;

  StreamSubscription<MagnetometerEvent>? _magnetSub;
  StreamSubscription<Position>? _positionSub;

  late AnimationController _alignCtrl;

  @override
  void initState() {
    super.initState();
    _alignCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _initSensors();
  }

  @override
  void dispose() {
    _magnetSub?.cancel();
    _positionSub?.cancel();
    _alignCtrl.dispose();
    super.dispose();
  }

  Future<void> _initSensors() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _position = pos;
        _qiblaDirection = _calcQibla(pos.latitude, pos.longitude);
        _isLoading = false;
      });

      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 1000,
        ),
      ).listen((p) {
        if (!mounted) return;
        setState(() {
          _position = p;
          _qiblaDirection = _calcQibla(p.latitude, p.longitude);
        });
      });

      _magnetSub = magnetometerEventStream(
        samplingPeriod: const Duration(milliseconds: 50),
      ).listen(_onMagnetEvent, onError: (_) {
        if (mounted) setState(() => _noSensor = true);
      });
    } catch (e) {
      if (mounted) setState(() { _error = '$e'; _isLoading = false; });
    }
  }

  void _onMagnetEvent(MagnetometerEvent event) {
    if (!mounted) return;
    try {
      _smoothX += (event.x - _smoothX) * _smoothAlpha;
      _smoothY += (event.y - _smoothY) * _smoothAlpha;

      var raw = math.atan2(_smoothY, _smoothX) * 180 / math.pi;
      raw = (raw + 360) % 360;

      final diff = raw - _smoothHeading;
      final wrapped = (diff + 180) % 360 - 180;
      _smoothHeading += wrapped * _headingFilter;
      _smoothHeading = (_smoothHeading + 360) % 360;

      final qd = (_qiblaDirection - _smoothHeading + 360) % 360;
      final aligned = qd < 3 || qd > 357;

      setState(() {
        _isQiblaAligned = aligned;
      });
      if (aligned) {
        if (!_alignCtrl.isAnimating) _alignCtrl.forward();
      } else {
        _alignCtrl.reverse();
      }
    } catch (_) {}
  }

  double _calcQibla(double lat, double lon) {
    final lr = lat * math.pi / 180;
    final lor = lon * math.pi / 180;
    final klr = _kaabaLat * math.pi / 180;
    final klor = _kaabaLon * math.pi / 180;
    final d = klor - lor;
    final y = math.sin(d);
    final x = math.cos(lr) * math.tan(klr) - math.sin(lr) * math.cos(d);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Qibla Compass',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    try {
      if (_buildException != null) {
        return Center(child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('$_buildException',
            style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
        ));
      }
      if (_isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF00BFA6)));
      }
      if (_error != null) return _buildError();
      if (_noSensor) return _buildNoSensor();
      return _buildCompass();
    } catch (e) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text('Build error:\n$e',
          style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
      ));
    }
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
              child: const Icon(Icons.location_disabled_rounded,
                size: 64, color: Colors.white24),
            ),
            const SizedBox(height: 24),
            const Text('Location Required',
              style: TextStyle(color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text('Please enable location permissions\nto use the Qibla compass.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() { _isLoading = true; _error = null; });
                _initSensors();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSensor() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
              child: const Icon(Icons.sensors_off_rounded,
                size: 64, color: Colors.white24),
            ),
            const SizedBox(height: 24),
            const Text('Magnetometer Not Found',
              style: TextStyle(color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text('Your device does not have a\nmagnetic sensor for compass.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass() {
    final relativeQibla = (_qiblaDirection - _smoothHeading + 360) % 360;

    return Stack(
      children: [
        Positioned(top: -80, right: -60, child: Container(
          width: 240, height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00BFA6).withOpacity(0.06),
          ),
        )),
        Positioned(bottom: -60, left: -80, child: Container(
          width: 200, height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A237E).withOpacity(0.08),
          ),
        )),

        Column(
          children: [
            const Spacer(flex: 1),
            SizedBox(
              width: 300, height: 300,
              child: Stack(alignment: Alignment.center, children: [
                Transform.rotate(
                  angle: -(_smoothHeading * math.pi / 180),
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: _QiblaArcPainter(
                      angle: _qiblaDirection * math.pi / 180,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -(_smoothHeading * math.pi / 180),
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: _CompassPainter(),
                  ),
                ),
                Transform.rotate(
                  angle: relativeQibla * math.pi / 180,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 4, height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF00BFA6),
                              const Color(0xFF00BFA6).withOpacity(0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00BFA6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00BFA6)
                                  .withOpacity(0.6),
                              blurRadius: 12, spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.near_me_rounded,
                          color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF090E1A),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15), width: 2),
                  ),
                ),
              ]),
            ),
            const Spacer(flex: 1),
            _buildInfoCard(relativeQibla),
            const SizedBox(height: 16),
            if (_position != null)
              Text(
                '${_position!.latitude.toStringAsFixed(4)}°, '
                '${_position!.longitude.toStringAsFixed(4)}°',
                style: const TextStyle(color: Colors.white24, fontSize: 11)),
            const Spacer(flex: 1),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(double relativeQibla) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isQiblaAligned
            ? const Color(0xFF00BFA6).withOpacity(0.08)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isQiblaAligned
              ? const Color(0xFF00BFA6).withOpacity(0.4)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _isQiblaAligned
                ? Icons.check_circle_rounded
                : Icons.explore_rounded,
            color: _isQiblaAligned
                ? const Color(0xFF00BFA6)
                : Colors.white38,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            _isQiblaAligned ? 'Facing Qibla' : 'Qibla Direction',
            style: TextStyle(
              color: _isQiblaAligned
                  ? const Color(0xFF00BFA6)
                  : Colors.white.withOpacity(0.6),
              fontSize: 13, fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isQiblaAligned
                ? 'You are facing the Kaaba!'
                : '${_qiblaDirection.toStringAsFixed(1)}° from True North',
            style: TextStyle(
              color: _isQiblaAligned
                  ? Colors.white
                  : const Color(0xFF00BFA6).withOpacity(0.8),
              fontSize: 18, fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${relativeQibla.round()}° ${_dirLabel(relativeQibla)}',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _dirLabel(double d) {
    if (d < 22.5 || d >= 337.5) return 'N';
    if (d < 67.5) return 'NE';
    if (d < 112.5) return 'E';
    if (d < 157.5) return 'SE';
    if (d < 202.5) return 'S';
    if (d < 247.5) return 'SW';
    if (d < 292.5) return 'W';
    return 'NW';
  }
}

// ─── Compass Dial Painter ────────────────────────────────────────────────

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Outer ring
    final ring = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(c, r * 0.97, ring);

    // Ticks
    for (int i = 0; i < 360; i += 2) {
      final rad = (i * math.pi / 180);
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;

      double outer, w;
      if (isCardinal) { outer = r * 0.78; w = 2.5; }
      else if (isMajor) { outer = r * 0.83; w = 1.5; }
      else { outer = r * 0.87; w = 0.5; }

      final o = Offset(c.dx + outer * math.cos(rad - math.pi / 2),
                       c.dy + outer * math.sin(rad - math.pi / 2));
      final inner = Offset(c.dx + r * 0.92 * math.cos(rad - math.pi / 2),
                           c.dy + r * 0.92 * math.sin(rad - math.pi / 2));

      canvas.drawLine(o, inner, Paint()
        ..color = isCardinal
            ? Colors.white.withOpacity(0.7)
            : Colors.white.withOpacity(isMajor ? 0.25 : 0.1)
        ..strokeWidth = w);

      if (isCardinal) {
        final tp = TextPainter(
          text: TextSpan(
            text: i == 0 ? 'N' : i == 90 ? 'E' : i == 180 ? 'S' : 'W',
            style: TextStyle(
              color: i == 0 ? Colors.redAccent : Colors.white.withOpacity(0.7),
              fontSize: 15, fontWeight: FontWeight.w800),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final ld = r * 0.66;
        tp.paint(canvas, Offset(
          c.dx + ld * math.cos(rad - math.pi / 2) - tp.width / 2,
          c.dy + ld * math.sin(rad - math.pi / 2) - tp.height / 2,
        ));
      }

      if (isMajor && !isCardinal) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${i}°',
            style: TextStyle(
              color: Colors.white.withOpacity(0.15), fontSize: 8),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final ld = r * 0.73;
        tp.paint(canvas, Offset(
          c.dx + ld * math.cos(rad - math.pi / 2) - tp.width / 2,
          c.dy + ld * math.sin(rad - math.pi / 2) - tp.height / 2,
        ));
      }
    }

    canvas.drawCircle(c, r * 0.30, Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Qibla Arc Painter ──────────────────────────────────────────────────

class _QiblaArcPainter extends CustomPainter {
  final double angle;
  _QiblaArcPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final start = -math.pi / 2 + angle - 0.05;
    final sweep = 0.1;

    final p = Paint()
      ..color = const Color(0xFF00BFA6).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 0.96), start, sweep, false, p);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 0.32), start, sweep, false, p..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant _QiblaArcPainter old) => old.angle != angle;
}
