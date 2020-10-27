import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../const.dart';

class GoogleBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: MyColors.secondaryColor,
        border: Border.all(color: MyColors.primaryColor),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              height: 24,
              width: 24,
              child: SvgPicture.asset("assets/images/google-icon.svg")),
          SizedBox(width: 20),
          Text('Continue with Google',
              style: MyTextStyle.btnTextStyle.copyWith(
                  fontSize: 16,
                  color: MyColors.blackColor,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
