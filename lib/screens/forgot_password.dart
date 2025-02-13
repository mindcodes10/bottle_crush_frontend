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
  bool isNewPasswordObscured = true; /// State for New Password visibility
  bool isConfirmPasswordObscured = true; /// State for Confirm Password visibility
  String resetToken = ""; /// Declare a variable to store the reset token

  final ApiServices apiServices = ApiServices();

  void showSnackBar(String message) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message,style: TextStyle(color: isDark? textBlack: textWhite),), backgroundColor: isDark? backgroundWhite : textBlack, duration: const Duration(seconds: 2),),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: isDark ? backgroundBlue: backgroundBlue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: screenHeight * 0.02),
          /// Back Arrow Button
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 30, color: isDark ? textWhite: textWhite,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
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
          Center(
            child: Text(
              "Welcome to Aquazen!",
              style: TextStyle(
                color: isDark ? textWhite: textWhite,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Forgot Password",
              style: TextStyle(
                color: isDark ? textWhite: textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: screenHeight * 0.1),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? textBlack : backgroundWhite,
                borderRadius: const BorderRadius.only(
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
                      Center(
                        child: Text(
                          "Reset your password here",
                          style: TextStyle(
                            color: isDark ? textWhite: textBlack,
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
                          width: screenWidth * 0.34,
                          height: screenHeight * 0.05,
                          backgroundColor: isDark ? backgroundBlue: backgroundBlue,
                          textColor: isDark ? textWhite: textWhite,
                          onPressed: () async {
                            if (emailController.text.isEmpty) {
                              showSnackBar("Please enter your email", );
                              return;
                            }
                            // Show loading Snack bar
                            showSnackBar("Sending OTP... Please wait.");

                            try {
                              final response = await apiServices.sendForgotPasswordEmail(emailController.text);

                              if (response.containsKey('message')) {
                                // Show success Snack bar
                                showSnackBar("OTP sent successfully! Check your email.");
                                setState(() {
                                  isOtpSent = true;
                                });
                              } else {
                                showSnackBar("Email not found... please enter valid email");
                              }
                            } catch (e) {
                              showSnackBar("Email not found... please enter valid email");
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
                          width: screenWidth * 0.38,
                          height: screenHeight * 0.05,
                          backgroundColor: isDark ? backgroundBlue: backgroundBlue,
                          textColor: isDark ? textWhite: textWhite,
                          onPressed: () async {
                            // Check if all OTP fields are filled
                            if (otpControllers.any((controller) => controller.text.isEmpty)) {
                              showSnackBar("Please enter all digits of OTP");
                              return;
                            }

                            // Show loading Snack bar
                            showSnackBar("Verifying OTP... Please wait.");

                            // Extract OTP from controllers
                            String otp = otpControllers.map((e) => e.text).join();

                            try {
                              final response = await apiServices.verifyOtp(emailController.text, otp);

                              if (response.containsKey('message') && response['message'] == "OTP verified successfully") {
                                // Show success Snack bar
                                showSnackBar("OTP verified successfully.");

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
                                showSnackBar("Failed to verify OTP. Please try again.");
                              }
                            } catch (e) {
                              showSnackBar("Error verifying OTP. Please try again.");
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
                              color: isDark ? backgroundBlue: backgroundBlue,
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
                              color: isDark ? backgroundBlue: backgroundBlue,
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
                          width: screenWidth * 0.42,
                          backgroundColor: isDark ? backgroundBlue: backgroundBlue,
                          textColor: isDark ? textWhite: textWhite,
                          icon: Icon(Icons.check,
                            color: isDark ? textWhite: textWhite,
                          ),
                          onPressed: () async {
                            // Check if the new password and confirm password match
                            if (newPasswordController.text != confirmPasswordController.text) {
                              showSnackBar("Passwords do not match");
                              return;
                            }

                            // Check if OTP is verified and token is available
                            if (resetToken.isEmpty) {
                              showSnackBar("OTP verification is required before resetting the password.");
                              return;
                            }

                            try {
                              debugPrint('Reset Token: $resetToken');
                              debugPrint('New Password: ${newPasswordController.text}');

                              // Using the stored resetToken from OTP verification
                              final response = await apiServices.passwordReset(resetToken, newPasswordController.text);

                              debugPrint('Response received: $response');

                              if (response['message'] == 'Password reset successfully') {
                                showSnackBar("Password reset successfully!");
                                Navigator.pop(context); // Redirect to Login Page
                              } else {
                                showSnackBar("Failed to reset password. Please try again.");
                              }
                            } catch (e) {
                              showSnackBar("Error resetting password. Please try again.");
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
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
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: isDark? Colors.grey : Colors.grey.shade700, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:isDark? Colors.grey: Colors.grey.shade700, width: 2.0,
                ),
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(fontSize: 12, color: isDark ? textWhite : textBlack),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
        prefixIcon: Icon(
          icon,
          color: isDark ? backgroundBlue: backgroundBlue,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color:isDark? Colors.grey.shade400: textBlack),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color:isDark? Colors.grey.shade400: textBlack, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
