import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WebOrSvgImage extends StatelessWidget {
  WebOrSvgImage({this.svg, this.url});

  String svg;
  String url;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: _getImage(),
    );
  }

  Widget _getImage() {
    if (url != null) {
      return SizedBox(
        height: 50,
        width: 50,
        child: CachedNetworkImage(
          imageUrl: url,
          placeholder: (context, url) => Center(
              child: SizedBox(
                  height: 20, width: 20, child: CircularProgressIndicator())),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      );
    }
    if (svg != null) {
      return SvgPicture.asset(svg, fit: BoxFit.fill);
    }
    throw ArgumentError('No placeholderAsset or file was provided');
  }
}
