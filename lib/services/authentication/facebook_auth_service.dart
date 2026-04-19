import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthService {
  String errorMessage = '';
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Start the Facebook sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email', 'pages_show_list', 'pages_messaging', 'pages_manage_metadata'],
      );

      if (loginResult.status == LoginStatus.success) {
        // Create the Facebook credential
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(
                loginResult.accessToken!.tokenString);

        // Link the Facebook credential to the current user
        return await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);
      } else {
        errorMessage = 'Facebook sign-in was canceled or failed.';
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage =
            'An account already exists with the same email address but different sign-in credentials. Use another method to sign in.';
      } else if (e.code == 'credential-already-in-use') {
        errorMessage =
            'This Facebook account is already associated with another user.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'The Facebook credential is invalid or has expired.';
      } else {
        errorMessage =
            'An error occurred while signing in with Facebook: ${e.message}';
      }
      return null;
    }
  }

  Future<void> signOutFromFacebook () async {
    try {
      // Sign out from Firebase and Google
      await FirebaseAuth.instance.signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      errorMessage = 'Error signing out from Facebook: $e';
    }
  }
}
