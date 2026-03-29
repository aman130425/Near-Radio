import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/widgets/glass_container.dart';
import '../../app/widgets/glass_button.dart';
import '../../core/utils/loader_widgets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/radio_station.dart';
import '../../core/services/audio_service.dart';
import 'package:near_radio/controllers/player_controller.dart';
import 'package:near_radio/app/widgets/station_logo_image.dart';

/// Player screen view – layout like reference: artwork, dots, control row, utility row, sections below.
class PlayerView extends GetView<PlayerController> {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusBarColor = theme.colorScheme.primary.withOpacity(0.12);
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Obx(() {
          final station = controller.currentStation.value;

          if (station == null) {
            if (controller.isLoading.value || controller.stationList.isNotEmpty) {
              return const Center(child: CircularLoader());
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.radio_rounded, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No station selected',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildArtworkAndInfo(context, station),
                        _buildDotsIndicator(context),
                        _buildMainControlRow(context, station),
                        // _buildUtilityRow(context),
                        _buildRecentlyPlayed(context, station),
                        _buildYouMightAlsoLike(context, station),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    ));
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Spacer(),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.graphic_eq_rounded),
          // ),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.cast_rounded),
          // ),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.sports_esports_rounded),
          // ),
        ],
      ),
    );
  }

  Widget _buildArtworkAndInfo(BuildContext context, RadioStation station) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          GlassContainer(
            width: double.infinity,
            height: 280,
            borderRadius: 24,
            padding: const EdgeInsets.all(16),
            child: station.logo != null && station.logo!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: StationLogoImage(
                      url: station.logo!,
                      fit: BoxFit.cover,
                      errorWidget: _buildDefaultArtwork(context),
                    ),
                  )
                : _buildDefaultArtwork(context),
          ),
          const SizedBox(height: 20),
          Text(
            station.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            station.category ?? station.country ?? 'Various',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                controller.isLoading.value
                    ? AppStrings.loading
                    : controller.isPlaying.value
                        ? AppStrings.playing
                        : AppStrings.paused,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: controller.isPlaying.value
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[600],
                    ),
              )),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _dot(context, false),
          const SizedBox(width: 8),
          _dot(context, true),
          const SizedBox(width: 8),
          _dot(context, false),
        ],
      ),
    );
  }

  Widget _dot(BuildContext context, bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
      ),
    );
  }

  Widget _buildMainControlRow(BuildContext context, RadioStation station) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GlassButton(
            icon: Obx(() {
              final audioService = Get.find<AudioService>();
              final muted = audioService.isMuted.value;
              return Icon(
                muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                size: 20,
              );
            }),
            onPressed: () => controller.toggleMute(),
            borderRadius: 28,
            padding: const EdgeInsets.all(10),
          ),
          Obx(() => GlassButton(
                icon: Icon(
                  Icons.skip_previous_rounded,
                  size: 20,
                  color: controller.hasPreviousStation ? null : Colors.grey[400],
                ),
                onPressed: controller.hasPreviousStation ? () => controller.playPrevious() : null,
                borderRadius: 28,
                padding: const EdgeInsets.all(10),
              )),
          // GlassButton(
          //   icon: const Icon(Icons.share_rounded, size: 24),
          //   onPressed: () {},
          //   borderRadius: 28,
          //   padding: const EdgeInsets.all(14),
          // ),
          Obx(() => GlassButton(
                icon: Icon(
                  controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 35,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => controller.togglePlayPause(),
                borderRadius: 35,
                padding: const EdgeInsets.all(12),
              )),
          // GlassButton(
          //   icon: const Icon(Icons.graphic_eq_rounded, size: 24),
          //   onPressed: () {},
          //   borderRadius: 28,
          //   padding: const EdgeInsets.all(14),
          // ),
          Obx(() => GlassButton(
                icon: Icon(
                  Icons.skip_next_rounded,
                  size: 20,
                  color: controller.hasNextStation ? null : Colors.grey[400],
                ),
                onPressed: controller.hasNextStation ? () => controller.playNext() : null,
                borderRadius: 28,
                padding: const EdgeInsets.all(10),
              )),
          Obx(() {
            final isFav = controller.isCurrentStationFavourite.value;
            return GlassButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isFav ? Colors.red : null,
              ),
              onPressed: () => controller.toggleFavourite(station),
              borderRadius: 28,
              padding: const EdgeInsets.all(10),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUtilityRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassButton(
            icon: const Icon(Icons.alarm_rounded, size: 22),
            onPressed: () {},
            borderRadius: 24,
            padding: const EdgeInsets.all(12),
          ),
          const SizedBox(width: 20),
          GlassButton(
            icon: const Icon(Icons.bedtime_rounded, size: 22),
            onPressed: () {},
            borderRadius: 24,
            padding: const EdgeInsets.all(12),
          ),
          const SizedBox(width: 20),
          GlassButton(
            icon: const Icon(Icons.share_rounded, size: 22),
            onPressed: () {},
            borderRadius: 24,
            padding: const EdgeInsets.all(12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyPlayed(BuildContext context, RadioStation currentStation) {
    return Obx(() {
      final recent = controller.recentStations;
      if (recent.isEmpty) return const SizedBox.shrink();

      final itemWidth = MediaQuery.of(context).size.width / 2.6;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Recently Played',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: recent.length,
              itemBuilder: (context, index) {
                final s = recent[index];
                final isCurrent = s.id == currentStation.id;
                return SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: _stationCard(context, s, isCurrent, currentStation),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildYouMightAlsoLike(BuildContext context, RadioStation currentStation) {
    return Obx(() {
      final recentIds = controller.recentStations.map((r) => r.id).toSet();
      final list = controller.stationList
          .where((s) => s.id != currentStation.id && !recentIds.contains(s.id))
          .take(10)
          .toList();
      if (list.isEmpty) return const SizedBox.shrink();

      final itemWidth = MediaQuery.of(context).size.width / 2.6;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'You might also like',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final s = list[index];
                return SizedBox(
                  width: itemWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: _stationCard(context, s, false, currentStation),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _stationCard(BuildContext context, RadioStation s, bool isCurrent, RadioStation currentStation) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () => controller.playStation(s),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              ),
              child: s.logo != null && s.logo!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: StationLogoImage(
                        url: s.logo!,
                        fit: BoxFit.cover,
                        errorWidget: Icon(
                          Icons.radio_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(Icons.radio_rounded, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              s.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultArtwork(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.radio_rounded,
        size: 100,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
