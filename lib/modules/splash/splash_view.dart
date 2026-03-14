import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_pages.dart';
import '../../core/utils/loader_widgets.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';

/// Splash screen shown on every app launch. Navigates to onboarding or main.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    final hasSeenOnboarding = StorageService.hasSeenOnboarding();
    if (hasSeenOnboarding) {
      Get.offAllNamed(Routes.main);
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.25),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: CircularLoader(size: 32),
              ),
              Image.asset(
                'assets/icons/app_logo2.png',
                width: MediaQuery.of(context).size.width*0.7,
                height: MediaQuery.of(context).size.width*0.7,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.radio_rounded,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
