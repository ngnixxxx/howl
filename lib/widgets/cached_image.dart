import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String url;
  final bool isRound;
  final double radius;
  final double height;
  final double width;

  final BoxFit fit;

  final String imageNotAvailable =
      'https://firebasestorage.googleapis.com/v0/b/moon-sun-curse.appspot.com/o/no-img.png?alt=media&token=72248e1d-8d8c-4c2f-806c-3ef3b824879b';

  CachedImage(
    this.url, {
    this.isRound = true,
    this.radius = 0,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });
  @override
  Widget build(BuildContext context) {
    try {
      return SizedBox(
        height: isRound ? radius : height,
        width: isRound ? radius : width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isRound ? 50 : radius),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                Image.network(imageNotAvailable, fit: BoxFit.cover),
          ),
        ),
      );
    } catch (e) {
      return Image.network(imageNotAvailable, fit: BoxFit.cover);
    }
  }
}
