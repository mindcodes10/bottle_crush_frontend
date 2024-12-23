import 'package:flutter/material.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import Flutter Secure Storage
import 'package:bottle_crush/screens/login_screen.dart'; // Import your LoginScreen

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56); // Implemented preferredSize
}

class _CustomAppBarState extends State<CustomAppBar> {
  final GlobalKey _iconKey = GlobalKey(); // Key for the profile icon
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage(); // Initialize secure storage

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56), // Adjust the height as needed
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              spreadRadius: 1, // Shadow spread
              blurRadius: 8, // Shadow blur effect
              offset: const Offset(0, 4), // Shadow offset
            ),
          ],
        ),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(0), // Remove padding for larger image
            child: Image.asset(
              'assets/images/bottle_crusher_logo.png', // Replace with the path to your logo
              fit: BoxFit.cover, // Ensure the image covers the space
              width: 70, // Set a fixed width to maximize the size (adjust as needed)
              height: 70, // Set a fixed height to keep the logo proportionate (adjust as needed)
            ),
          ),
          actions: [
            IconButton(
              key: _iconKey, // Assign the GlobalKey to the IconButton
              icon: const Icon(
                Icons.account_circle,
                color: AppTheme.backgroundBlue,
              ),
              iconSize: 45,
              onPressed: () {
                // Show the logout menu when the profile icon is clicked
                _showLogoutMenu(context);
              },
            ),
          ],
          backgroundColor: Colors.white, // Optional: Set AppBar color
        ),
      ),
    );
  }

  // Function to show the logout menu
  void _showLogoutMenu(BuildContext context) {
    // Check if the key's current context is available
    if (_iconKey.currentContext == null) {
      return; // Exit if the context is not available
    }

    RenderBox renderBox = _iconKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    double x = offset.dx;
    double y = offset.dy + renderBox.size.height; // Position below the icon

    showMenu(
      color: AppTheme.backgroundBlue,
      context: context,
      position: RelativeRect.fromLTRB(x, y, x, y), // Adjust position based on icon
      items: [
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppTheme.backgroundWhite),
            title: const Text('Logout', style: TextStyle(color: AppTheme.textWhite)),
            onTap: () {
              // Handle logout action
              print("Logging out");
              Navigator.pop(context); // Close the menu
              _logoutUser (context); // Call the logout function
            },
          ),
        ),
      ],
      elevation: 8.0,
    );
  }

  // Function to handle user logout
  void _logoutUser (BuildContext context) async {
    // Clear the token or user session from secure storage
    await _secureStorage.delete(key: 'access_token'); // Replace 'userToken' with your actual key

    // Redirect to the login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Replace with your login screen
          (Route<dynamic> route) => false, // Remove all previous routes
    );
  }
}