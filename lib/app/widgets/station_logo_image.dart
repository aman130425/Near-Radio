import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// True when [url] is very likely an SVG — raster [Image.network] fails on Android for these.
bool looksLikeSvgImageUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return false;
  final lower = trimmed.toLowerCase();
  if (lower.startsWith('data:image/svg+xml')) return true;
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return false;
  final path = uri.path.toLowerCase();
  if (path.endsWith('.svg') || path.endsWith('.svgz')) return true;
  if (lower.contains('.svg?')) return true;
  return false;
}

/// Station artwork: SVG via [SvgPicture.network], everything else via [Image.network].
class StationLogoImage extends StatelessWidget {
  const StationLogoImage({
    super.key,
    required this.url,
    required this.errorWidget,
    this.fit = BoxFit.cover,
  });

  final String url;
  final Widget errorWidget;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (looksLikeSvgImageUrl(url)) {
      return SizedBox.expand(
        child: SvgPicture.network(
          url,
          fit: fit,
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          placeholderBuilder: (_) => errorWidget,
        ),
      );
    }
    return Image.network(
      url,
      fit: fit,
      alignment: Alignment.center,
      gaplessPlayback: true,
      filterQuality: FilterQuality.low,
      errorBuilder: (_, _, _) => errorWidget,
    );
  }
}
