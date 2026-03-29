import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/widgets/glass_card.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/radio_station.dart';
import 'package:near_radio/controllers/favourites_controller.dart';
import 'package:near_radio/core/constants/app_constants.dart';
import 'package:near_radio/core/utils/loader_widgets.dart';
import 'package:near_radio/app/widgets/station_logo_image.dart';

/// Favourites screen view
class FavouritesView extends GetView<FavouritesController> {
  const FavouritesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh favourites when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadFavourites();
    });

    final topInset = MediaQuery.of(context).size.height * 0.1;
    final bottomInset = AppConstants.mainViewBottomInset;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.favouriteStations.isEmpty) {
          return buildRefreshableScrollView(
            onRefresh: () async => controller.loadFavourites(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: topInset)),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: _buildEmptyState(context)),
                ),
              ],
            ),
          );
        }
        return buildRefreshableScrollView(
          onRefresh: () async => controller.loadFavourites(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topInset)),
              SliverPadding(
                padding: EdgeInsets.only( bottom: bottomInset + 8),
                sliver: SliverList.builder(
                  itemCount: controller.favouriteStations.length,
                  itemBuilder: (context, index) {
                    final station = controller.favouriteStations[index];
                    return _buildStationCard(station, context);
                  },
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: bottomInset + 8)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.noFavourites,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.noFavouritesDesc,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(RadioStation station, BuildContext context) {
    final isPlaying = controller.isCurrentlyPlaying(station);
    
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      borderRadius: 12,
      onTap: () => controller.togglePlayPause(station),
      child: Row(
        children: [
          // Station Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            child: station.logo != null && station.logo!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: StationLogoImage(
                      url: station.logo!,
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
          const SizedBox(width: 16),
          
          // Station Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (station.category != null)
                  Text(
                    station.category!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                if (station.country != null)
                  Text(
                    station.country!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          
          // Remove Favourite Button
          IconButton(
            onPressed: () => controller.removeFavourite(station),
            icon: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
          ),
          
          // Play Button
          IconButton(
            onPressed: () => controller.togglePlayPause(station),
            icon: Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 40,
              color: isPlaying
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

