import 'package:findfriend/core/models/user.dart';
import 'package:flutter/material.dart';
import 'web_or_svg_image.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User friend;
  AppBar appBar;
  ChatAppBar({this.friend, this.appBar});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            color: Theme.of(context).primaryColor,
          ),
          friend.profilePicture != null
              ? WebOrSvgImage(url: friend.profilePicture)
              : Icon(Icons.account_circle,
                  color: Theme.of(context).primaryColor),
          Flexible(
            child: Container(
              padding: EdgeInsets.only(left: 8.00),
              child: Text(
                friend.displayName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal),
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        InkWell(
            child: Icon(Icons.call, color: Theme.of(context).primaryColor),
            onTap: () {}),
        SizedBox(width: 14),
        InkWell(
            child: Icon(Icons.videocam, color: Theme.of(context).primaryColor),
            onTap: () {}),
        PopupMenuButton(
          itemBuilder: (context) =>
              [PopupMenuItem(child: Text("Info"), value: "Info")],
          icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
        )
      ],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}
