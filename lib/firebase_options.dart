import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Configuración para Flutter Web basada en tu JS config
      return FirebaseOptions(
        apiKey: "AIzaSyDmTLDTrsa5Kww6k-BEvcixk26xo9yivZE",
        authDomain: "mascotas-plus-7c2fe.firebaseapp.com",
        projectId: "mascotas-plus-7c2fe",
        storageBucket: "mascotas-plus-7c2fe.firebasestorage.app",
        messagingSenderId: "392970849623",
        appId: "1:392970849623:web:39362bcea3ba874bd44212",
        measurementId: "G-CCHJK57K86",
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: "AIzaSyDmTLDTrsa5Kww6k-BEvcixk26xo9yivZE",
          appId: "1:392970849623:android:39362bcea3ba874bd44212",
          messagingSenderId: "392970849623",
          projectId: "mascotas-plus-7c2fe",
          storageBucket: "mascotas-plus-7c2fe.firebasestorage.app",
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: "AIzaSyDmTLDTrsa5Kww6k-BEvcixk26xo9yivZE",
          appId: "1:392970849623:ios:39362bcea3ba874bd44212",
          messagingSenderId: "392970849623",
          projectId: "mascotas-plus-7c2fe",
          storageBucket: "mascotas-plus-7c2fe.firebasestorage.app",
          iosBundleId: "", // reemplaza con tu Bundle ID
          iosClientId: "", // opcional para Google Sign-In
          androidClientId: "", // opcional para Google Sign-In
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no soportadas para esta plataforma.',
        );
    }
  }
}
