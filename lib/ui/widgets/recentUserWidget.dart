import 'package:findfriend/core/models/chatModel.dart';
import 'package:findfriend/core/models/user.dart';
import 'package:findfriend/core/services/fb_authProvider.dart';
import 'package:findfriend/ui/screens/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'web_or_svg_image.dart';

class RecentUserWidget extends StatelessWidget {
  Chat chat;
  RecentUserWidget({@required this.chat});

  @override
  Widget build(BuildContext context) {
    Fbauth auth = Provider.of<Fbauth>(context, listen: false);
    User me = auth.getMe;
    bool isMe = chat.me.id == me.id;
    User friend = isMe ? chat.friend : chat.me;
    var casttime = DateTime.parse(chat.time).toLocal();
    var formatter = new DateFormat.jm();
    String formattedDate = formatter.format(casttime);

    return Card(
      elevation: 1.0,
      color: Colors.white,
      margin: EdgeInsets.only(top: 4, right: 4, left: 4),
      child: ListTile(
        // contentPadding: EdgeInsets.all(4),
        onTap: () async {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatScreen(friend: friend)));
        },
        leading: friend.profilePicture != null
            ? WebOrSvgImage(url: friend.profilePicture)
            : Icon(Icons.account_circle),
        title: Text(friend.displayName ?? "",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        subtitle: isMe
            ? Text(chat.type == 'text' ? 'You: ' + chat.text : "You send image",
                maxLines: 1, style: TextStyle(fontSize: 14))
            : Text(chat.type == 'text' ? chat.text : "image",
                style: TextStyle(fontSize: 14)),
        trailing: Text('${formattedDate}\n'),
      ),
    );
  }
}
