import 'package:findfriend/core/models/user.dart';
import 'package:findfriend/core/services/fb_authProvider.dart';
import 'package:findfriend/ui/widgets/msgImg.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ProgressDialog progressDialog;
  bool _status = true;
  final FocusNode myFocusNode = FocusNode();
  Fbauth auth;
  User me;
  String _name, _email, _phone, _social;
  @override
  void initState() {
    auth = Provider.of<Fbauth>(context, listen: false);
    me = auth.getMe;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = new ProgressDialog(context, isDismissible: false);
    progressDialog.style(message: 'loading...');

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text("profile View"), centerTitle: true),
        body: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            Stack(fit: StackFit.loose, children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 140.0,
                    height: 140.0,
                    child: MsgImg(url: me.profilePicture),
                  ),
                ],
              ),
              // pick image
              Padding(
                  padding: EdgeInsets.only(top: 95.0, right: 100.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          try {
                            String imageurl = await auth.uploadFile();
                            if (imageurl != null) me.profilePicture = imageurl;
                            print("yess $imageurl");
                            setState(() {});
                          } catch (e) {
                            print("some error on upload image");
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 25.0,
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      )
                    ],
                  )),
            ]),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //edit action
                  Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              new Text(
                                'Parsonal Information',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          new Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              _status ? _getEditIcon() : new Container(),
                            ],
                          )
                        ],
                      )),
                  //user name
                  Padding(
                    padding:
                        EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                    child: Text('Your name',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                      child: new Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          new Flexible(
                            child: new TextFormField(
                              initialValue: me.displayName,
                              onSaved: (value) => _name = value,
                              validator: (value) {
                                if (value != null && value?.isNotEmpty)
                                  return null;
                                return "field can't empty";
                              },
                              decoration: InputDecoration(
                                  hintText: "${me.displayName}"),
                              enabled: !_status,
                              autofocus: !_status,
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                    child: Text('Email ID',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              initialValue: me.email ?? "",
                              onSaved: (value) => _email = value,
                              validator: (value) {
                                if (value != null && value?.isNotEmpty)
                                  return null;
                                return "field can't empty";
                              },
                              decoration: InputDecoration(
                                  hintText: me.email ?? "Enter Email ID"),
                              enabled: !_status,
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                    child: Text('Mobile',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              initialValue: me.phone ?? "",
                              onSaved: (value) => _phone = value,
                              validator: (value) {
                                if (value != null && value?.isNotEmpty)
                                  return null;
                                return "field can't empty";
                              },
                              decoration: InputDecoration(
                                  hintText: me.phone ?? "Enter Mobile Number"),
                              enabled: !_status,
                            ),
                          ),
                        ],
                      )),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                    child: Text('Social profile',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                      padding:
                          EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              initialValue: me.social ?? "",
                              onSaved: (value) => _social = value,
                              decoration: InputDecoration(
                                  hintText: me.social ?? "Enter social link"),
                              enabled: !_status,
                            ),
                          ),
                        ],
                      )),
                  !_status ? _getActionButtons() : Container(),
                ],
              ),
            )
          ],
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
                padding: EdgeInsets.only(right: 10.0),
                child: RaisedButton(
                  child: Text("Save"),
                  textColor: Colors.white,
                  color: Colors.green,
                  onPressed: () async {
                    _formKey.currentState.save();
                    if (_formKey.currentState.validate()) {
                      progressDialog.show();
                      try {
                        await auth.updateUserInfo(
                            _name, _email, _phone, _social);
                      } catch (e) {
                        print("user info update failed");
                      }
                      progressDialog.hide();
                      setState(() {
                        _status = true;
                        FocusScope.of(context).requestFocus(new FocusNode());
                      });
                    }
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                )),
            flex: 2,
          ),
          //cancle btn
          Expanded(
            child: Container(
                padding: EdgeInsets.only(left: 10.0),
                child: RaisedButton(
                  child: Text("Cancel"),
                  textColor: Colors.white,
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      _status = true;
                      FocusScope.of(context).requestFocus(FocusNode());
                    });
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                )),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: Colors.red,
        radius: 14.0,
        child: Icon(
          Icons.edit,
          color: Colors.white,
          size: 16.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }
}
