import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pwmanager/Screens/Generator/Generatepassword.dart';
import 'package:pwmanager/Screens/Settings/Setting.dart';
import 'package:pwmanager/themes/color.dart';
import 'package:pwmanager/Screens/Vault/vaultScreen.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState(title: title);
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _pages;
  int _currentPage = 0;
  String _title;

  _MyHomePageState({required String title})
      : _title = title,
        _pages = [
          PasswordVaultScreen(),
          PasswordGeneratorPage(),
          SettingsPage(),
        ];

  void _onItemTapped(int index) {
    setState(() {
      _currentPage = index;
      if (_currentPage == 0) {
        _title = 'Password Vault';
      } else if (_currentPage == 1) {
        _title = 'Password Generator';
      } else {
        _title = 'Settings';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: MainColor.primaryColor10,
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Log Out',
                child: Text('Log Out'),
              ),
            ],
            onSelected: (String value) {
              if (value == 'Log Out') {
                FirebaseAuth.instance.signOut();
                print('Logging out...'); // Example action
              } else {
                // Handle other menu item actions here
              }
            },
          ),
        ],
      ),
      body: _pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: MainColor.lightColor,
        unselectedItemColor: Colors.blueGrey,
        backgroundColor: MainColor.primaryColor10,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'My Vault',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vpn_key),
            label: 'Generator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _currentPage,
        onTap: _onItemTapped,
      ),
    );
  }
}
