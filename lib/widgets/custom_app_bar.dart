import 'package:flutter/material.dart';
import 'package:bottle_crush/utils/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(56), // Adjust the height as needed
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              spreadRadius: 1, // Shadow spread
              blurRadius: 8, // Shadow blur effect
              offset: Offset(0, 4), // Shadow offset
            ),
          ],
        ),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(0), // Remove padding for larger image
            child: Image.asset(
              'assets/images/bottle_crusher_logo.png', // Replace with the path to your logo
              fit: BoxFit.cover, // Ensure the image covers the space
              width: 50, // Set a fixed width to maximize the size (adjust as needed)
              height: 50, // Set a fixed height to keep the logo proportionate (adjust as needed)
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.account_circle,
                color: AppTheme.backgroundBlue,
              ), // User profile icon
              iconSize: 33, // Increase the size of the icon (adjust as needed)
              onPressed: () {
                // Handle user profile action (e.g., navigate to profile page)
                print("User profile clicked");
              },
            ),
          ],
          backgroundColor: Colors.white, // Optional: Set AppBar color
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56); // You can adjust the height here
}
