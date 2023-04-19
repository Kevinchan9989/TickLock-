import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pwmanager/Screens/Authentication/Auth.dart';
import 'package:pwmanager/Screens/Vault/promptMP.dart';
import 'package:pwmanager/Screens/mainframe.dart';

class Verify extends StatefulWidget {
  const Verify({Key? key}) : super(key: key);

  @override
  State<Verify> createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final user = FirebaseAuth.instance.currentUser!;
  bool isVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    //get verify state
    isVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    //if not verify, send email
    if (!isVerified) {
      sendVerificationEmail();

      //checks every 3 seconds
      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  //firebase sends verification email
  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } on Exception catch (e) {
      // TODO
    }
  }

  //dispose timer
  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  //check if user is verified
  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    //change verify state
    setState(() {
      isVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    //if verified, stop timer
    if (isVerified) timer?.cancel();
  }

  @override

  //if verified, go to password vault, else show verification email sent page
  Widget build(BuildContext context) => isVerified
      ? PasswordPrompt()
      : Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(35),
                child: Column(
                  children: [
                    Text('The verification link has been sent to your email.',
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        );
}
