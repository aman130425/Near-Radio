import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';
import '../../app/widgets/connectivity_wrapper.dart';
import '../../app/widgets/glass_bottom_nav_bar.dart';
import '../../app/widgets/mini_player.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import 'package:near_radio/controllers/settings_controller.dart';
import 'package:near_radio/controllers/main_controller.dart';
import '../home/home_view.dart';
import '../station_list/station_list_view.dart';
import '../podcast/podcast_coming_soon_view.dart';
import '../favourites/favourites_view.dart';
import 'package:near_radio/controllers/local_music_controller.dart';
import '../local_music/local_music_view.dart';
import '../content/html_content_screen.dart';

/// Main view with app bar (drawer, app name, search), drawer (settings), bottom nav (Home, Radio, Podcast, Local, Favourite)
class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scrimColor = isDark
        ? Colors.black.withOpacity(0.92)
        : Colors.white.withOpacity(0.92);

    return UpgradeAlert(
      child: Obx(() => Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          _appBarTitle(controller.currentIndex.value),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (controller.currentIndex.value == 3)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => Get.find<LocalMusicController>().pickMusicFiles(),
              tooltip: 'Add Music Files',
            ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scrimColor,
                scrimColor.withOpacity(0.85),
                scrimColor.withOpacity(0.3),
                Colors.transparent,
              ],
              stops: const [0.35, 0.5, 0.785, 1.0],
            ),
          ),
        ),
      ),
        drawer: _buildDrawer(context),
        body: ConnectivityWrapper(
          child: IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeView(),
              StationListView(),
              PodcastComingSoonView(),
              LocalMusicView(),
              FavouritesView(),
            ],
          ),
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniPlayer(),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: -60,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            (isDark ? Colors.black : Colors.white).withOpacity(0.92),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                GlassBottomNavBar(
                  currentIndex: controller.currentIndex.value,
                  onTap: controller.changePage,
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  String _appBarTitle(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return AppConstants.appName;
      case 1:
        return 'Radio';
      case 2:
        return 'Podcast';
      case 3:
        return 'Local';
      case 4:
        return AppStrings.favourites;
      default:
        return AppConstants.appName;
    }
  }

  Widget _buildDrawer(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    const drawerBg = Color(0xFF1E1B2E);
    const textColor = Color(0xFFE8E6F0);

    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      AppStrings.appSetting,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 22,
                      ),
                    ),
                  ),

                  _buildDrawerRow(
                    context: context,
                    title: AppStrings.comingSoon,
                    icon: Icons.schedule_rounded,
                    iconColor: const Color(0xFF81C784),
                    onTap: () => Get.back(),
                  ),
                  _buildDrawerRow(
                    context: context,
                    title: AppStrings.termAndCondition,
                    icon: Icons.description_rounded,
                    iconColor: const Color(0xFFFFD54F),
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.to(() => HtmlContentScreen(
                            url: ApiConstants.termsConditionsUrl,
                            title: AppStrings.termAndCondition,
                          ));
                    },
                  ),
                  _buildDrawerRow(
                    context: context,
                    title: AppStrings.privacyPolicy,
                    icon: Icons.privacy_tip_rounded,
                    iconColor: const Color(0xFF4DD0E1),
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.to(() => HtmlContentScreen(
                            url: ApiConstants.privacyPolicyUrl,
                            title: AppStrings.privacyPolicy,
                          ));
                    },
                  ),
                  _buildDrawerRow(
                    context: context,
                    title: AppStrings.about,
                    icon: Icons.info_rounded,
                    iconColor: const Color(0xFFFFB74D),
                    onTap: () {
                      Navigator.of(context).pop();
                      Get.to(() => HtmlContentScreen(
                            url: ApiConstants.aboutUrl,
                            title: AppStrings.about,
                          ));
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  Text(
                    '${AppStrings.appVersion}: ${settingsController.appVersion}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'From',
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ProkximaTech',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerRow({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    const textColor = Color(0xFFE8E6F0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        leading: Icon(icon, color: iconColor, size: 26),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: textColor,
          size: 24,
        ),
        onTap: onTap,
      ),
    );
  }

}