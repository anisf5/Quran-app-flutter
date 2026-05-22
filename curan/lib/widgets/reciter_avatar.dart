import 'package:flutter/material.dart';

class ReciterAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double fontSize;

  const ReciterAvatar({
    super.key,
    required this.name,
    this.size = 50,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final colorHex = _getColorHex(name);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.network(
        'https://ui-avatars.com/api/'
        '?name=${Uri.encodeComponent(name)}'
        '&background=$colorHex'
        '&color=fff'
        '&size=${size.toInt()}'
        '&bold=true'
        '&font-size=0.5',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(initials),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildFallback(initials);
        },
      ),
    );
  }

  Widget _buildFallback(String initials) {
    final colors = _colorsForName(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _getColorHex(String name) {
    final colors = _colorsForName(name);
    return colors[0].value.toRadixString(16).substring(2).toUpperCase();
  }

  static const _palettes = [
    [Color(0xFF00BFA6), Color(0xFF00897B)],
    [Color(0xFFE91E63), Color(0xFFC2185B)],
    [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    [Color(0xFF3F51B5), Color(0xFF303F9F)],
    [Color(0xFF2196F3), Color(0xFF1976D2)],
    [Color(0xFF009688), Color(0xFF00796B)],
    [Color(0xFFFF5722), Color(0xFFE64A19)],
    [Color(0xFF795548), Color(0xFF5D4037)],
    [Color(0xFF607D8B), Color(0xFF455A64)],
    [Color(0xFFFF9800), Color(0xFFF57C00)],
    [Color(0xFF4CAF50), Color(0xFF388E3C)],
    [Color(0xFF673AB7), Color(0xFF512DA8)],
  ];

  List<Color> _colorsForName(String name) {
    final hash = name.codeUnits.fold<int>(0, (h, c) => h * 31 + c);
    return _palettes[hash.abs() % _palettes.length];
  }
}
