import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> updateNotificationPreference(bool isEnabled) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await userDoc.update({
        'notificationsEnabled': isEnabled,
      });
      print('Notification preference updated successfully.');
    } catch (e) {
      print('Failed to update notification preference: $e');
    }
  } else {
    print('No user logged in.');
  }
}
