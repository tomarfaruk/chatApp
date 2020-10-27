import 'package:findfriend/core/services/fb_authProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/adMobService.dart';
import 'core/services/findUserByLocationProvider.dart';
import 'ui/route.dart';
import 'ui/screens/homeScreen.dart';
import 'ui/screens/loggedOutScreen.dart';
import 'ui/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Ads.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Fbauth>(create: (context) => Fbauth()),
        ChangeNotifierProvider(
            create: (context) => FindUserByLocationProvider()),
      ],
      child: Consumer<Fbauth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: auth.isLogin
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.tryLogin(),
                  builder: (ct, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return SplashScreen();
                    if (snapshot.connectionState == ConnectionState.done) {
                      return LoggedOutScreen();
                    }
                    return LoggedOutScreen();
                  },
                ),
          onGenerateRoute: Router.generateRoute,
        ),
      ),
    );
  }
}
