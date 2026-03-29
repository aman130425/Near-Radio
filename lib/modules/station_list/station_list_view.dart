import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/widgets/glass_card.dart';
import '../../app/widgets/glass_container.dart';
import '../../app/widgets/loading_overlay.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/radio_station.dart';
import '../../core/services/audio_service.dart';
import 'package:near_radio/controllers/station_list_controller.dart';
import 'package:near_radio/controllers/favourites_controller.dart';
import 'package:near_radio/core/utils/country_utils.dart';
import 'package:near_radio/core/utils/loader_widgets.dart';
import 'package:near_radio/core/constants/app_constants.dart';
import 'package:near_radio/app/widgets/station_logo_image.dart';

/// Station list screen view
class StationListView extends GetView<StationListController> {
  const StationListView({super.key});

  static const double _headerContentHeight = 120;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).size.height * 0.1;
    final overlayHeight = topInset + _headerContentHeight;
    final bottomInset = AppConstants.mainViewBottomInset;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Obx(() {
            final slivers = <Widget>[
              SliverToBoxAdapter(child: SizedBox(height: overlayHeight)),
              if (controller.isLoading.value)
                const SliverFillRemaining(
                  child: Center(child: CircularLoader()),
                )
              else if (controller.errorMessage.value.isNotEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.loadStations,
                          child: const Text(AppStrings.retry),
                        ),
                      ],
                    ),
                  ),
                )
              else if (controller.displayList.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (controller.selectedItem.value.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: controller.goBack,
                        ),
                        Expanded(
                          child: Text(
                            controller.selectedItem.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (controller.isLoadingFilteredStations.value)
                  const SliverFillRemaining(
                    child: Center(child: CircularLoader()),
                  )
                else ...[
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: bottomInset + 8),
                    sliver: SliverList.builder(
                      itemCount: controller.displayList.length,
                      itemBuilder: (context, index) {
                        final station = controller.displayList[index] as RadioStation;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: _buildStationCard(station, context),
                        );
                      },
                    ),
                  ),
                  if (controller.hasMoreFilteredStations.value)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Center(
                          child: controller.isLoadingMoreFiltered.value
                              ? const SizedBox(
                                  height: 44,
                                  child: Center(child: CircularLoader(size: 28)),
                                )
                              : TextButton.icon(
                                  onPressed: controller.loadMoreFilteredStations,
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: Text(AppStrings.seeMore),
                                ),
                        ),
                      ),
                    ),
                ],
              ]
              else ...[
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: bottomInset + 8,
                  ),
                  sliver: SliverList.builder(
                    itemCount: controller.displayList.length,
                    itemBuilder: (context, index) {
                      final item = controller.displayList[index] as ItemWithCount;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildItemCard(item, context),
                      );
                    },
                  ),
                ),
              ],
              SliverToBoxAdapter(child: SizedBox(height: bottomInset + 8)),
            ];
            return buildRefreshableScrollView(
              onRefresh: () async {
                if (controller.selectedItem.value.isEmpty) {
                  await controller.loadFilterData();
                } else {
                  await controller.loadStationsForFilter();
                }
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: slivers,
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
                _buildTabButtons(context),
                const SizedBox(height: 4),
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

  Widget _buildTabButtons(BuildContext context) {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        borderRadius: 16,
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                context,
                _tabLabel('Country', controller.totalCountries.value),
                TabType.country,
                controller.selectedTab.value == TabType.country,
              ),
            ),
            Expanded(
              child: _buildTabButton(
                context,
                _tabLabel('Genre', controller.totalCategories.value),
                TabType.genre,
                controller.selectedTab.value == TabType.genre,
              ),
            ),
            Expanded(
              child: _buildTabButton(
                context,
                _tabLabel('Language', controller.totalLanguages.value),
                TabType.language,
                controller.selectedTab.value == TabType.language,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  String _tabLabel(String name, int total) {
    return total > 0 ? '$name ($total)' : name;
  }

  Widget _buildTabButton(BuildContext context, String label, TabType tab, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.selectTab(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: 15,
              child: Obx(() => TextField(
                onChanged: controller.searchStations,
                decoration: InputDecoration(
                  hintText: AppStrings.searchStations,
                  border: InputBorder.none,
                  icon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            controller.searchQuery.value = '';
                            controller.searchStations('');
                          },
                        )
                      : null,
                ),
              )),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => GlassContainer(
            padding: const EdgeInsets.all(10),
            borderRadius: 15,
            child: GestureDetector(
              onTap: () => _showFilterDialog(context),
              child: Icon(
                Icons.filter_list_rounded,
                color: controller.selectedFilter.value != FilterType.default_
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => _buildFilterOption(
              context,
              'Default',
              FilterType.default_,
              controller.selectedFilter.value == FilterType.default_,
            )),
            Obx(() => _buildFilterOption(
              context,
              'A - Z',
              FilterType.aToZ,
              controller.selectedFilter.value == FilterType.aToZ,
            )),
            Obx(() => _buildFilterOption(
              context,
              'Z - A',
              FilterType.zToA,
              controller.selectedFilter.value == FilterType.zToA,
            )),
            Obx(() => _buildFilterOption(
              context,
              'Number',
              FilterType.number,
              controller.selectedFilter.value == FilterType.number,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String label,
    FilterType filter,
    bool isSelected,
  ) {
    return ListTile(
      title: Text(label),
      leading: Radio<FilterType>(
        value: filter,
        groupValue: controller.selectedFilter.value,
        onChanged: (value) {
          if (value != null) {
            controller.setFilter(value);
            Navigator.pop(context);
          }
        },
      ),
      onTap: () {
        controller.setFilter(filter);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildItemCard(ItemWithCount item, BuildContext context) {
    final tab = controller.selectedTab.value;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      borderRadius: 12,
      onTap: () => controller.selectItem(item),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          children: [
            _buildItemLeading(tab, item.name, context),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${item.count}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemLeading(TabType tab, String name, BuildContext context) {
    const size = 48.0;
    final boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
    );
    if (tab == TabType.country) {
      final flagUrl = getCountryFlagImageUrlFromName(name);
      final flagEmoji = countryNameToFlagEmoji(name);
      return Container(
        width: size,
        height: size,
        decoration: boxDecoration,
        clipBehavior: Clip.antiAlias,
        child: flagUrl != null
            ? Image.network(
                flagUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _flagFallback(context, flagEmoji, size),
              )
            : _flagFallback(context, flagEmoji, size),
      );
    }
    if (tab == TabType.language) {
      return Container(
        width: size,
        height: size,
        decoration: boxDecoration,
        alignment: Alignment.center,
        child: Icon(
          Icons.language_rounded,
          size: 28,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: boxDecoration,
      alignment: Alignment.center,
      child: Icon(
        Icons.music_note_rounded,
        size: 28,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _flagFallback(BuildContext context, String? flagEmoji, double size) {
    return flagEmoji != null
        ? Center(child: Text(flagEmoji, style: TextStyle(fontSize: size * 0.6)))
        : Icon(Icons.public_rounded, size: 28, color: Theme.of(context).colorScheme.primary);
  }

  void _showStationMenu(BuildContext context, RadioStation station, Offset tapPosition) {
    final isFavourite = controller.isFavourite(station);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        MediaQuery.of(context).size.width - tapPosition.dx,
        MediaQuery.of(context).size.height - tapPosition.dy,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.play_arrow_rounded),
              const SizedBox(width: 12),
              const Text('Play'),
            ],
          ),
          onTap: () async {
            // Close menu first
            Navigator.pop(context);
            // Show loading dialog
            showLoadingDialog(context, message: 'Loading station...');
            try {
              // Wait for 2 seconds before navigation
              await Future.delayed(const Duration(seconds: 2));
              
              // Hide loading dialog before navigation
              if (context.mounted) {
                hideLoadingDialog(context);
              }
              
              // Then navigate and play
              await controller.playStation(station);
            } catch (e) {
              // Error is handled in controller
              if (context.mounted) {
                hideLoadingDialog(context);
              }
            }
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                isFavourite ? Icons.favorite : Icons.favorite_border,
                color: isFavourite ? Colors.red : null,
              ),
              const SizedBox(width: 12),
              Text(isFavourite ? 'Remove from Favourites' : 'Add to Favourites'),
            ],
          ),
          onTap: () {
            Future.delayed(const Duration(milliseconds: 100), () {
              controller.toggleFavourite(station);
            });
          },
        ),
      ],
    );
  }

  Widget _buildStationCard(RadioStation station, BuildContext context) {
    return Obx(() {
      final isPlaying = controller.isCurrentlyPlaying(station);
      final audioService = Get.find<AudioService>();
      final isCurrentStation = audioService.currentStation.value?.id == station.id;
      
      return GlassCard(

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        borderRadius: 12,
        onTap: () async {
          // Show loading dialog
          showLoadingDialog(context, message: 'Loading station...');
          try {
            // Wait for 2 seconds before navigation
            await Future.delayed(const Duration(seconds: 2));
            
            // Hide loading dialog before navigation
            if (context.mounted) {
              hideLoadingDialog(context);
            }
            
            // Then navigate and play
            await controller.playStation(station);
          } catch (e) {
            // Error is handled in controller
            if (context.mounted) {
              hideLoadingDialog(context);
            }
          }
        },
        child: Row(
          children: [
            // Station Logo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isCurrentStation
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                border: isCurrentStation
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          station.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrentStation ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentStation
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

            if (isCurrentStation)
              Obx(() => Icon(
                audioService.isPlaying.value
                    ? Icons.equalizer
                    : Icons.pause_circle_outline,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              )),
            // Three Dot Menu Button
            Builder(
              builder: (builderContext) => IconButton(
                onPressed: () {
                  final RenderBox? renderBox = builderContext.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    final position = renderBox.localToGlobal(Offset.zero);
                    _showStationMenu(context, station, position);
                  }
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

