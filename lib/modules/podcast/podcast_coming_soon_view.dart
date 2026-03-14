import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Placeholder for Podcast tab – coming soon.
class PodcastComingSoonView extends StatelessWidget {
  const PodcastComingSoonView({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).size.height * 0.08;
    final bottomInset = AppConstants.mainViewBottomInset;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.podcasts_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Coming soon',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Podcast feature is under development',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
