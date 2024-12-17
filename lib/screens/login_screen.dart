import 'dart:convert';
import 'package:bottle_crush/screens/dashboard.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading JSON
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../widgets/custom_elevated_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    /// whenever your initialization is completed, remove the splash screen:
    Future.delayed(Duration(seconds: 2)).then((value) => {
      FlutterNativeSplash.remove()
    });
  }

  // method to load the admin details from json
  Future<Map<String, dynamic>> _fetchAdminDetails() async {
    // Load the JSON file
    final String response = await rootBundle.loadString('assets/json/admin_details.json');
    return json.decode(response);
  }


  // Method to validate credentials
  Future<void> submitPressed() async {
    String enteredEmail = _emailController.text;
    String enteredPassword = _passwordController.text;

    // Check if email or password is empty
    if (enteredEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
      // Validate email format
      String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      RegExp regExp = RegExp(emailPattern);

      if (!regExp.hasMatch(enteredEmail)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid email'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop further execution
      } // Stop further execution


    if (enteredPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop further execution
    }

    try {
      // Load the JSON file
      final String response = await rootBundle.loadString('assets/json/user_credentials.json');
      final data = json.decode(response);

      // Check if credentials exist in the JSON file
      final user = data['users'].firstWhere(
            (user) => user['email'] == enteredEmail && user['password'] == enteredPassword,
        orElse: () => null,
      );

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid credentials.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error loading credentials: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong...please try again later'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: screenHeight * 0.1),
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.textWhite,
              child: Icon(
                Icons.eco_rounded,
                color: AppTheme.backgroundBlue,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Welcome to Bottle Crush!",
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "Login to continue",
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: screenHeight * 0.1),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35.0),
                  topRight: Radius.circular(35.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email, color: AppTheme.backgroundBlue),
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock, color: AppTheme.backgroundBlue),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: AppTheme.backgroundBlue,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          labelStyle: TextStyle(color: Colors.grey.shade700),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      // forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () async {
                            // Fetch admin details from JSON
                            final adminDetails = await _fetchAdminDetails();

                            // Display dialog with fetched details
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: AppTheme.backgroundBlue,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Forgot Password',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Contact the admin to change your password.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        children: [
                                          const Icon(Icons.person, color: AppTheme.backgroundBlue),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Admin: ${adminDetails['admin_name']}',
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone, color: AppTheme.backgroundBlue),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Contact: ${adminDetails['admin_contact']}',
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  actionsAlignment: MainAxisAlignment.center,
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.backgroundBlue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: const Text(
                                        'Got it!',
                                        style: TextStyle(
                                          color: AppTheme.textWhite,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppTheme.backgroundBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.09,),

                      CustomElevatedButton(
                        buttonText: 'Submit',
                        onPressed: submitPressed, // Call validateCredentials on submit
                        width: screenWidth * 0.3,
                        height: 50,
                        backgroundColor: AppTheme.backgroundBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
