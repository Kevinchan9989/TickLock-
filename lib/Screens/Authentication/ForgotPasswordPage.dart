import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pwmanager/themes/color.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  //firebase sends reset password link
  Future resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      const snackBar = SnackBar(
        content: Text('Email Sent'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on Exception catch (e) {
      // TODO
      print(e);
      const snackBar = SnackBar(
        content: Text('Please Enter Your Email'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    //Utils.showSnackBar('Password Reset Email Sent');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                children: [
                  Text('We will send a reset password link to your email',
                      style: TextStyle(
                          fontSize: 25,
                          color: MainColor.primaryColor10,
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      return value!.isEmpty ? 'Please Enter Your Email' : null;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MaterialButton(
                    color: MainColor.primaryColor10,
                    //minWidth: double.infinity,
                    onPressed: resetPassword,

                    child: Text('Reset Password'),
                    //color: Colors.black,
                    textColor: Colors.white,
                  ),
                ],
              ))
        ]));
  }
}
