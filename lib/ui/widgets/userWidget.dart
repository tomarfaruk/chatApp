import 'package:findfriend/core/models/user.dart';
import 'package:findfriend/ui/screens/chatScreen.dart';
import 'package:flutter/material.dart';
import 'web_or_svg_image.dart';

class UserWidget extends StatelessWidget {
  User friend;
  UserWidget({this.friend});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      color: Colors.white,
      margin: EdgeInsets.only(top: 4, right: 4, left: 4),
      child: ListTile(
        contentPadding: EdgeInsets.all(4),
        onTap: () async {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatScreen(friend: friend)));
        },
        leading: friend.profilePicture != null
            ? WebOrSvgImage(url: friend.profilePicture)
            : Icon(Icons.account_circle),
        title: Text(friend.displayName ?? "",
            style: TextStyle(fontWeight: FontWeight.w600)),
        trailing: Icon(Icons.message),
      ),
    );
  }
}
