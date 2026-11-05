import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:furmate/screens/splashscreen.dart';
import '../services/settings/enable_notifications.dart';
import '../widgets/general/error_dialog.dart';
import 'change_password.dart';
import 'package:get/get.dart';
import 'user_profile.dart';
import '../services/authentication/google_auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import '../services/export/pet_export.dart';

final InAppReview inAppReview = InAppReview.instance;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  bool onNoti = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotificationPreference();
  }

  Future<void> loadNotificationPreference() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      setState(() {
        onNoti = doc.data()?['notificationsEnabled'] == true;
      });
    } catch (e) {
      debugPrint('Failed to load notification preference: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  Future<void> toggleNotifications(bool value) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (value) {
        final granted =
            await NotificationService.instance.requestPermission();

        if (!granted) {
          throw Exception('Notification permission denied');
        }
      }

      await NotificationService.instance.updateNotificationPreference(value);
      await NotificationService.instance.syncEventNotifications();

      if (!mounted) return;

      setState(() {
        onNoti = value;
      });
    } catch (e) {
      debugPrint('Notification error: $e');

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(
          title: 'Error',
          message: 'Failed to update notification settings',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> openEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'phamduong2604@gmail.com',
      query: 'subject=FurMate Support',
    );

    await launchUrl(emailUri);
  }

  Future<void> _signOut() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final isGoogleUser = user.providerData.any(
          (provider) => provider.providerId == 'google.com',
        );

        if (isGoogleUser) {
          await _googleAuthService.signOutFromGoogle();
        }

        await FirebaseAuth.instance.signOut();
      }

      if (!mounted) return;

      Get.offAll(() => SplashScreen());
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            title: Text('Edit Profile'),
            leading: Icon(Icons.person),
            onTap: () {
              Get.to(() => UserProfile());
            },
          ),
          ListTile(
            title: Text('Password'),
            leading: Icon(Icons.lock),
            onTap: () {
              Get.to(() => ChangePassword());
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: Switch(
              value: onNoti,
              activeThumbColor: Colors.red,
              onChanged: isLoading ? null : toggleNotifications,
            ),
            onTap: isLoading
                ? null
                : () => toggleNotifications(!onNoti),
          ),
          ListTile(
            title: Text('Export Data'),
            leading: Icon(Icons.download),
            onTap: () {
              // Navigate to Privacy Settings
              try {
                ExportService().exportEvents();
              } catch (e) {
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  builder: (context) => const ErrorDialog(
                    title: 'Error',
                    message: 'Failed to export data',
                  ),
                );
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text('Contact'),
            leading: Icon(Icons.email),
            onTap: () {
              // Navigate to email
              openEmail();
            },
          ),
          ListTile(
            title: Text('Rate FurMate'),
            leading: Icon(Icons.star_rate),
            onTap: () async{
              // Navigate to rating
              try{
                await inAppReview.openStoreListing(appStoreId: 'sdfndvkjdfv');
              } catch (e) {
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  builder: (context) => const ErrorDialog(
                    title: 'Error',
                    message: 'Failed to open review dialog',
                  ),
                );
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text('Sign Out'),
            leading: Icon(Icons.logout),
            onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure to sign out?'),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            _signOut();
                          },
                          child: const Text('Sign Out'))
                    ],
                  )
                ],
              ),
            ),
          ),
          Divider()
        ],
      ),
    );
  }
}
