// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyAQmT8wQbjKlGPEW5-4c85uNH_sZb85oDU',
    appId: '1:190432291509:web:23a768b7b6f752f591ecfc',
    messagingSenderId: '190432291509',
    projectId: 'malavi-stock',
    authDomain: 'malavi-stock.firebaseapp.com',
    storageBucket: 'malavi-stock.appspot.com',
    measurementId: 'G-3S8SV4DMKC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWU_bT6Izx5SDaNoq2fR1Wt-lK-OYZIjc',
    appId: '1:190432291509:android:3556bbc428701da391ecfc',
    messagingSenderId: '190432291509',
    projectId: 'malavi-stock',
    storageBucket: 'malavi-stock.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyByb7KKvvvMPjTrfHyZamHHyrOK9sis0qw',
    appId: '1:190432291509:ios:ee6b4a555a273f5291ecfc',
    messagingSenderId: '190432291509',
    projectId: 'malavi-stock',
    storageBucket: 'malavi-stock.appspot.com',
    androidClientId: '190432291509-2kv1sbmb04f9bm06jg20t15qgrjhtk3q.apps.googleusercontent.com',
    iosClientId: '190432291509-2r96jg37fa1e3cda1rveqtibf8e89lc0.apps.googleusercontent.com',
    iosBundleId: 'com.example.malaviManagement',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyByb7KKvvvMPjTrfHyZamHHyrOK9sis0qw',
    appId: '1:190432291509:ios:ee6b4a555a273f5291ecfc',
    messagingSenderId: '190432291509',
    projectId: 'malavi-stock',
    storageBucket: 'malavi-stock.appspot.com',
    androidClientId: '190432291509-2kv1sbmb04f9bm06jg20t15qgrjhtk3q.apps.googleusercontent.com',
    iosClientId: '190432291509-2r96jg37fa1e3cda1rveqtibf8e89lc0.apps.googleusercontent.com',
    iosBundleId: 'com.example.malaviManagement',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAQmT8wQbjKlGPEW5-4c85uNH_sZb85oDU',
    appId: '1:190432291509:web:103940a418f0527591ecfc',
    messagingSenderId: '190432291509',
    projectId: 'malavi-stock',
    authDomain: 'malavi-stock.firebaseapp.com',
    storageBucket: 'malavi-stock.appspot.com',
    measurementId: 'G-3958HPYSSH',
  );
}