import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/screens/login_screen.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final GlobalKey _iconKey = GlobalKey();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isDarkMode = false; // Track dark mode state

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
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
              height: 60,
            ),
          ),
          actions: [
            IconButton(
              key: _iconKey,
              icon: const Icon(
                Icons.account_circle,
                color: AppTheme.backgroundBlue,
              ),
              iconSize: 45,
              onPressed: () {
                _showMenu(context);
              },
            ),
          ],
          scrolledUnderElevation: 0,
          backgroundColor: _isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundWhite,
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
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
        // Dark Mode Toggle
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          height: 35,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Uniform padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dark Mode",
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 14,
                  ),
                ),
                Transform.scale(
                  scale: 0.7, // Adjust switch size
                  child: Switch(
                    value: _isDarkMode,
                    activeColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divider
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          height: 5,
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        // Logout Option
        PopupMenuItem(
          value: 'logout',
          padding: EdgeInsets.zero,
          height: 35,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Uniform padding
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to start
              children: [
                Icon(Icons.exit_to_app, color: AppTheme.backgroundWhite, size: 18),
                SizedBox(width: 8), // Adjust spacing for better alignment
                Text(
                  'Logout',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 14,
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

  void _logoutUser(BuildContext context) async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing or invalid.");
      }

      await _secureStorage.delete(key: 'access_token');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      debugPrint('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during logout.')),
      );
    }
  }
}
