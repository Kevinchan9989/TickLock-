import 'package:flutter/material.dart';
import 'package:pwmanager/Screens/Settings/theme_provider.dart';
import 'package:provider/provider.dart';
import 'Screens/Authentication/Auth.dart';
import 'package:firebase_core/firebase_core.dart';

//run in terminal : flutter pub add firebase_core  && flutter pub add firebase_auth

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness:
                  themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
            ),
            home: Auth(),
          );
        },
      ),
    );
  }
}
