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
            left: 12,
            top: 12,
            child: InkWell(
              onTap: onClose,
              child: Container(
                  padding: EdgeInsets.all(size.height * 0.015),
                  decoration: const BoxDecoration(
                      color: signInButtonColor, shape: BoxShape.circle),
                  child: SvgPicture.asset(
                    AppAssets.closeIcon,
                    color: titleTextWhiteColor,
                  )),
            ))
      ],
    );
  }
}
