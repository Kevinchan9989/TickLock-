import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:password_hash/password_hash.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pwmanager/themes/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ...

class PasswordVaultScreen extends StatefulWidget {
  @override
  _PasswordVaultScreenState createState() => _PasswordVaultScreenState();
}

class _PasswordVaultScreenState extends State<PasswordVaultScreen> {
  final CollectionReference<Map<String, dynamic>> _sites =
      FirebaseFirestore.instance.collection('Sites');
  final user = FirebaseAuth.instance.currentUser!;

  final _formKey = GlobalKey<FormState>();
  final _serviceProviderController = TextEditingController();
  final _siteUsernameController = TextEditingController();
  final _sitePasswordController = TextEditingController();

  // Function to handle the submit button
  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      // Retrieve the user's master password and device secret from Firestore
      String? uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      String? masterPassword = snapshot.data()!['password'];

      String? deviceSecret = snapshot.data()!['deviceSecret'];

      // Generate a master key from the master password and device secret
      String masterKey = _generateMasterKey(masterPassword!, deviceSecret!);

      // Encrypt the site password with the master key
      String encryptedPassword =
          _encryptPassword(_sitePasswordController.text, masterKey);

      // Save the entry to the Firebase database
      FirebaseFirestore.instance.collection('Sites').add({
        'uid': user.uid,
        'service_provider': _serviceProviderController.text,
        'site_username': _siteUsernameController.text,
        'encrypted_password': encryptedPassword,
      });

      // Close the form dialog
      Navigator.pop(context);
    }
  }

// Generate master key from master password and device secret
  String _generateMasterKey(String password, String deviceSecret) {
    var salt = 'my_salt';
    var hash = PBKDF2();
    var key = hash.generateKey(String.fromCharCodes(password.codeUnits),
        String.fromCharCodes(utf8.encode(salt)), 1000, 32);
    var masterKey = hash.generateKey(String.fromCharCodes(key),
        String.fromCharCodes(utf8.encode(deviceSecret)), 1000, 32);
    return base64.encode(masterKey);
  }

// Encrypt site password with AES-256
  String _encryptPassword(String password, String masterKey) {
    print(password);
    final key = encrypt.Key.fromBase64(masterKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);
    return base64.encode(iv.bytes) + ":" + encrypted.base64;
  }

// Decrypt site password with AES-256
  String _decryptPassword(String encryptedPassword, String masterKey) {
    final key = encrypt.Key.fromBase64(masterKey);
    final parts = encryptedPassword.split(":");
    final iv = encrypt.IV.fromBase64(parts[0]);
    final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }

// Function to retrieve the user's master password from local storage
  Future<String> _getMasterPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hashedPassword = prefs.getString('hashed_password');
    if (hashedPassword == null) {
      return '';
    }
    return hashedPassword;
  }

  Future<String?> getDecryptedPassword(String encryptedPassword) async {
    String? uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    String? masterPassword = snapshot.data()!['password'];

    String? deviceSecret = snapshot.data()!['deviceSecret'];

    // Generate a master key from the master password and device secret
    String masterKey = _generateMasterKey(masterPassword!, deviceSecret!);

    // Encrypt the site password with the master key
    String decrypted = _decryptPassword(encryptedPassword, masterKey);
    return decrypted;
  }

  // Function to handle the add button click
  void _handleAddButton() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: SizedBox(
              height: 350,
              child: Column(
                children: [
                  Text(
                    "New Account",
                    style: TextStyle(
                      fontSize: 40,
                      color: MainColor.primaryColor10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _serviceProviderController,
                          decoration: const InputDecoration(
                            labelText: 'Service Provider',
                            hintText: 'e.g. Google, Amazon',
                            prefixIcon: Icon(Icons.language),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a service provider';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _siteUsernameController,
                          decoration: const InputDecoration(
                            labelText: 'Site Username',
                            hintText: 'e.g. john.doe@gmail.com',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a site username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _sitePasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Site Password',
                            prefixIcon: Icon(Icons.vpn_key),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a site password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                MainColor.primaryColor10),
                          ),
                          onPressed: _handleSubmit,
                          child: Text('Add New Account'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _sites.where('uid', isEqualTo: user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred.'),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: MainColor.primaryColor10,
              ),
            );
          }

          final siteDocs = snapshot.data!.docs;

          if (siteDocs.isEmpty) {
            return const Center(
              child: Text('No sites found.'),
            );
          }

          return ListView.builder(
            itemCount: siteDocs.length,
            itemBuilder: (context, index) {
              final site = siteDocs[index].data();
              final serviceProvider = site['service_provider'] ?? 'N/A';
              final siteUsername = site['site_username'] ?? 'N/A';

              return InkWell(
                //onTap: () => ,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: MainColor.primaryColor10),
                    borderRadius: BorderRadius.circular(16),
                    color: MainColor.primaryColor10,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$serviceProvider',
                        style: TextStyle(
                            fontSize: 18,
                            color: MainColor.lightColor,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Username: $siteUsername',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueGrey,
                        ),
                      ),
                      SizedBox(height: 2),
                      FutureBuilder<String?>(
                        future:
                            getDecryptedPassword(site['encrypted_password']),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final password = snapshot.data!;
                            final maskedPassword = '*' * password.length;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Password: $maskedPassword',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 36,
                                      height: 24,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.copy,
                                          color: MainColor.goldColor,
                                        ),
                                        onPressed: () async {
                                          await Clipboard.setData(
                                            ClipboardData(text: password),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text(
                                                  'Password copied to clipboard!'),
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 24,
                                    ),
                                    SizedBox(
                                      width: 36,
                                      height: 24,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: MainColor.bronzeColor,
                                        ),
                                        onPressed: () async {
                                          final uid = FirebaseAuth
                                              .instance.currentUser!.uid;
                                          final siteId = siteDocs[index].id;

                                          // Show confirmation dialog before deleting site
                                          bool confirm = await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                title: Text('Delete Site'),
                                                content: const Text(
                                                    'Are you sure you want to delete this site?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          backgroundColor:
                                                              Colors.green,
                                                          content: Text(
                                                              'Account Deleted Successfully!'),
                                                          duration: Duration(
                                                              seconds: 2),
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                          color: MainColor
                                                              .primaryColor10),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                    },
                                                    child: Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color: MainColor
                                                              .primaryColor10),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirm == true) {
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('Sites')
                                                  .doc(siteId)
                                                  .delete();
                                            } catch (e) {
                                              print('Error deleting site: $e');
                                              // Handle error as needed
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                              ),
                            );
                          } else {
                            return const Text(
                              'Decrypting password...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blueGrey,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MainColor.primaryColor10,
        onPressed: _handleAddButton,
        child: const Icon(Icons.add),
      ),
    );
  }
}
