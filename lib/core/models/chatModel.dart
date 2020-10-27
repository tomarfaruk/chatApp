import 'user.dart';

class Chat {
  User friend;
  User me;
  String msgId;
  String text;
  String time;
  String type;

  Chat({this.friend, this.me, this.msgId, this.text, this.time, this.type});

  Chat.fromJson(Map<String, dynamic> json) {
    friend = User.fromJson(json['friend']);
    me = User.fromJson(json['me']);
    msgId = json['msgId'];
    text = json['text'];
    time = json['time'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['friend'] = this.friend.toJson();
    data['me'] = this.me.toJson();
    data['msgId'] = this.msgId;
    data['text'] = this.text;
    data['time'] = this.time;
    data['type'] = this.type;
    return data;
  }
}
