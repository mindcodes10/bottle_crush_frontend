import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_elevated_button.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isOtpSent = false;
  bool isOtpVerified = false;
  bool isNewPasswordObscured = true; // State for New Password visibility
  bool isConfirmPasswordObscured = true; // State for Confirm Password visibility

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
     backgroundColor: AppTheme.backgroundBlue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: screenHeight * 0.08),
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
              "Forgot Password",
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
              decoration: const BoxDecoration(color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35.0),
                  topRight: Radius.circular(35.0),
                ),),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(
                        child: Text(
                          "Reset your password here",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (!isOtpVerified) ...[
                        // Email Input Field and Send OTP Button
                        _buildTextField(
                          controller: emailController,
                          labelText: "Enter your email",
                          icon: FontAwesomeIcons.solidEnvelope,
                        ),
                        const SizedBox(height: 20),
                        CustomElevatedButton(
                          buttonText: "Send OTP",
                          width: screenWidth * 0.27,
                          height: screenHeight * 0.05,
                          backgroundColor: AppTheme.backgroundBlue,
                          textColor: AppTheme.textWhite,
                          onPressed: () {
                            if (emailController.text.isEmpty) {
                              showSnackbar("Please enter email");
                              return;
                            }
                            setState(() {
                              isOtpSent = true;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (isOtpSent && !isOtpVerified) ...[
                        // OTP Input Fields and Verify OTP Button
                        _buildOtpFields(),
                        const SizedBox(height: 20),
                        CustomElevatedButton(
                          buttonText: "Verify OTP",
                          width: screenWidth * 0.30,
                          height: screenHeight * 0.05,
                          backgroundColor: AppTheme.backgroundBlue,
                          textColor: AppTheme.textWhite,
                          onPressed: () {
                            if (otpControllers.any((controller) => controller.text.isEmpty)) {
                              showSnackbar("Please enter all digits of OTP");
                              return;
                            }
                            setState(() {
                              isOtpVerified = true;
                            });
                          },
                        ),
                      ],
                      if (isOtpVerified) ...[
                        // Password Reset Fields
                        _buildTextField(
                          controller: newPasswordController,
                          labelText: "New Password",
                          icon: FontAwesomeIcons.lock,
                          obscureText: isNewPasswordObscured,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isNewPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.startColor,
                            ),
                            onPressed: () {
                              setState(() {
                                isNewPasswordObscured = !isNewPasswordObscured;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: confirmPasswordController,
                          labelText: "Confirm New Password",
                          icon: FontAwesomeIcons.lock,
                          obscureText: isConfirmPasswordObscured,
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmPasswordObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.startColor,
                            ),
                            onPressed: () {
                              setState(() {
                                isConfirmPasswordObscured = !isConfirmPasswordObscured;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomElevatedButton(
                          buttonText: "Reset Password",
                          width: screenWidth * 0.38,
                          backgroundColor: AppTheme.backgroundBlue,
                          textColor: AppTheme.textWhite,
                          onPressed: () {
                            if (newPasswordController.text != confirmPasswordController.text) {
                              showSnackbar("Passwords do not match");
                              return;
                            }
                            // Password reset logic
                            showSnackbar("Password reset successfully!");
                            Navigator.pop(context); // Redirect to Login Page
                          },
                        ),
                      ],
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

  // OTP Input Fields as Individual Fields
  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          width: 50.0,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: TextField(
            controller: otpControllers[index],
            keyboardType: TextInputType.number,
            maxLength: 1,
            textAlign: TextAlign.center,
            autofocus: index == 0, // Focus on the first input by default
            decoration: InputDecoration(
              counterText: "", // Hide the character counter
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.backgroundBlue),
              ),
            ),
            onChanged: (value) {
              // Move to the next field if a number is entered and not the last field
              if (value.isNotEmpty && index < 5) {
                FocusScope.of(context).nextFocus();
              }
              // Move to the previous field if the value is empty and not the first field
              if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.textWhite,
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 12),
        prefixIcon: Icon(icon, color: AppTheme.backgroundBlue),
        suffixIcon: suffixIcon, // Add suffix icon if provided
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
      ),
    );
  }
}
