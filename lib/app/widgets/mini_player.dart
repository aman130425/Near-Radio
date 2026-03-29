import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/audio_service.dart';
import '../../core/models/radio_station.dart';
import '../../core/constants/app_strings.dart';
import '../../app/routes/app_pages.dart';
import 'package:near_radio/controllers/player_controller.dart';
import 'glass_container.dart';
import 'station_logo_image.dart';

/// Mini player widget that shows at the bottom when a station is playing
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  Future<void> _navigateToPlayer(BuildContext context) async {
    final audioService = Get.find<AudioService>();
    final currentStation = audioService.currentStation.value;
    
    if (currentStation == null) return;
    
    try {
      // Get or create player controller
      PlayerController playerController;
      if (Get.isRegistered<PlayerController>()) {
        playerController = Get.find<PlayerController>();
        // Sync with audio service current station
        playerController.currentStation.value = currentStation;
        // Update index if station list is available
        if (playerController.stationList.isNotEmpty) {
          final index = playerController.stationList.indexWhere(
            (s) => s.id == currentStation.id,
          );
          if (index >= 0) {
            playerController.currentIndex.value = index;
          }
        }
      } else {
        playerController = Get.put(PlayerController(), permanent: false);
      }
      
      // Navigate to player screen
      await Get.toNamed(Routes.player);
    } catch (e) {
      // If navigation fails, just show error
      Get.snackbar(
        'Error',
        'Failed to open player',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioService = Get.find<AudioService>();

    return Obx(() {
      final currentStation = audioService.currentStation.value;
      final isPlaying = audioService.isPlaying.value;

      if (currentStation == null) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: GlassContainer(
          padding: EdgeInsets.all(12),
          borderRadius: 20,
          child: InkWell(
            onTap: () => _navigateToPlayer(context),
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                  child: currentStation.logo != null && currentStation.logo!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: StationLogoImage(
                            url: currentStation.logo!,
                            fit: BoxFit.cover,
                            errorWidget: Icon(
                              Icons.radio_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.radio_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentStation.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPlaying ? AppStrings.playing : AppStrings.paused,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => audioService.togglePlayPause(),
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => audioService.stop(),
                  icon: const Icon(Icons.stop_circle_outlined),
                  color: Colors.grey,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

