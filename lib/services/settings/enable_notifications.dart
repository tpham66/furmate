import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> updateNotificationPreference(bool isEnabled) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('No user logged in');
  }

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update({
    'notificationsEnabled': isEnabled,
  });
}