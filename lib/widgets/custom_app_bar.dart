import 'package:bottle_crush/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bottle_crush/utils/theme.dart';
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
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Initialize secure storage
  final ApiServices _apiService = ApiServices(); // Initialize ApiService

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56), // Adjust the height as needed
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
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
            padding: const EdgeInsets.only(left: 7),
            child: Image.asset(
              'assets/images/aquazen_logo.png',
              fit: BoxFit.cover,
              width: 70,
              height: 70,
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
          scrolledUnderElevation: 0,
          backgroundColor: AppTheme.backgroundWhite,
        ),
      ),
    );
  }

  // Function to show the logout menu
  void _showLogoutMenu(BuildContext context) {
    if (_iconKey.currentContext == null) {
      return;
    }

    RenderBox renderBox = _iconKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    double x = offset.dx;
    double y = offset.dy + renderBox.size.height;

    showMenu(
      color: AppTheme.backgroundBlue,
      context: context,
      position: RelativeRect.fromLTRB(x, y, x, y),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      items: [
        PopupMenuItem(
          value: 'logout',
          padding: EdgeInsets.zero,
          child: Container(
            height: 29.0,
            alignment: Alignment.center,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.exit_to_app, color: AppTheme.backgroundWhite),
                SizedBox(width: 4.0),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 'logout') {
        _logoutUser(context);
      }
    });
  }

  // Function to handle user logout
  void _logoutUser(BuildContext context) async {
    try {
      // Retrieve token from secure storage
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing or invalid.");
      }

      // Clear the token from secure storage
      await _secureStorage.delete(key: 'access_token');

      // Redirect to the login page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle errors during logout
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during logout.')),
      );
    }
  }

}