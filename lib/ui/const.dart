import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

class MyColors {
  static const Color primaryColor = Color(0xFF0601FD);
  static const Color secondaryColor = Color(0xFFE1EAF9);
  static const Color subBrandColor = Color(0xFFFF7300);
  static const Color greyDarkColor = Color(0xFF9F9FB7);
  static const Color greyLightkColor = Color(0xFFF0F4FD);
  static const Color blackColor = Color(0xFF0F1137);
  static const Color verifykColor = Color(0xFFB2DD4C);
  static const Color offerCardColor = Color(0xFFECEDEF);
  static const Color greenColor = Color(0xFF16E600);
  static const Color errorColor = Color(0xFFEA0001);
}

class MyTextStyle {
  static TextStyle btnTextStyle = TextStyle(
    color: MyColors.blackColor,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.0125,
    height: 1.285,
    fontSize: 14,
  );
  static TextStyle cardFooterStyle = TextStyle(
    color: MyColors.greyDarkColor,
    letterSpacing: 0.015,
    height: 1.3,
    fontSize: 10,
  );

  static TextStyle paragraphStyle = TextStyle(
    color: MyColors.greyDarkColor,
    letterSpacing: 0.0025,
    height: 1.57,
    fontSize: 14,
  );
}

class MyToast {
  static ProgressDialog progressDialog;

  static success(String msg) {
    return Fluttertoast.showToast(
        msg: "$msg",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white70,
        textColor: Colors.black,
        fontSize: 14.0);
  }

  static error(String msg) {
    return Fluttertoast.showToast(
        msg: "$msg",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white70,
        textColor: Colors.redAccent,
        fontSize: 14.0);
  }

  static progetssStart({BuildContext context, msg = 'loading...'}) {
    progressDialog = new ProgressDialog(context, isDismissible: false);
    progressDialog.style(message: msg);
    progressDialog.show();
  }

  static progressStop() {
    progressDialog.hide();
  }
}

String getNameTruncate(var value, {int len = 40}) {
  if (value == null) {
    return 'no name';
  } else if (value.toString().length > len) {
    return value.toString().substring(0, len) + ' ...';
  } else
    return value.toString();
}

String getUniqueId(String i1, String i2) {
  if (i1.compareTo(i2) <= -1)
    return i1 + "@" + i2;
  else
    return i2 + "@" + i1;
}
