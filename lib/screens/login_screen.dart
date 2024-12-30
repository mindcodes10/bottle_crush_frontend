import 'package:bottle_crush/screens/forgot_password.dart';
import 'dart:io';
import 'package:bottle_crush/screens/business_dashboard.dart';
import 'package:bottle_crush/screens/dashboard.dart';
import 'package:bottle_crush/services/api_services.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/utils/token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../widgets/custom_elevated_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final secureStorage = const FlutterSecureStorage();


  @override
  void initState() {
    super.initState();

    // Check if a token exists and navigate accordingly
    _checkToken();

    /// whenever your initialization is completed, remove the splash screen:
    Future.delayed(const Duration(seconds: 2)).then((value) => {
      FlutterNativeSplash.remove()
    });
  }

  // Method to check token
  Future<void> _checkToken() async {
    String? token = await secureStorage.read(key: 'access_token');
    if (token != null) {
      // Decode the token and extract email and role
      final decodedData = TokenService.decodeToken(token);
      if (decodedData != null) {
        final email = decodedData['sub'];
        debugPrint("Token found for: $email");

        // Navigate based on the role
        final role = decodedData['role'];
        final id = decodedData['id'];
        if (role == 't_admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        } else if (role == 't_customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BusinessDashboard(id:id)),
          );
        }
      }
    }
  }

  Future<void> submitPressed() async {
    String enteredEmail = _emailController.text.trim();
    String enteredPassword = _passwordController.text.trim();

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

    if (enteredPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call the API login function
    final apiService = ApiServices();

    try {
      final response = await apiService.login(enteredEmail, enteredPassword);

      if (response != null && response['access_token'] != null) {
        // Decode the token and extract email and role
        final token = response['access_token'];
        final decodedData = TokenService.decodeToken(token);

        if (decodedData != null) {
          final email = decodedData['sub']; // 'sub' is the email
          final role = decodedData['role']; // 'role' is available in token
          final id = decodedData['id'];

          // Print the email and role
          debugPrint("User Email: $email");
          debugPrint("User Role: $role");
          debugPrint("User Id: $id");

          // Store the token securely (e.g., using flutter_secure_storage)
          await secureStorage.write(key: 'access_token', value: token);
          debugPrint("Access Token = $token");

          // Navigate to the appropriate dashboard based on the role
          if (role == 't_admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          } else if (role == 't_customer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BusinessDashboard(id:id)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid role.'),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please try again.'),
          ),
        );
      }
    } on SocketException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection. Please check your network and try again.'),
        ),
      );
    } catch (e) {
      debugPrint('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please try again later.'),
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
          SizedBox(height: screenHeight * 0.08),
          Center(
            child: ClipOval(
              child: SizedBox(
                width: 150, // Set a specific width
                height: 150, // Set a specific height
                child: Image.asset(
                  'assets/images/aquazen_logo.png',
                  fit: BoxFit.cover, // Ensures the image fits proportionally
                ),
              ),
            ),
          ),


          const SizedBox(height: 20),
          const Center(
            child: Text(
              "Welcome to Aquazen!",
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
          SizedBox(height: screenHeight * 0.09),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPassword()));
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
                      SizedBox(height: screenHeight * 0.09),
                      CustomElevatedButton(
                        buttonText: 'Submit',
                        onPressed: submitPressed,
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.06,
                        backgroundColor: AppTheme.backgroundBlue,
                        icon: const Icon(Icons.check, color: AppTheme.textWhite),
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
