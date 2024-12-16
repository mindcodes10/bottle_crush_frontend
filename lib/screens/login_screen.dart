import 'package:bottle_crush/utils/theme.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_elevated_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlue, // Blue background
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.15),

          // Welcome text
          const Text(
            "Welcome to Bottle Crush!",
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          // Spacer between text and container
          SizedBox(height: screenHeight * 0.18),

          // White container with Login text
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20), // Spacer for the text
                    const Center(
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Text field for email
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Enter email',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Text field for password
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Enter password',
                      ),
                      obscureText: true, // Hide password for security
                    ),

                    const SizedBox(height: 20),

                    // Forgot Password? clickable text using GestureDetector
                    GestureDetector(
                      onTap: () {
                        // Handle the click event
                        print("Forgot Password clicked");
                        // You can navigate to a password reset screen here
                      },
                      child: const Text(
                        "Forgot Password?",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.blue, // Blue color like a link
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Submit button using CustomElevatedButton
                    CustomElevatedButton(
                      buttonText: "Submit",
                      onPressed: () {
                        // Handle the submit action
                        print("Submit clicked");
                        // You can add your login logic here
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
