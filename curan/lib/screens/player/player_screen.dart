import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/audio_player_widget.dart';
import '../../widgets/reciter_avatar.dart';
import '../../models/track_model.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Audio Player'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.tertiary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.library_music), text: 'Library'),
            Tab(icon: Icon(Icons.queue_music), text: 'Playlist'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildLibraryTab(), _buildPlaylistTab()],
            ),
          ),
          Consumer<AudioProvider>(
            builder: (context, audio, _) {
              if (audio.currentTrack == null) {
                return const SizedBox.shrink();
              }
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                child: AudioPlayerWidget(
                  track: audio.currentTrack!,
                  position: audio.position,
                  duration: audio.duration,
                  isPlaying: audio.isPlaying,
                  isRepeat: audio.isRepeat,
                  isShuffled: audio.isShuffled,
                  onPlayPause: audio.togglePlayPause,
                  onSeek: audio.seekTo,
                  onNext: audio.seekToNext,
                  onPrevious: audio.seekToPrevious,
                  onToggleRepeat: audio.toggleRepeat,
                  onToggleShuffle: audio.toggleShuffle,
                  progress: audio.playbackProgress,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryTab() {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        if (audio.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (audio.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.library_music, size: 64, color: Colors.white38),
                const SizedBox(height: 16),
                Text(
                  'No playlists available',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          key: const PageStorageKey('library_list'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: audio.categories.length,
          itemBuilder: (context, index) {
            final category = audio.categories[index];
            return Padding(
              key: ValueKey(category.id),
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: ReciterAvatar(
                    name: category.name,
                    size: 50,
                    fontSize: 18,
                  ),
                  title: Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    '${category.tracks.length} Surahs',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 16,
                  ),
                  onTap: () {
                    audio.selectCategory(index);
                    _showCategoryTracks(context, category);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistTab() {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        if (audio.currentPlaylist.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.queue_music, size: 64, color: Colors.white38),
                const SizedBox(height: 16),
                Text(
                  'Select a reciter to start',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          key: const PageStorageKey('playlist_list'),
          padding: const EdgeInsets.all(16),
          itemCount: audio.currentPlaylist.length,
          itemBuilder: (context, index) {
            final track = audio.currentPlaylist[index];
            final isCurrentTrack = audio.currentIndex == index;

            return Padding(
              key: ValueKey(track.id),
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrentTrack
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrentTrack
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentTrack
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white.withValues(alpha: 0.1),
                    child: Icon(
                      isCurrentTrack && audio.isPlaying
                          ? Icons.equalizer
                          : Icons.music_note,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    track.title,
                    style: TextStyle(
                      fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentTrack ? Colors.white : Colors.white70,
                    ),
                  ),
                  subtitle: Text(
                    track.category ?? '',
                    style: TextStyle(color: Colors.white54),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer2<FavoritesProvider, AuthProvider>(
                        builder: (context, fav, auth, _) {
                          return FutureBuilder<bool>(
                            future: auth.currentUser != null
                                ? fav.isFavorite(auth.currentUser!.uid, track.id)
                                : Future.value(false),
                            builder: (context, snapshot) {
                              final isFav = snapshot.data ?? false;
                              return IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.redAccent : Colors.white54,
                                ),
                                onPressed: () async {
                                  if (auth.currentUser == null) return;
                                  if (isFav) {
                                    await fav.removeFavorite(
                                      auth.currentUser!.uid,
                                      track.id,
                                    );
                                  } else {
                                    await fav.addFavorite(
                                      auth.currentUser!.uid,
                                      track,
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        onPressed: () => audio.playTrack(index),
                      ),
                    ],
                  ),
                  onTap: () => audio.playTrack(index),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCategoryTracks(BuildContext context, dynamic category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      ReciterAvatar(
                        name: category.name,
                        size: 44,
                        fontSize: 16,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        context.read<AudioProvider>().playTrack(0);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play All', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.1)),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: category.tracks.length,
                  itemBuilder: (context, index) {
                    final track = category.tracks[index] as TrackModel;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        title: Text(track.title, style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          context.read<AudioProvider>().playTrack(index);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
