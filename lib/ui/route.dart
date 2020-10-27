import 'package:findfriend/core/models/user.dart';
import 'package:flutter/material.dart';
import 'screens/homeScreen.dart';
import 'screens/splash_screen.dart';
import 'screens/chatScreen.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case ChatScreen.routeName:
        User friend = settings.arguments;
        return MaterialPageRoute(builder: (_) => ChatScreen(friend: friend));

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
