import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:findfriend/ui/screens/photo_view_screen.dart';
import 'package:findfriend/ui/widgets/audio_play_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../const.dart';
import 'msgImg.dart';

class MyMsg extends StatelessWidget {
  String msg, time;
  String type;
  MyMsg({this.msg, this.time, this.type});

  @override
  Widget build(BuildContext context) {
    var casttime = DateTime.parse(time).toLocal();
    var formatter = new DateFormat.jm();
    String formattedDate = formatter.format(casttime);

    return ConfigurableExpansionTile(
      key: UniqueKey(),
      header: Flexible(
        child: Container(
          alignment: Alignment.centerRight,
          child: Container(
            margin: EdgeInsets.only(bottom: 4, top: 4, left: 80),
            padding: EdgeInsets.only(left: 8, top: 4, right: 16, bottom: 4),
            decoration: BoxDecoration(
              color: MyColors.secondaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
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
                                builder: (context) => PhotoViewScreen(url: msg),
                                fullscreenDialog: true),
                          );
                        },
                        child: MsgImg(url: msg)),
          ),
        ),
      ),
      children: [
        Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 16),
            child: Text(formattedDate, style: MyTextStyle.cardFooterStyle)),
      ],
    );
  }
}
