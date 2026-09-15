import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ink/src/utils/assets.dart';
import 'package:ink/src/utils/colors.dart';
import 'package:ink/src/utils/webService.dart';

class FixedAdCard extends StatelessWidget {
  final String ad;
  final VoidCallback onClose;

  const FixedAdCard({Key? key, required this.ad, required this.onClose})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CachedNetworkImage(
                imageUrl: WebService.resolveImageUrl(ad),
                alignment: Alignment.center,
                imageBuilder: (context, imageProvider) => Container(
                      width: size.width,
                      height: size.height,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.contain),
                      ),
                    ),
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => FutureBuilder(
                      future: Future.delayed(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return SizedBox(
                            width: size.width,
                            height: size.height,
                            child: Image.asset("assets/images/placeholder.png"),
                          );
                        } else {
                          // You can return a loader or transparent box during the wait
                          return SizedBox(
                            width: size.width,
                            height: size.height,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          );
                        }
                      },
                    )),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            right: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Material(
                color: signInButtonColor,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onClose,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: SvgPicture.asset(
                        AppAssets.closeIcon,
                        color: titleTextWhiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
