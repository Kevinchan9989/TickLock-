import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'ForgotPasswordPage.dart';
import 'RegisterPage.dart';
import 'package:pwmanager/themes/color.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //firebase sign in
  Future signIn() async {
    //checks if login credentials is entered
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    } on Exception catch (e) {
      // TODO
      print(e);

      //show snackbar message
      const snackBar = SnackBar(
        content: Text('Wrong Login Credentials'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  //dispose controllers when not in used to free up memory
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //login page
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Welcome Back!',
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
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),

                    //check if email is entered in the correct form
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

                    //checks if password is entered
                    validator: (value) {
                      return value!.isEmpty
                          ? 'Please Enter Your Password'
                          : null;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MaterialButton(
                    color: MainColor.primaryColor10,
                    //minWidth: double.infinity,
                    onPressed: signIn,

                    child: Text('Login'),
                    //color: Colors.black,
                    textColor: Colors.white,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  GestureDetector(
                    child: Text('Forgot Password',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        )),

                    //go to forgot password page when clicked
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage()));
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New User? ',
                        //style: TextStyle(fontSize: 25.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterPage()));
                        },
                        child: Text('Register',
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

    //); //mat app
  }
}
