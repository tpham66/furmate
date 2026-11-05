
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  String errorMessage = '';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      errorMessage = '';

      // Web: Google popup sign-in flow
      if (kIsWeb) {
        return await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      }

      // Initialize Google Sign-In once.
      await _initializeGoogleSignIn();

      // Trigger the Google sign-in flow.
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      // Obtain the Google ID token.
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      // Create a Firebase credential.
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase.
      return await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        errorMessage = 'Error signing in with Google: $e';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      errorMessage = 'Error signing in with Google: $e';
      return null;
    } catch (e) {
      errorMessage = 'Error signing in with Google: $e';
      return null;
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      errorMessage = '';
      await _initializeGoogleSignIn();

      // Sign out from Firebase and Google.
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      errorMessage = 'Error signing out from Google: $e';
    }
  }

  static Future<void>? _initialization;

  Future<void> _initializeGoogleSignIn() {
    return _initialization ??= _googleSignIn.initialize();
  }
}
