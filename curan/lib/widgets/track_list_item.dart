import 'package:flutter/material.dart';

class TrackListItem extends StatelessWidget {
  final String trackTitle;
  final int playCount;
  final VoidCallback onTap;
  final String? subtitle;

  const TrackListItem({
    super.key,
    required this.trackTitle,
    required this.playCount,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '$playCount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
      title: Text(
        trackTitle,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: IconButton(
        icon: const Icon(Icons.play_arrow),
        onPressed: onTap,
      ),
      onTap: onTap,
    );
  }
}
