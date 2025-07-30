import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
    apiKey: 'AIzaSyDGxYfNSkDIY8tABUMYMSobgCMMvrhx8gs',
    appId: '1:752699470468:web:a1b462b7dbc4c80b2988d1',
    messagingSenderId: '752699470468',
    projectId: 'finbuddy-b0763',
    authDomain: 'finbuddy-b0763.firebaseapp.com',
    storageBucket: 'finbuddy-b0763.firebasestorage.app',
    measurementId: 'G-WVKGEW3K1Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmdGEqAsBjZaNIAT32o4xjeTApcVgNtzg',
    appId: '1:752699470468:android:3257be7bd14be66e2988d1',
    messagingSenderId: '752699470468',
    projectId: 'finbuddy-b0763',
    storageBucket: 'finbuddy-b0763.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC5OrQuKehClVsJ-UYUTpFMSGExs0YtY60',
    appId: '1:752699470468:ios:991498026191fc0c2988d1',
    messagingSenderId: '752699470468',
    projectId: 'finbuddy-b0763',
    storageBucket: 'finbuddy-b0763.firebasestorage.app',
    iosClientId: '752699470468-m7gdq6m8bt1g9ca4jlmp3c7b11nn04s0.apps.googleusercontent.com',
    iosBundleId: 'com.example.finbuddy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC5OrQuKehClVsJ-UYUTpFMSGExs0YtY60',
    appId: '1:752699470468:ios:991498026191fc0c2988d1',
    messagingSenderId: '752699470468',
    projectId: 'finbuddy-b0763',
    storageBucket: 'finbuddy-b0763.firebasestorage.app',
    iosClientId: '752699470468-m7gdq6m8bt1g9ca4jlmp3c7b11nn04s0.apps.googleusercontent.com',
    iosBundleId: 'com.example.finbuddy',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDGxYfNSkDIY8tABUMYMSobgCMMvrhx8gs',
    appId: '1:752699470468:web:eacd15043c878c9e2988d1',
    messagingSenderId: '752699470468',
    projectId: 'finbuddy-b0763',
    authDomain: 'finbuddy-b0763.firebaseapp.com',
    storageBucket: 'finbuddy-b0763.firebasestorage.app',
    measurementId: 'G-YV30Z7P3ER',
  );
}
