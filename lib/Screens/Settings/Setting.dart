import 'package:flutter/material.dart';
import 'package:pwmanager/Screens/Authentication/LoginPage.dart';
import 'package:pwmanager/Screens/mainframe.dart';
import 'package:pwmanager/Screens/Settings/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:pwmanager/themes/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _secureMode = false;
  bool _autoLock = false;

  @override
  void initState() {
    super.initState();
    _loadAutoLockPreference();
  }

  Future<bool> _getDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('darkMode') ?? false;
  }

  Future<void> _setDarkModePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', value);
  }

  void _toggleDarkMode(BuildContext context) {
    Provider.of<ThemeProvider>(context, listen: false).toggleDarkMode();
  }

  Future<void> _deleteAllCollections() async {
    bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10.0), // This line makes the dialog box rounded.
              ),
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Warning',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Text(
                        'This will delete all data in the Cloud Firestore. Are you sure you want to continue?'),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;

    if (confirmed) {
      // Get a reference to the Cloud Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get a list of all collections in the Firestore database
      QuerySnapshot snapshot = await firestore.collectionGroup("Sites").get();
      List<QueryDocumentSnapshot> docs = snapshot.docs;

      // Delete all documents in each collection
      for (QueryDocumentSnapshot doc in docs) {
        await doc.reference.delete();
      }

      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All data cleared from Cloud Firestore')),
      );
    }
  }

  Future<void> _sendFeedback(String initialFeedback) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    String feedback = initialFeedback;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController feedbackController =
            TextEditingController(text: initialFeedback);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10.0), // This line makes the dialog box rounded.
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Report and Feedback',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: feedbackController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your feedback here',
                  ),
                  onChanged: (value) {
                    // Update the feedback variable as the user types
                    feedback = value;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Submit'),
                      onPressed: () async {
                        await firestore.collection('feedback').add({
                          'feedback': feedbackController.text,
                          'timestamp': Timestamp.now(),
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Feedback sent')),
                        );

                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10.0), // This line makes the dialog box rounded.
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'About this app',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                    'We offer a user-friendly and reliable way to store and manage all your passwords in one secure, encrypted location.'), // Add the full description here
                SizedBox(height: 20),
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAccountDetailsDialog(String accountEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Account Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 20),
                Text('Logged in as: $accountEmail'),
                SizedBox(height: 20),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAutoLockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10.0), // This line makes the dialog box rounded.
          ),
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Auto Lock Enabled',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                    'The app will lock automatically after 5 minutes of inactivity.'),
                SizedBox(height: 20),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadAutoLockPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoLock = prefs.getBool('autoLock') ?? false;
      if (_autoLock) {
        _startAutoLockTimer();
      }
    });
  }

  Future<void> _setAutoLockPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('autoLock', value);
  }

  void _startAutoLockTimer() {
    const Duration autoLockDuration = Duration(minutes: 5);
    Future.delayed(autoLockDuration, () {
      if (_autoLock) {
        _lockApp();
      }
    });
  }

  void _lockApp() {
    // Navigate to the Vault screen
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<String> _getAccountEmail() async {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "About",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MainColor.primaryColor10,
                ),
              ),
            ),

            ListTile(
              title: Text('Account Details'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () async {
                String accountEmail = await _getAccountEmail();
                _showAccountDetailsDialog(accountEmail);
              },
            ),

            ListTile(
              title: Text(
                'Sign Out',
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Features",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MainColor.primaryColor10,
                ),
              ),
            ),

            ListTile(
              title: Text('Auto-lock'),
              trailing: Switch(
                activeColor: Colors.blueGrey,
                value: _autoLock,
                onChanged: (bool value) {
                  setState(() {
                    _autoLock = value;
                    _setAutoLockPreference(value);
                    if (value) {
                      _startAutoLockTimer();
                      _showAutoLockDialog();
                    }
                  });
                },
              ),
            ),

            // Dark Mode
            ListTile(
              title: Text('Dark Mode'),
              trailing: Switch(
                activeColor: Colors.blueGrey,
                value: isDarkMode,
                onChanged: (value) {
                  _toggleDarkMode(context);
                },
              ),
            ),

            ListTile(
              title: Text('Secure Mode'),
              trailing: Switch(
                activeColor: Colors.blueGrey,
                value: _secureMode,
                onChanged: (bool value) async {
                  if (value) {
                    await FlutterWindowManager.addFlags(
                        FlutterWindowManager.FLAG_SECURE);
                  } else {
                    await FlutterWindowManager.clearFlags(
                        FlutterWindowManager.FLAG_SECURE);
                  }
                  setState(() {
                    _secureMode = value;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Disables screenshot within the app",
                style: TextStyle(color: Colors.grey),
              ),
            ),

            ListTile(
              title: Text('Clear All Data'),
              onTap: () async {
                await _deleteAllCollections();
              },
            ),

            //Others
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Others",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MainColor.primaryColor10,
                ),
              ),
            ),

            ListTile(
              title: Text('About this app'),
              onTap: _showAboutDialog,
            ),

            ListTile(
              title: Text('Report and Feedback'),
              onTap: () async {
                await _sendFeedback("");
              },
            ),
          ],
        ),
      ),
    );
  }
}
