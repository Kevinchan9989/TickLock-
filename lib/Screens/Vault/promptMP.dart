import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pwmanager/Screens/mainframe.dart';
import 'package:pwmanager/themes/color.dart';

import 'package:pwmanager/utils/NumberButton.dart';

class PasswordPrompt extends StatefulWidget {
  const PasswordPrompt({Key? key}) : super(key: key);

  @override
  _PasswordPromptState createState() => _PasswordPromptState();
}

class _PasswordPromptState extends State<PasswordPrompt> {
  final _formKey = GlobalKey<FormState>();
  String _password = '';
  String _deviceSecret = '';

  @override
  void initState() {
    super.initState();
    _generateDeviceSecret();
  }

  // Generate device secret
  void _generateDeviceSecret() {
    var rng = Random.secure();
    var bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    var digest = sha256.convert(bytes);
    setState(() {
      _deviceSecret = digest.toString();
    });
  }

  void _handleButtonPressed(String value) {
    setState(() {
      _password += value;
    });
  }

  void _handleBackspace() {
    setState(() {
      if (_password.isNotEmpty) {
        _password = _password.substring(0, _password.length - 1);
      }
    });
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      //Store device secret and password
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'password': _password,
        'deviceSecret': _deviceSecret,
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: 'Password Vault',
          ),
        ),
      );
    }
  }

  // Hash master password with SHA-256
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MainColor.primaryColor10,
        title: Text('Enter Master Password'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 6; i++)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(color: MainColor.silverColor),
                          borderRadius: BorderRadius.circular(5),
                          color: MainColor.silverColor),
                      child: Center(
                        child: Text(
                          _password.length >= i ? '●' : '',
                          style: TextStyle(
                            fontSize: 24,
                            color: MainColor.primaryColor10,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      NumberButton(
                        number: 1,
                        onPressed: (number) => _handleButtonPressed('1'),
                      ),
                      NumberButton(
                        number: 2,
                        onPressed: (number) => _handleButtonPressed('2'),
                      ),
                      NumberButton(
                        number: 3,
                        onPressed: (number) => _handleButtonPressed('3'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      NumberButton(
                        number: 4,
                        onPressed: (number) => _handleButtonPressed('4'),
                      ),
                      NumberButton(
                        number: 5,
                        onPressed: (number) => _handleButtonPressed('5'),
                      ),
                      NumberButton(
                        number: 6,
                        onPressed: (number) => _handleButtonPressed('6'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      NumberButton(
                        number: 7,
                        onPressed: (number) => _handleButtonPressed('7'),
                      ),
                      NumberButton(
                        number: 8,
                        onPressed: (number) => _handleButtonPressed('8'),
                      ),
                      NumberButton(
                        number: 9,
                        onPressed: (number) => _handleButtonPressed('9'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 60,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                MainColor.primaryColor10),
                          ),
                          onPressed: _handleBackspace,
                          child: Icon(Icons.keyboard_backspace),
                        ),
                      ),
                      NumberButton(
                        number: 0,
                        onPressed: (number) => _handleButtonPressed('0'),
                      ),
                      SizedBox(
                        width: 60,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                MainColor.primaryColor10),
                          ),
                          onPressed: _handleSubmit,
                          child: Icon(Icons.keyboard_return),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
