import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/widgets/glass_card.dart';
import '../../app/widgets/glass_container.dart';
import '../../app/widgets/loading_overlay.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/local_music_file.dart';
import 'package:near_radio/controllers/player_controller.dart';
import 'package:near_radio/controllers/local_music_controller.dart';
import 'package:near_radio/core/constants/app_constants.dart';
import 'package:near_radio/core/utils/loader_widgets.dart';

/// Local music screen view
class LocalMusicView extends GetView<LocalMusicController> {
  const LocalMusicView({super.key});

  static const double _headerContentHeight = 72;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).size.height*0.08;
    final overlayHeight = topInset + _headerContentHeight;
    final bottomInset = AppConstants.mainViewBottomInset;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value) {
              return buildRefreshableScrollView(
                onRefresh: controller.loadLocalMusic,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: overlayHeight)),
                    const SliverFillRemaining(
                      child: Center(child: CircularLoader()),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: bottomInset + 8)),
                  ],
                ),
              );
            }
            if (controller.errorMessage.value.isNotEmpty) {
              return buildRefreshableScrollView(
                onRefresh: controller.loadLocalMusic,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: overlayHeight)),
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: controller.loadLocalMusic,
                              child: const Text(AppStrings.retry),
                            ),
                            if (controller.errorMessage.value
                                .toLowerCase()
                                .contains('settings')) ...[
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: controller.openAppSettingsForPermission,
                                icon: const Icon(Icons.settings_rounded, size: 20),
                                label: const Text('Open Settings'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: bottomInset + 8)),
                ],
                ),
              );
            }
            final musicFiles = controller.filteredMusicFiles;
            if (musicFiles.isEmpty) {
              return buildRefreshableScrollView(
                onRefresh: controller.loadLocalMusic,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: overlayHeight)),
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_off_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No music files found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add music files',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: bottomInset + 8)),
                ],
                ),
              );
            }
            return buildRefreshableScrollView(
              onRefresh: controller.loadLocalMusic,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: overlayHeight)),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      top: 1,
                      bottom: bottomInset,
                    ),
                    sliver: SliverList.builder(
                      itemCount: musicFiles.length,
                      itemBuilder: (context, index) {
                        final musicFile = musicFiles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: _buildMusicCard(musicFile, context),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
                ],
              ),
            );
          }),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: topInset),
                _buildSearchBar(context),
                Container(
                  height: 0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (isDark ? Colors.black : Colors.white).withOpacity(0.92),
                        (isDark ? Colors.black : Colors.white).withOpacity(0.85),
                        (isDark ? Colors.black : Colors.white).withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16,right: 16,top: 18, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: 15,
              child: Obx(() => TextField(
                onChanged: controller.searchMusic,
                decoration: InputDecoration(
                  hintText: 'Search music...',
                  border: InputBorder.none,
                  icon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            controller.searchQuery.value = '';
                            controller.searchMusic('');
                          },
                        )
                      : null,
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicCard(LocalMusicFile musicFile, BuildContext context) {
    final isPlaying = controller.isCurrentlyPlaying(musicFile);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      borderRadius: 12,
      onTap: () async {
        // Show loading dialog
        showLoadingDialog(context, message: 'Loading music...');
        try {
          // Wait for 2 seconds
          await Future.delayed(const Duration(seconds: 2));
          
          // Hide loading dialog before navigation
          if (context.mounted) {
            hideLoadingDialog(context);
          }
          
          // Then play
          await controller.playMusicFile(musicFile);
        } catch (e) {
          if (context.mounted) {
            hideLoadingDialog(context);
          }
        }
      },
      child: Row(
        children: [
          // Music Icon
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            child: Icon(
              Icons.music_note_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),

          // Music Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  musicFile.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (musicFile.artist != null)
                  Text(
                    musicFile.artist!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (musicFile.album != null)
                  Text(
                    musicFile.album!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Play/Pause Icon
          Obx(() {
            final isCurrentlyPlaying = controller.isCurrentlyPlaying(musicFile);
            if (isCurrentlyPlaying) {
              // Check if actually playing (not just paused)
              if (Get.isRegistered<PlayerController>()) {
                final playerController = Get.find<PlayerController>();
                final isActuallyPlaying = playerController.isPlaying.value;
                return Icon(
                  isActuallyPlaying
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 26,
                );
              }
            }
            return Icon(
              Icons.play_circle_outline,
              color: Colors.grey[600],
              size: 32,
            );
          }),
        ],
      ),
    );
  }
}

