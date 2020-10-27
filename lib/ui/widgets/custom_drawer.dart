import 'package:findfriend/core/models/user.dart';
import 'package:findfriend/core/services/fb_authProvider.dart';
import 'package:findfriend/core/services/findUserByLocationProvider.dart';
import 'package:findfriend/ui/screens/edit_profile.dart';
import 'package:findfriend/ui/screens/view_ads_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'web_or_svg_image.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  User me;
  FindUserByLocationProvider findUserByLocationProvider;
  Fbauth auth;

  @override
  void initState() {
    super.initState();

    auth = Provider.of<Fbauth>(context, listen: false);
    findUserByLocationProvider =
        Provider.of<FindUserByLocationProvider>(context, listen: false);
    me = auth.getMe;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(me?.displayName ?? ""),
            accountEmail: Text(me?.email ?? me.id),
            currentAccountPicture: CircleAvatar(
                backgroundColor:
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? Colors.blue
                        : Colors.white,
                child: WebOrSvgImage(url: me.profilePicture)),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Find your friend within ${findUserByLocationProvider.radius.toInt()} km",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.left,
                ),
              )
            ],
          ),
          Slider(
            value: findUserByLocationProvider.radius,
            onChanged: (double value) {
              findUserByLocationProvider.changeRadius(value);
              setState(() {});
            },
            label: "${findUserByLocationProvider.radius.toInt()} km",
            divisions: 100,
            max: 50,
            min: 1,
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
            },
            child: Row(children: [
              Text(" View profile", style: TextStyle(color: Colors.black)),
              Spacer(),
              Icon(Icons.remove_red_eye, color: Colors.black),
            ]),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewAdsPage()),
              );
            },
            child: Row(children: [
              Text(" Your credit: ", style: TextStyle(color: Colors.black)),
              Spacer(),
              Text("${me.rewardAd}", style: TextStyle(color: Colors.black)),
            ]),
          ),
          Spacer(),
          Align(
            alignment: Alignment.center,
            child: RaisedButton.icon(
              elevation: 0,
              color: Colors.white,
              label: Text("Log out",
                  style: TextStyle(fontSize: 14, color: Colors.black)),
              icon: Icon(Icons.power_settings_new),
              onPressed: () async {
                Navigator.pop(context);
                await auth.fbLogout();
              },
            ),
          )
        ],
      ),
    );
  }
}
