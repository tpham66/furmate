import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furmate/screens/splashscreen.dart';
import 'change_password.dart';
import 'package:get/get.dart';
import 'user_profile.dart';
import '../services/google_auth_service.dart';
import '../services/facebook_auth_service.dart';

const List<Widget> units = <Widget>[
  Text('Lb'),
  Text('Kg'),
];

String weightUnit = '';
List<bool> _selectedUnits = <bool>[true, false];
bool onNoti = true;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FacebookAuthService _facebookAuthService = FacebookAuthService();

  Future<void> _signOut() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Check the provider
      for (var providerProfile in user.providerData) {
        switch (providerProfile.providerId) {
          case 'google.com':
            await _googleAuthService.signOutFromGoogle();
            break;
          case 'facebook.com':
            await _facebookAuthService.signOutFromFacebook();
            break;
          default:
            await FirebaseAuth.instance.signOut();
        }
      }
    }

    // Navigate to the initial screen
    Get.to(() => SplashScreen());
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications'),
                Switch(
                  value: onNoti,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      onNoti = value;
                    });
                  },
                )
              ],
            ),
            leading: Icon(Icons.notifications),
            onTap: () {
              // Navigate to Privacy Settings
            },
          ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Weight Unit'),
                ToggleButtons(
                  children: units,
                  isSelected: _selectedUnits,
                  direction: Axis.horizontal,
                  onPressed: (int index) {
                    setState(() {
                      // The button that is tapped is set to true, and the others to false.
                      for (int i = 0; i < _selectedUnits.length; i++) {
                        _selectedUnits[i] = i == index;
                      }
                    });
                    weightUnit = units[index].toString().substring(6, 8);
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  // selectedBorderColor: Colors.red[700],
                  selectedColor: Colors.white,
                  fillColor: Colors.red[200],
                  color: Colors.red[400],
                  constraints: const BoxConstraints(
                    minHeight: 40.0,
                    minWidth: 80.0,
                  ),
                )
              ],
            ),
            leading: Icon(Icons.scale),
          ),
          ListTile(
            title: Text('Export Data'),
            leading: Icon(Icons.download),
            onTap: () {
              // Navigate to Privacy Settings
            },
          ),
          Divider(),
          ListTile(
            title: Text('Contact'),
            leading: Icon(Icons.email),
            onTap: () {
              // Navigate to Privacy Settings
            },
          ),
          ListTile(
            title: Text('Rate FurMate'),
            leading: Icon(Icons.star_rate),
            onTap: () {
              // Navigate to Privacy Settings
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
