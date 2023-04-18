import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:pwmanager/themes/color.dart';

class PasswordGeneratorPage extends StatefulWidget {
  final Function(String, String)? onSaveUsernameAndPassword;

  const PasswordGeneratorPage({Key? key, this.onSaveUsernameAndPassword})
      : super(key: key);

  @override
  _PasswordGeneratorPagestate createState() => _PasswordGeneratorPagestate();
}

class _PasswordGeneratorPagestate extends State<PasswordGeneratorPage> {
  // State variables
  String _generatedPassword = '';
  String _generatedUsername = '';
  int _passwordLength = 8;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSpecialChars = true;
  bool _generateUsername = false; // Add this line to manage the toggle state
  int _minSpecialChars = 0;

// Helper functions
  String _generateItem(bool isUsername) {
    const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const String numberChars = '0123456789';
    const String specialChars = '!@#\$%^&*()_-+=<>?';

    String allowedChars = '';
    if (_includeUppercase) allowedChars += uppercaseChars;
    if (_includeLowercase) allowedChars += lowercaseChars;
    if (_includeNumbers) allowedChars += numberChars;
    if (_includeSpecialChars) allowedChars += specialChars;

    if (allowedChars.isEmpty) return '';

    final random = Random();
    return List.generate(_passwordLength,
        (index) => allowedChars[random.nextInt(allowedChars.length)]).join();
  }

  String _passwordStrength(String password) {
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasNumbers = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars =
        password.contains(RegExp(r'[\!\@\#\$\%\^\&\*\(\)\_\-\+\=\<\>\?]'));

    int characterSetSize = 0;
    if (hasUppercase) characterSetSize += 26;
    if (hasLowercase) characterSetSize += 26;
    if (hasNumbers) characterSetSize += 10;
    if (hasSpecialChars) characterSetSize += 10;

    double entropy = log(characterSetSize) / log(2) * password.length;
    if (entropy > 0) {
      if (entropy < 40) return 'Weak';
      if (entropy < 60) return 'Moderate';
      return 'Strong';
    } else {
      return "Please choose at least one condition to generate a password";
    }
  }

  String _generateItemWithMinimumSpecialChars() {
    const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
    const String numberChars = '0123456789';
    const String specialChars = '!@#\$%^&*()_-+=<>?';

    String allowedChars = '';
    if (_includeUppercase) allowedChars += uppercaseChars;
    if (_includeLowercase) allowedChars += lowercaseChars;
    if (_includeNumbers) allowedChars += numberChars;
    if (_includeSpecialChars) allowedChars += specialChars;

    if (allowedChars.isEmpty) return '';

    final random = Random();
    String generatedItem;
    int specialCharCount;

    do {
      generatedItem = List.generate(_passwordLength,
          (index) => allowedChars[random.nextInt(allowedChars.length)]).join();

      specialCharCount = 0;
      for (var rune in generatedItem.runes) {
        if (specialChars.contains(String.fromCharCode(rune))) {
          specialCharCount++;
        }
      }
    } while (specialCharCount < _minSpecialChars);

    return generatedItem;
  }

  void _updateGeneratedItem() {
    setState(() {
      if (_generateUsername) {
        _generatedUsername = _generateItem(true);
        _generatedPassword = '';
      } else {
        _generatedUsername = '';
        _generatedPassword = _generateItemWithMinimumSpecialChars();
      }
    });
  }

  void _incrementMinSpecialChars() {
    setState(() {
      if (_minSpecialChars < _passwordLength) {
        _minSpecialChars++;
      }
    });
  }

  void _decrementMinSpecialChars() {
    setState(() {
      if (_minSpecialChars > 1) {
        _minSpecialChars--;
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Section - Generated Password and Password Strength
              Text(
                'Generated ${_generateUsername ? 'Username' : 'Password'}:',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MainColor.primaryColor10),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueGrey, width: 2),
                      ),
                      child: Text(
                        _generateUsername
                            ? _generatedUsername
                            : (_generatedPassword.isEmpty
                                ? _generatedPassword
                                : _generateItem(false)),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      IconButton(
                        onPressed: _updateGeneratedItem,
                        icon: const Icon(Icons.refresh),
                        color: Colors.blueGrey,
                      ),
                      IconButton(
                        onPressed: () {
                          _copyToClipboard(_generatedPassword);
                        },
                        icon: const Icon(Icons.content_copy),
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              if (!_generateUsername)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Password Strength:'),
                    Text(
                      _passwordStrength(_generatedPassword),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // Second Section - Type (Password or Username)
              Text(
                'Types:',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MainColor.primaryColor10),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                activeColor: Colors.blueGrey,
                title: Text(_generateUsername ? 'Username' : 'Password'),
                value: _generateUsername,
                onChanged: (bool value) {
                  setState(() {
                    _generateUsername = value;
                    if (!_generateUsername) {
                      _updateGeneratedItem();
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Third Section - Filters
              Text(
                'Filters:',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MainColor.primaryColor10),
              ),
              const SizedBox(height: 8),
              const Text('Password Length:'),
              Slider(
                activeColor: MainColor.primaryColor10,
                value: _passwordLength.toDouble(),
                min: 1,
                max: 32,
                divisions: 31,
                label: _passwordLength.toString(),
                onChanged: (double newValue) {
                  setState(() {
                    _passwordLength = newValue.round();
                  });
                },
              ),
              CheckboxListTile(
                activeColor: MainColor.primaryColor10,
                title: const Text('Uppercase Characters (A-Z)'),
                value: _includeUppercase,
                onChanged: (bool? value) {
                  setState(() {
                    _includeUppercase = value!;
                  });
                },
              ),
              CheckboxListTile(
                activeColor: MainColor.primaryColor10,
                title: const Text('Lowercase Characters (a-z)'),
                value: _includeLowercase,
                onChanged: (bool? value) {
                  setState(() {
                    _includeLowercase = value!;
                  });
                },
              ),
              CheckboxListTile(
                activeColor: MainColor.primaryColor10,
                title: const Text('Numbers (0-9)'),
                value: _includeNumbers,
                onChanged: (bool? value) {
                  setState(() {
                    _includeNumbers = value!;
                  });
                },
              ),
              CheckboxListTile(
                activeColor: MainColor.primaryColor10,
                title: const Text('Special Characters (!@#%^&*)'),
                value: _includeSpecialChars,
                onChanged: (bool? value) {
                  setState(() {
                    _includeSpecialChars = value!;
                  });
                },
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('Minimum Special Characters:'),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: _decrementMinSpecialChars,
                    child: const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  Text(
                    _minSpecialChars.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MainColor.primaryColor10,
                    ),
                  ),
                  TextButton(
                    onPressed: _incrementMinSpecialChars,
                    child: const Text(
                      '+',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
