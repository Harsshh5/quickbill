import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quickbill/views/masters/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

SharedPreferences? pref;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  pref = await SharedPreferences.getInstance();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Or any color you want
    statusBarIconBrightness: Brightness.dark, // This makes icons dark
  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quick Bill',
        theme: ThemeData(
          fontFamily: 'quicksand',
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: Home(),
      );
  }
}