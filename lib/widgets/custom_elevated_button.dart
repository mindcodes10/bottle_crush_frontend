import 'package:flutter/material.dart';

// Reusable Custom Button Widget
class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final double? width; // Optional width to make it flexible
  final double? height; // Optional height to make it flexible
  final Color backgroundColor; // Customizable background color
  final Color textColor; // Customizable text color
  final Color? borderColor; // Optional customizable border color
  final Icon? icon; // Optional prefix icon

  const CustomElevatedButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.width,
    this.height,
    this.backgroundColor = Colors.green, // Default green background
    this.textColor = Colors.white, // Default white text color
    this.borderColor, // Optional border color
    this.icon, // Optional prefix icon
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
              side: borderColor != null
                  ? BorderSide(color: borderColor!, width: 2.0) // Add border if specified
                  : BorderSide.none, // No border if not specified
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!, // Display the prefix icon if provided
                const SizedBox(width: 8.0), // Space between icon and text
              ],
              Text(
                buttonText,
                style: TextStyle(
                  color: textColor, // Custom text color
                  fontSize: 16, // Font size
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
