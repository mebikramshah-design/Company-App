// Placeholder Firebase options.
// Replace this file by running `flutterfire configure` once you have created
// the Firebase project (Auth, Firestore, Storage, Messaging enabled).
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'darwish-interserve',
    storageBucket: 'darwish-interserve.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'darwish-interserve',
    storageBucket: 'darwish-interserve.appspot.com',
    iosBundleId: 'com.darwishinterserve.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'darwish-interserve',
    authDomain: 'darwish-interserve.firebaseapp.com',
    storageBucket: 'darwish-interserve.appspot.com',
  );
}
