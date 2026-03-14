import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/widgets/loading_overlay.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/loader_widgets.dart';
import '../../core/models/radio_station.dart';
import 'package:near_radio/controllers/home_controller.dart';
import 'package:near_radio/core/constants/app_constants.dart';

/// Home screen view – All channels in grid with See more
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).size.height * 0.08;
    final bottomInset = AppConstants.mainViewBottomInset + MediaQuery.of(context).size.height * 0.1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value && controller.allChannels.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
            child: const Center(child: CircularLoader()),
          );
        }

        if (controller.errorMessage.value.isNotEmpty && controller.allChannels.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.loadData,
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            ),
          );
        }

        final itemWidth = MediaQuery.of(context).size.width / 2.6;
        return buildRefreshableScrollView(
          onRefresh: controller.loadData,
          child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: topInset)),
            // Recently Played – horizontal scroll (above English channels)
            if (controller.recentStations.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: AppStrings.recentlyPlayed,
                  context: context,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: controller.recentStations.length,
                    itemBuilder: (context, index) {
                      final station = controller.recentStations[index];
                      return SizedBox(
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: _buildHorizontalStationCard(station, context),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            // Top 20 English Channels – horizontal scroll (left to right)
            if (controller.topEnglishChannels.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: AppStrings.topEnglishChannels,
                  context: context,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: controller.topEnglishChannels.length,
                    itemBuilder: (context, index) {
                      final station = controller.topEnglishChannels[index];
                      return SizedBox(
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: _buildHorizontalStationCard(station, context),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            // Top by Location (local stations) – below Top English, same style
            if (controller.topLocalStations.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  title: AppStrings.topLocalStations,
                  context: context,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: controller.topLocalStations.length,
                    itemBuilder: (context, index) {
                      final station = controller.topLocalStations[index];
                      return SizedBox(
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: _buildHorizontalStationCard(station, context),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            // All channels heading
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                title: AppStrings.allChannels,
                context: context,
              ),
            ),
            // Grid: 4 columns
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final station = controller.allChannels[index];
                    return _buildGridStationCard(station, context);
                  },
                  childCount: controller.allChannels.length,
                ),
              ),
            ),
            // See more button – only after 72 items when more pages exist
            if (controller.allChannels.length >= 72 && controller.hasMoreChannels.value)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Center(
                    child: controller.isLoadingMore.value
                        ? const SizedBox(
                            height: 44,
                            child: Center(child: CircularLoader(size: 28)),
                          )
                        : TextButton.icon(
                            onPressed: controller.loadMoreChannels,
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text(AppStrings.seeMore),
                          ),
                  ),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: bottomInset + 16)),
          ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
      ),
    );
  }

  Widget _buildHorizontalStationCard(RadioStation station, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          showLoadingDialog(context, message: 'Loading station...');
          try {
            await Future.delayed(const Duration(milliseconds: 500));
            if (context.mounted) hideLoadingDialog(context);
            await controller.playStation(station);
          } catch (e) {
            if (context.mounted) hideLoadingDialog(context);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 160 * 0.7,
                  width: double.infinity,
                  child: station.logo != null && station.logo!.isNotEmpty
                      ? Image.network(
                          station.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _stationImagePlaceholder(context),
                        )
                      : _stationImagePlaceholder(context),
                ),
                SizedBox(
                  height: 160 * 0.3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        station.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridStationCard(RadioStation station, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          showLoadingDialog(context, message: 'Loading station...');
          try {
            await Future.delayed(const Duration(milliseconds: 500));
            if (context.mounted) hideLoadingDialog(context);
            await controller.playStation(station);
          } catch (e) {
            if (context.mounted) hideLoadingDialog(context);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 7,
                  child: station.logo != null && station.logo!.isNotEmpty
                      ? Image.network(
                          station.logo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _stationImagePlaceholder(context),
                        )
                      : _stationImagePlaceholder(context),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        station.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stationImagePlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
      child: Icon(
        Icons.radio_rounded,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
