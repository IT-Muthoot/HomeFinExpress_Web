import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'HomePageView.dart';
import 'LoginPageView.dart';
import 'PrivacyPolicy.dart';
import 'SplashView.dart';
import 'TermsAndCondition.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeFin Express',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:
     //HomePageView(),
     SplashView(),
    );
  }
}

