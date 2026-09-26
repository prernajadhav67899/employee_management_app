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
    apiKey: 'AIzaSyDcADH2tmSY76Z5dYn1Ln0XyN9nbWC26hc',
    appId: '1:1094907529642:web:3d3f028ac45344770b43d3',
    messagingSenderId: '1094907529642',
    projectId: 'employeemanagement-17f0d',
    authDomain: 'employeemanagement-17f0d.firebaseapp.com',
    storageBucket: 'employeemanagement-17f0d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBsEmBq7AuhInj3e3AnmiZiROvwo0ukvok',
    appId: '1:1094907529642:ios:a96c45803a4a476a0b43d3',
    messagingSenderId: '1094907529642',
    projectId: 'employeemanagement-17f0d',
    storageBucket: 'employeemanagement-17f0d.firebasestorage.app',
    iosBundleId: 'com.example.employeeManagementApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBsEmBq7AuhInj3e3AnmiZiROvwo0ukvok',
    appId: '1:1094907529642:ios:a96c45803a4a476a0b43d3',
    messagingSenderId: '1094907529642',
    projectId: 'employeemanagement-17f0d',
    storageBucket: 'employeemanagement-17f0d.firebasestorage.app',
    iosBundleId: 'com.example.employeeManagementApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDcADH2tmSY76Z5dYn1Ln0XyN9nbWC26hc',
    appId: '1:1094907529642:web:34b892043e4ba6fd0b43d3',
    messagingSenderId: '1094907529642',
    projectId: 'employeemanagement-17f0d',
    authDomain: 'employeemanagement-17f0d.firebaseapp.com',
    storageBucket: 'employeemanagement-17f0d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDBL-C23gbqvxqkl82CvKVxpc30apfRe_s',
    appId: '1:1094907529642:android:b44ede2eea1ed8350b43d3',
    messagingSenderId: '1094907529642',
    projectId: 'employeemanagement-17f0d',
    storageBucket: 'employeemanagement-17f0d.firebasestorage.app',
  );
}
