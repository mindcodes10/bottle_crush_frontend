import 'package:flutter/material.dart';

// Reusable Custom Button Widget
class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final double? width; // Optional width to make it flexible
  final double? height; // Optional height to make it flexible
  final Color backgroundColor; // Customizable background color

  const CustomElevatedButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.width,
    this.height,
    this.backgroundColor = Colors.green, // Default green background
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center, // Center alignment
      child: SizedBox(
        width: width ?? 200, // Default width if not provided
        height: height ?? 50, // Default height if not provided
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 20.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Rounded edges
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.white, // White text
              fontSize: 16, // Font size
              fontWeight: FontWeight.bold, // Bold text
            ),
          ),
        ),
      ),
    );
  }
}
