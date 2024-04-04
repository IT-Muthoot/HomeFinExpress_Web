// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDAnDSl4To7GBkUWi2jw2Wiig7-BfMkS1c',
    appId: '1:818116081964:web:6134b735aafcea7dbe9489',
    messagingSenderId: '818116081964',
    projectId: 'lms-application-be1ea',
    authDomain: 'lms-application-be1ea.firebaseapp.com',
    storageBucket: 'lms-application-be1ea.appspot.com',
    measurementId: 'G-6BWPF79KXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCkEwNU-DwN8Lol-snkPibjSwT6vUGRjWA',
    appId: '1:818116081964:android:b6e26a12616b39d1be9489',
    messagingSenderId: '818116081964',
    projectId: 'lms-application-be1ea',
    storageBucket: 'lms-application-be1ea.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB7Gvcz0JyDRW2tbZ2wpXINOrUGyovkH6o',
    appId: '1:818116081964:ios:d871fee3f481aca3be9489',
    messagingSenderId: '818116081964',
    projectId: 'lms-application-be1ea',
    storageBucket: 'lms-application-be1ea.appspot.com',
    iosBundleId: 'com.example.leadManagementSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB7Gvcz0JyDRW2tbZ2wpXINOrUGyovkH6o',
    appId: '1:818116081964:ios:c145e9e4f250a83dbe9489',
    messagingSenderId: '818116081964',
    projectId: 'lms-application-be1ea',
    storageBucket: 'lms-application-be1ea.appspot.com',
    iosBundleId: 'com.example.leadManagementSystem.RunnerTests',
  );
}
