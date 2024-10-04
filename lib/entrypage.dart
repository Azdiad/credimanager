import 'package:account_manage/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordEntryPage extends StatefulWidget {
  @override
  _PasswordEntryPageState createState() => _PasswordEntryPageState();
}

class _PasswordEntryPageState extends State<PasswordEntryPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool isSettingPassword = true; // Flag to determine if setting a password
  bool isForgotPassword = false; // Flag for forget password mode

  @override
  void initState() {
    super.initState();
    _checkIfPasswordExists();
  }

  Future<void> _checkIfPasswordExists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? existingPassword = prefs.getString('user_password');
    if (existingPassword != null) {
      setState(() {
        isSettingPassword = false; // Password exists, show enter password
      });
    }
  }

  Future<void> _setPassword(String password, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_password', password);
    await prefs.setString('recovery_email', email);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> _checkPassword(String enteredPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? existingPassword = prefs.getString('user_password');
    if (existingPassword == enteredPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      _showErrorDialog();
    }
  }

  Future<void> _forgotPassword(String enteredEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? recoveryEmail = prefs.getString('recovery_email');
    if (recoveryEmail == enteredEmail) {
      _showChangePasswordDialog();
    } else {
      _showErrorDialog('Invalid recovery email.');
    }
  }

  Future<void> _changePassword(String newPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_password', newPassword);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void _showErrorDialog(
      [String message = 'Incorrect password. Please try again.']) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _changePassword(newPasswordController.text);
              },
              child: Text('Change'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a gradient background for a richer look
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[300]!, Colors.teal[700]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
                child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          isSettingPassword
                              ? 'Set Password'
                              : isForgotPassword
                                  ? 'Recover Password'
                                  : 'Enter Password',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                        SizedBox(height: 20),
                        if (isSettingPassword || isForgotPassword) ...[
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Recovery Email',
                              labelStyle: TextStyle(color: Colors.teal),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.teal),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.teal),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.teal),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.teal[800]!),
                            ),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (isSettingPassword) {
                              _setPassword(passwordController.text,
                                  emailController.text);
                            } else if (isForgotPassword) {
                              _forgotPassword(emailController.text);
                            } else {
                              _checkPassword(passwordController.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            backgroundColor: Colors.teal[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ), // Darker teal
                            elevation: 5,
                          ),
                          child: Text(
                            isSettingPassword
                                ? 'Set Password'
                                : isForgotPassword
                                    ? 'Submit'
                                    : 'Submit',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        if (!isSettingPassword && !isForgotPassword)
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  isForgotPassword = true;
                                });
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.teal[800]),
                              )),
                      ]),
                    ))),
          )),
    );
  }
}
