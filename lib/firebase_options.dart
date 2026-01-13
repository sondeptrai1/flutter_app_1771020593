import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'This platform is not supported.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDaKOJuCutDBRS1iauqpBPtsi_OgMRijm8",
    authDomain: "fir-cfaff.firebaseapp.com",
    projectId: "fir-cfaff",
    storageBucket: "fir-cfaff.firebasestorage.app",
    messagingSenderId: "56097614418",
    appId: "1:56097614418:web:7bca905db5697ce407cd8b",
    measurementId: "G-TQE53YHR6H",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDaKOJuCutDBRS1iauqpBPtsi_OgMRijm8",
    appId: "1:56097614418:android:replace_me",
    messagingSenderId: "56097614418",
    projectId: "fir-cfaff",
    storageBucket: "fir-cfaff.firebasestorage.app",
  );
}
