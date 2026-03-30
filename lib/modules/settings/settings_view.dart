import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/widgets/glass_card.dart';
import '../../core/constants/app_strings.dart';
import 'package:near_radio/controllers/settings_controller.dart';

/// Settings screen view
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  AppStrings.settings,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                centerTitle: true,
              ),
            ),

            // Settings List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Theme Toggle
                    _buildSettingCard(
                      context: context,
                      title: AppStrings.theme,
                      subtitle: Obx(() => Text(
                        controller.isDarkMode 
                          ? AppStrings.darkMode 
                          : AppStrings.lightMode,
                      )),
                      leading: const Icon(Icons.palette_rounded),
                      trailing: Obx(() => Switch(
                        value: controller.isDarkMode,
                        onChanged: (_) => controller.toggleTheme(),
                      )),
                    ),

                    const SizedBox(height: 16),

                    // Notifications Toggle
                    _buildSettingCard(
                      context: context,
                      title: AppStrings.notifications,
                      subtitle: const Text('Enable push notifications'),
                      leading: const Icon(Icons.notifications_rounded),
                      trailing: Obx(() => Switch(
                        value: controller.notificationsEnabled.value,
                        onChanged: controller.toggleNotifications,
                      )),
                    ),

                    const SizedBox(height: 32),

                    // About Section
                    _buildSettingCard(
                      context: context,
                      title: AppStrings.about,
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.aboutDesc),
                          const SizedBox(height: 8),
                          Obx(
                            () => Text(
                              '${AppStrings.appVersion}: ${controller.packageVersionLine.value.isEmpty ? '…' : controller.packageVersionLine.value}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      leading: const Icon(Icons.info_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required String title,
    required Widget subtitle,
    required Icon leading,
    Widget? trailing,
  }) {
    return GlassCard(
      child: Row(
        children: [
          leading,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  child: subtitle,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing,
          ],
        ],
      ),
    );
  }
}

