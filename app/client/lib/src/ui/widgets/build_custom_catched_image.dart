import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/webService.dart';

class BuildCachedNetworkImage extends StatelessWidget {
  final double height;
  final double width;
  final String url;
  final Widget? errorWidget;
  final String? errorImgUrl;
  final double radius;

  const BuildCachedNetworkImage(
      {super.key,
      required this.height,
      required this.width,
      required this.url,
      this.errorWidget,
      this.errorImgUrl,
      required this.radius});

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = (width * dpr).round().clamp(64, 1200);
    final cacheH = (height * dpr).round().clamp(64, 1200);
    final resolved = WebService.resolveImageUrl(url);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: url == "" || url.isEmpty
              ? errorWidget ??
                  Image.asset(AppAssets.galleryPlaceholder,
                      width: width, fit: BoxFit.cover)
              : CachedNetworkImage(
                  alignment: Alignment.center,
                  imageUrl: resolved,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  filterQuality: FilterQuality.low,
                  memCacheWidth: cacheW,
                  memCacheHeight: cacheH,
                  maxWidthDiskCache: cacheW,
                  maxHeightDiskCache: cacheH,
                  placeholder: (context, url) => ColoredBox(
                        color: const Color(0xFF2A262E),
                        child: SizedBox(height: height, width: width),
                      ),
                  errorWidget: (context, url, error) =>
                      errorWidget ??
                      Image.asset(AppAssets.galleryPlaceholder,
                          width: width, fit: BoxFit.cover))),
    );
  }
}
