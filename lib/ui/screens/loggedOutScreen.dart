import 'package:findfriend/ui/widgets/google_btn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:findfriend/core/services/fb_authProvider.dart';
import '../const.dart';
import '../widgets/fb_btn.dart';

class LoggedOutScreen extends StatelessWidget {
  Fbauth _auth;

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<Fbauth>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("NearBy"), centerTitle: true),
        body: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Expanded(flex: 4, child: SizedBox()),
              InkWell(
                child: FbBtn(),
                onTap: () async {
                  try {
                    String v = await _auth.fbAuth();
                    if (v.contains("login success")) {
                      MyToast.success("login success");
                      await _auth.initUserData();
                    } else
                      MyToast.success("$v");
                  } catch (e) {
                    MyToast.success("some unknown error");
                    print(e.toString());
                  }
                },
              ),
              SizedBox(height: 40),
              InkWell(
                child: GoogleBtn(),
                onTap: () async {
                  try {
                    String v = await _auth.signInWithGoogle();
                    if (v.contains("login success")) {
                      MyToast.success("login success");
                      await _auth.initUserData();
                    } else
                      MyToast.success("$v");
                  } catch (e) {
                    MyToast.success("some unknown error");
                    print(e.toString());
                  }
                },
              ),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
    );
  }
}
