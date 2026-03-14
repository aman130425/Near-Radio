import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import '../../core/utils/loader_widgets.dart';

/// Screen that fetches HTML from a URL and renders it in-app (no WebView).
/// Used for Terms & Conditions, Privacy Policy, etc.
class HtmlContentScreen extends StatefulWidget {
  const HtmlContentScreen({
    super.key,
    required this.url,
    required this.title,
  });

  final String url;
  final String title;

  @override
  State<HtmlContentScreen> createState() => _HtmlContentScreenState();
}

class _HtmlContentScreenState extends State<HtmlContentScreen> {
  bool _loading = true;
  String? _html;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      final response = await http
          .get(Uri.parse(widget.url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        setState(() {
          _html = response.body;
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = 'Failed to load (${response.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Unable to load content. Please check your connection.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        titleSpacing: 0,
        leadingWidth: 48,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(48, 48),
          ),
        ),
        title: Text(widget.title),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(
        child: CircularLoader(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _fetchContent();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_html == null || _html!.isEmpty) {
      return const Center(child: Text('No content available.'));
    }

    final textColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface.withOpacity(0.95)
        : theme.colorScheme.onSurface.withOpacity(0.92);
    final headingColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.onSurface
        : const Color(0xFF1A1A2E);

    return buildRefreshableScrollView(
      onRefresh: _fetchContent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
        child: Html(
        data: _html!,
        shrinkWrap: true,
        style: {
          'body': Style(
            color: textColor,
            fontSize: FontSize(15),
            fontWeight: FontWeight.w500,
          ),
          'p': Style(color: textColor, fontWeight: FontWeight.w500),
          'h1': Style(
            color: headingColor,
            fontSize: FontSize(20),
            fontWeight: FontWeight.bold,
          ),
          'h2': Style(
            color: headingColor,
            fontSize: FontSize(17),
            fontWeight: FontWeight.w600,
          ),
          'h3': Style(
            color: headingColor,
            fontSize: FontSize(15),
            fontWeight: FontWeight.w600,
          ),
          'li': Style(color: textColor, fontWeight: FontWeight.w500),
          'a': Style(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        },
      ),
      ),
    );
  }
}
