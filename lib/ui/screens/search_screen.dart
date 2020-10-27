import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findfriend/core/services/search_user.dart';
import 'package:findfriend/ui/widgets/userWidget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String name = "S";
  SearchUser searchUser = SearchUser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Card(
            child: TextField(
              decoration: InputDecoration(hintText: '   User Name ...'),
              onChanged: (val) {
                name = val;
                searchUser.listentUser(name.isEmpty ? 'a' : name);
              },
            ),
          ),
        ),
        body: StreamBuilder(
            stream: searchUser.listentUser(name.isEmpty ? 'a' : name),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data.length == 0) {
                return Center(child: Text("no user found"));
              }
              if (snapshot.hasError) {
                return Center(child: Text("Some error"));
              }

              return ListView(
                children: [
                  ...snapshot.data.map((d) => UserWidget(friend: d)),
                  SizedBox(height: 65),
                ],
              );
            }));
  }
}
