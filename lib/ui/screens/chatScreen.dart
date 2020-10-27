import 'package:findfriend/core/models/chatModel.dart';
import 'package:findfriend/core/models/user.dart';
import 'package:findfriend/core/services/fb_authProvider.dart';
import 'package:findfriend/core/services/firestore.dart';
import 'package:findfriend/ui/widgets/friendMsgWithDate.dart';
import 'package:findfriend/ui/widgets/myMsgWithDate.dart';
import 'package:intl/intl.dart';
import '../widgets/friendMsg.dart';
import '../widgets/chatAppBar.dart';
import '../widgets/myMsg.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/chat_input_widget.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = "/ChatScreen";
  final User friend;
  ChatScreen({this.friend});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();

    auth = Provider.of<Fbauth>(context, listen: false);
    currentUser = auth.getMe;
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      firestoreService.requestMoreData(currentUser, widget.friend);
    }
  }

  FirestoreService firestoreService = FirestoreService();

  Fbauth auth;
  ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: ChatAppBar(friend: widget.friend, appBar: AppBar()),
      body: Column(
        children: <Widget>[
          Flexible(child: buildChats()),
          ChatInputWidget(
            onSubmitted: (value, type) async {
              Chat msg = Chat(
                  text: value,
                  type: type,
                  time: DateTime.now().toUtc().toString(),
                  friend: widget.friend,
                  me: currentUser);
              await firestoreService.sendMessage(msg);
            },
          )
        ],
      ),
    );
  }

  Widget buildChats() {
    return StreamBuilder(
      stream:
          firestoreService.listenToPostsRealTime(currentUser, widget.friend),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data.length == 0) {
          return Center(child: Text("Start conversation"));
        }

        if (snapshot.hasError) {
          return Center(child: Text("Some error"));
        }

        List<Chat> data = snapshot.data;
        return ListView.builder(
          controller: scrollController,
          reverse: true,
          itemCount: data.length,
          itemBuilder: (context, index) {
            Chat chat = data[index];
            if (data.length - 1 == index) {
              //if it is last mesg
              if (chat.me.id == currentUser.id) {
                return MyMsgWithDate(
                    msg: chat.text, time: chat.time, type: chat.type);
              }
              return FriendMsgWithDate(
                  msg: chat.text, time: chat.time, type: chat.type);
            } else {
              Chat prevChat = data[index + 1];

              if (isSameDate(chat.time, prevChat.time)) {
                //if current and next msg date same
                if (chat.me.id == currentUser.id) {
                  return MyMsg(
                      msg: chat.text, time: chat.time, type: chat.type);
                }
                return Container(
                  alignment: Alignment.centerLeft,
                  child: FriendMsg(
                      msg: chat.text, time: chat.time, type: chat.type),
                );
              } else {
                //if current and next msg date not same
                if (chat.me.id == currentUser.id) {
                  return MyMsgWithDate(
                      msg: chat.text, time: chat.time, type: chat.type);
                }
                return FriendMsgWithDate(
                    msg: chat.text, time: chat.time, type: chat.type);
              }
            }
          },
        );
      },
    );
  }

  bool isSameDate(String curDate, String prevDate) {
    DateTime dateCurrent = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(curDate);
    DateTime datePrev = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(prevDate);

    final diff = dateCurrent.difference(datePrev).inDays;
    return diff == 0 && dateCurrent.day == datePrev.day;
  }
}
