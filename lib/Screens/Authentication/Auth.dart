import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pwmanager/Screens/Authentication/LoginPage.dart';
import 'package:pwmanager/Screens/Vault/promptMP.dart';

import '../mainframe.dart';

class Auth extends StatelessWidget {
  Future<bool> verifyFirstTime(bool isFirstTimeUser) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc('uid').get();
    isFirstTimeUser = !snapshot.exists;
    return isFirstTimeUser;
    // Do something with the snapshot
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              //if user is logged in, go to password vault page
              if (snapshot.hasData) {
                return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(snapshot.data!.uid)
                        .get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          // User already exists in the database, show MyHomePage screen
                          return const MyHomePage(
                            title: 'Password Vault',
                          );
                        } else {
                          // User does not exist in the database, show PasswordPrompt screen
                          return const PasswordPrompt();
                        }
                      } else {
                        // Show loading indicator while we wait for data to load
                        return const Center(child: CircularProgressIndicator());
                      }
                    });
              }
              //else go to login page
              else {
                return LoginPage();
              }
            }));
  }
}
