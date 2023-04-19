# pwmanager
 group assignment
 
 applicationId "com.example.pwmanager"

---------------------------------------------------------

android - app
google-services.json

---------------------------------------------------------
 
 android - gradle - build gradle
 build script - dependencies:
 add   classpath 'com.google.gms:google-services:4.3.15'
  
---------------------------------------------------------

android - app - src - build gradle
last line add   apply plugin: 'com.google.gms.google-services'
 
---------------------------------------------------------
pubspec.yaml

Firebase dependencies:
  firebase_core: ^2.9.0
  firebase_auth: ^4.4.1
  email_validator: ^2.0.1
  firebase_database: ^10.1.0
  crypto: ^2.0.0
  encrypt: ^4.1.0
  password_hash: ^2.0.0
  shared_preferences: ^2.1.0
  cloud_firestore: ^4.5.1
  provider: ^6.0.5
  flutter_windowmanager: ^0.2.0
  
---click on pub get---

if that doesnt work: run these in terminal
 flutter pub add firebase_core  
 flutter pub add firebase_auth 
 flutter pub add email_validator
