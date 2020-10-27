import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:findfriend/ui/screens/photo_view_screen.dart';

import 'audio_play_widget.dart';
import 'msgImg.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../const.dart';

class FriendMsgWithDate extends StatelessWidget {
  String msg, time;
  String type;
  FriendMsgWithDate({this.msg, this.time, this.type});

  @override
  Widget build(BuildContext context) {
    var casttime = DateTime.parse(time).toLocal();
    var yMDFormatter = DateFormat.yMMMMd();
    var yMD = yMDFormatter.format(casttime);
    var formatter = new DateFormat.jm();
    String formattedDate = formatter.format(casttime);

    return Column(
      key: UniqueKey(),
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(yMD, style: MyTextStyle.cardFooterStyle),
        ConfigurableExpansionTile(
          header: Flexible(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(bottom: 4, top: 4, right: 80),
                padding: EdgeInsets.only(left: 16, top: 4, right: 8, bottom: 4),
                decoration: BoxDecoration(
                  color: MyColors.secondaryColor,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: type == 'text'
                    ? Text(
                        msg ?? '',
                        textAlign: TextAlign.justify,
                        style: MyTextStyle.paragraphStyle
                            .copyWith(color: MyColors.blackColor),
                      )
                    : type == 'audio'
                        ? AudioPlayWidget(url: msg)
                        : InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PhotoViewScreen(url: msg),
                                    fullscreenDialog: true),
                              );
                            },
                            child: MsgImg(url: msg)),
              ),
            ),
          ),
          children: [
            Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 16),
                child: Text(formattedDate, style: MyTextStyle.cardFooterStyle)),
          ],
        ),
      ],
    );
  }
}
