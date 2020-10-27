import 'package:findfriend/core/models/user.dart';
import 'package:flutter/material.dart';

import 'web_or_svg_image.dart';

class Header extends StatelessWidget {
  final User friend;
  Header({this.friend});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
      child: Column(
        children: <Widget>[
          friend.profilePicture != null
              ? WebOrSvgImage(url: friend.profilePicture)
              : Icon(Icons.account_circle),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              friend.displayName,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              "${friend.id}",
              style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
