import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'demo-api-key',
      appId: '1:000000000000:web:demo-app-id',
      messagingSenderId: '000000000000',
      projectId: 'demo-project-id',
      authDomain: 'demo-project-id.firebaseapp.com',
      storageBucket: 'demo-project-id.appspot.com',
      measurementId: 'G-0000000000',
    );
  }
}
