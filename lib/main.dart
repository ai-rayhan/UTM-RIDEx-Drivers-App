import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/infoHandler/app_info.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:drivers_app/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  

  //plus
  sharedPreferences = await SharedPreferences.getInstance();

  // await Firebase.initializeApp();
     initilizeOnesignal();

  runApp(
    MyApp(
      child: ChangeNotifierProvider(
        create: (context) => AppInfo(),
        child: MaterialApp(
          title: 'Driver App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const MySplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      )
    ),
  );
}
class MyApp extends StatefulWidget
{
  final Widget? child;
  MyApp({this.child});
  static void restartApp(BuildContext context)
  {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
{
  Key key = UniqueKey();
  void restartApp(){
    setState(() {
      key = UniqueKey();
    });
  }
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}

initilizeOnesignal(){
if(FirebaseAuth.instance.currentUser!=null){
    OneSignal.initialize("730ff581-8df1-415b-98da-0dab05dbd851");
  OneSignal.Notifications.addPermissionObserver((state) {
    print("Has permission $state");
  });
  OneSignal.login(FirebaseAuth.instance.currentUser!.uid);
  OneSignal.Notifications.requestPermission(true);
}
}
