import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raithamithra/_utils/splashscreen.dart';
import 'package:raithamithra/pages/aboutus.dart';
import 'package:raithamithra/pages/adminPage.dart';
import 'package:raithamithra/pages/farmerPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:raithamithra/pages/invetorPage.dart';
import 'firebase_options.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken();
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  log("FCMToken $fcmToken");
  final appDocumentDirectory = await getApplicationCacheDirectory();
  Hive.init(appDocumentDirectory.path);
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ritha Mithra',
   home: const SplashScreen(),
   //    home: AdminHome(),
   // home: FarmerHome(),
   //    home: InvestorHome(),
    );
  }
}

