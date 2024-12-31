import 'package:bottle_crush/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bottle_crush/utils/theme.dart';
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
  String resetToken = ""; // Declare a variable to store the reset token

  final ApiServices apiServices = ApiServices();

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
                          onPressed: () async {
                            if (emailController.text.isEmpty) {
                              showSnackbar("Please enter your email");
                              return;
                            }
                            // Show loading Snack bar
                            showSnackbar("Sending OTP... Please wait.");

                            try {
                              final response = await apiServices.sendForgotPasswordEmail(emailController.text);

                              if (response.containsKey('message')) {
                                // Show success Snack bar
                                showSnackbar("OTP sent successfully! Check your email.");
                                setState(() {
                                  isOtpSent = true;
                                });
                              } else {
                                showSnackbar("Email not found... please enter valid email");
                              }
                            } catch (e) {
                              showSnackbar("Email not found... please enter valid email");
                              debugPrint(e.toString());
                            }
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
                          onPressed: () async {
                            // Check if all OTP fields are filled
                            if (otpControllers.any((controller) => controller.text.isEmpty)) {
                              showSnackbar("Please enter all digits of OTP");
                              return;
                            }

                            // Show loading Snack bar
                            showSnackbar("Verifying OTP... Please wait.");

                            // Extract OTP from controllers
                            String otp = otpControllers.map((e) => e.text).join();

                            try {
                              final response = await apiServices.verifyOtp(emailController.text, otp);

                              if (response.containsKey('message') && response['message'] == "OTP verified successfully") {
                                // Show success Snack bar
                                showSnackbar("OTP verified successfully.");

                                // Store the reset token from the response
                                setState(() {
                                  resetToken = response['reset_token']; // Store the reset token
                                });

                                // Add delay before showing the new password fields
                                Future.delayed(const Duration(seconds: 5), () {
                                  setState(() {
                                    isOtpVerified = true;  // OTP is verified, now show password fields
                                  });
                                });
                              } else {
                                showSnackbar("Failed to verify OTP. Please try again.");
                              }
                            } catch (e) {
                              showSnackbar("Error verifying OTP. Please try again.");
                              debugPrint(e.toString());
                            }
                          },
                        ),

                      ],
                      if (isOtpVerified) ...[
                        // New Password and Confirm New Password Fields (only visible after OTP is verified)
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
                              color: AppTheme.backgroundBlue,
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
                              color: AppTheme.backgroundBlue,
                            ),
                            onPressed: () {
                              setState(() {
                                isConfirmPasswordObscured =
                                !isConfirmPasswordObscured;
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
                          onPressed: () async {
                            // Check if the new password and confirm password match
                            if (newPasswordController.text != confirmPasswordController.text) {
                              showSnackbar("Passwords do not match");
                              return;
                            }

                            // Check if OTP is verified and token is available
                            if (resetToken.isEmpty) {
                              showSnackbar("OTP verification is required before resetting the password.");
                              return;
                            }

                            try {
                              debugPrint('Reset Token: $resetToken');
                              debugPrint('New Password: ${newPasswordController.text}');

                              // Using the stored resetToken from OTP verification
                              final response = await apiServices.passwordReset(resetToken, newPasswordController.text);

                              debugPrint('Response received: $response');

                              if (response['message'] == 'Password reset successfully') {
                                showSnackbar("Password reset successfully!");
                                Navigator.pop(context); // Redirect to Login Page
                              } else {
                                showSnackbar("Failed to reset password. Please try again.");
                              }
                            } catch (e) {
                              showSnackbar("Error resetting password. Please try again.");
                              debugPrint(e.toString());
                            }
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
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 12),
        prefixIcon: Icon(
          icon,
          color: AppTheme.backgroundBlue,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
