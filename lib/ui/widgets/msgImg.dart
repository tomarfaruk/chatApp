import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MsgImg extends StatelessWidget {
  MsgImg({this.url});

  String url;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: UniqueKey(),
      borderRadius: BorderRadius.circular(10.0),
      child: CachedNetworkImage(
        imageUrl: url,
        height: 250,
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(
            child: SizedBox(
                height: 20, width: 20, child: CircularProgressIndicator())),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
