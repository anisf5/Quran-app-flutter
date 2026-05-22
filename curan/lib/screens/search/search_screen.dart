import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';
import '../../widgets/reciter_avatar.dart';
import '../../models/track_model.dart';
import '../../models/playlist_category.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<_SearchResult> _getResults(List<PlaylistCategory> categories) {
    if (_query.trim().isEmpty) return [];
    final q = _query.trim().toLowerCase();

    final results = <_SearchResult>[];
    for (var ci = 0; ci < categories.length; ci++) {
      final cat = categories[ci];
      for (var ti = 0; ti < cat.tracks.length; ti++) {
        final track = cat.tracks[ti];
        if (track.title.toLowerCase().contains(q) ||
            (track.category?.toLowerCase().contains(q) ?? false)) {
          results.add(_SearchResult(
            categoryIndex: ci,
            trackIndex: ti,
            track: track,
            categoryName: cat.name,
          ));
        }
      }
    }
    return results;
  }

  void _playResult(_SearchResult result) {
    final audio = context.read<AudioProvider>();
    audio.selectCategory(result.categoryIndex);
    audio.playTrack(result.trackIndex);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search surahs or reciters...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
              prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          color: Colors.white54),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _focusNode.unfocus(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white54),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audio, _) {
          if (audio.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    'No reciters loaded',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final results = _getResults(audio.categories);

          if (_query.isNotEmpty && results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    'No results for "$_query"',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different surah or reciter name',
                    style: TextStyle(color: Colors.white24, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          if (_query.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded, size: 80, color: cs.primary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Search any surah or reciter',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Group results by category for display
          final grouped = <String, List<_SearchResult>>{};
          for (final r in results) {
            grouped.putIfAbsent(r.categoryName, () => []).add(r);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  '${results.length} result${results.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...grouped.entries.map((entry) => _buildGroup(entry.key, entry.value, cs)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroup(String categoryName, List<_SearchResult> results, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
          child: Row(
            children: [
              ReciterAvatar(
                name: categoryName,
                size: 28,
                fontSize: 11,
              ),
              const SizedBox(width: 8),
              Text(
                categoryName,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        ...results.map((r) => _buildResultTile(r, cs)),
      ],
    );
  }

  Widget _buildResultTile(_SearchResult result, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${result.track.trackNumber ?? (result.trackIndex + 1)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: cs.primary,
              fontSize: 13,
            ),
          ),
        ),
        title: Text(
          result.track.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          result.categoryName,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.play_arrow_rounded, color: cs.primary, size: 22),
            onPressed: () => _playResult(result),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
        onTap: () => _playResult(result),
      ),
    );
  }
}

class _SearchResult {
  final int categoryIndex;
  final int trackIndex;
  final TrackModel track;
  final String categoryName;

  const _SearchResult({
    required this.categoryIndex,
    required this.trackIndex,
    required this.track,
    required this.categoryName,
  });
}
