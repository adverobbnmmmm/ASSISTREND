platforms
    if (!kIsWeb && !(Platform.isWindows)) {
      await firebase.Firebase.initializeApp();
      debugPrint('Firebase initialized successfully');
    } else {
      debugPrint('Firebase initialization skipped on this platform');
    }  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
  }
}

class MyApp extends StatelessWidget {