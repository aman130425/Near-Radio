import 'package:flutter/material.dart';

/// Themed circular loader for consistent loading UI across the app.
class CircularLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const CircularLoader({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Wraps [child] with RefreshIndicator for pull-to-refresh.
/// Use with CustomScrollView, ListView, etc.
Widget buildRefreshableScrollView({
  required Future<void> Function() onRefresh,
  required Widget child,
  Color? color,
}) {
  return RefreshIndicator(
    onRefresh: onRefresh,
    color: color,
    child: child,
  );
}
