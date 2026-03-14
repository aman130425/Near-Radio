import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/widgets/glass_container.dart';
import '../../core/constants/app_constants.dart';
import 'package:near_radio/controllers/onboarding_controller.dart';

/// Onboarding screen shown only on first install. Get Started saves state and goes to home.
class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: [
                  _OnboardingPage(
                    icon: Icons.radio_rounded,
                    title: 'Welcome to ${AppConstants.appName}',
                    subtitle:
                        'Stream thousands of radio stations from around the world. Music, news, sports, and more.',
                  ),
                  _OnboardingPage(
                    icon: Icons.favorite_rounded,
                    title: 'Favourites & Recent',
                    subtitle:
                        'Save your favourite stations and quickly access recently played. Your music, your way.',
                  ),
                  _OnboardingPage(
                    icon: Icons.headphones_rounded,
                    title: 'Listen Anywhere',
                    subtitle:
                        'Play in the background and control playback from the notification. Enjoy radio on the go.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Obx(() {
                final isLast = controller.currentPage.value == OnboardingController.totalPages - 1;
                return SizedBox(
                  width: double.infinity,
                  child: GlassContainer(
                    borderRadius: 28,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: controller.nextPage,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        borderRadius: BorderRadius.circular(28),
                        child: Center(
                          child: Text(
                            isLast ? 'Get Started' : 'Next',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    OnboardingController.totalPages,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: controller.currentPage.value == i
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }
}
