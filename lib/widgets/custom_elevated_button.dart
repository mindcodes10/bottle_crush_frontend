import 'package:bottle_crush/utils/theme.dart';
import 'package:flutter/material.dart';

// Define the custom button widget
class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120, // Set a specific width for the button
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.backgroundBlue,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Adjusted padding for smaller button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0), // Reduced border radius for a smaller button
          ),
          minimumSize: const Size(120, 30), // Small button size
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 14, // Smaller font size for a more compact look
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
