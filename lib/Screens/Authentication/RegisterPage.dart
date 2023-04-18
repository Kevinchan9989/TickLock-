import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pwmanager/themes/color.dart';
import 'LoginPage.dart';
import 'Verify.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  //firebase signup
  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      if (_confirmPasswordController.text == _passwordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);

        //go to verify page and wait for users to complete 2fa
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Verify()));
      }
    } on Exception catch (e) {
      // TODO
      print(e);
      const snackBar = SnackBar(
        content:
            Text('This Email Has Been Registered or Invalid Login Credentials'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Registration!',
              style: TextStyle(
                  fontSize: 35,
                  color: MainColor.primaryColor10,
                  fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  //SizedBox(height: 15,),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (email) =>
                        email!.isEmpty && !EmailValidator.validate(email)
                            ? 'Please Enter Your Email'
                            : null,
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter Password',
                      prefixIcon: Icon(Icons.password),
                      border: OutlineInputBorder(),
                    ),
                    validator: (password) {
                      return password!.isEmpty
                          ? 'Please enter at least 6 characters'
                          : null;
                    },
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm Password',
                      prefixIcon: Icon(Icons.password),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please confirm your password'
                          : null;
                    },
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  MaterialButton(
                    color: MainColor.primaryColor10,
                    //minWidth: double.infinity,
                    onPressed: () {
                      signUp();
                    },
                    child: Text('Register'),
                    //color: Colors.black,
                    textColor: Colors.white,
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        //style: TextStyle(fontSize: 25.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          /*Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              LoginPage()));*/
                          Navigator.pop(context);
                        },
                        child: Text('Login',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
