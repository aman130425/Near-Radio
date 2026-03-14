import 'package:flutter/material.dart';
import '../home/home_view.dart';
import '../station_list/station_list_view.dart';

/// Radio tab: combines Home (For You) and Stations in sub-tabs
class RadioView extends StatelessWidget {
  const RadioView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surface,
              child: TabBar(
                tabs: const [
                  Tab(text: 'For You'),
                  Tab(text: 'Stations'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  HomeView(),
                  StationListView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
