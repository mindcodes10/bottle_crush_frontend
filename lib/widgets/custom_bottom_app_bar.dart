import 'package:bottle_crush/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomBottomAppBar extends StatelessWidget {
  final Function(int) onItemTapped; // Callback for item tap actions

  const CustomBottomAppBar({super.key, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8, // Add shadow elevation
      color: AppTheme.backgroundWhite, // Background color for the BottomAppBar
      child: SizedBox(
        height: 70, // Reduced height of the BottomAppBar
        child: BottomAppBar(
          color: AppTheme.backgroundWhite, // Ensures consistent color
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home, 'Home', 0),
              _buildBottomNavItem(Icons.business_center, 'Business', 1),
              _buildFontAwesomeNavItem(FontAwesomeIcons.box, 'Machine', 2),
              _buildBottomNavItem(Icons.email_sharp, 'Email', 3),
            ],
          ),
        ),
      ),
    );
  }

  // A reusable widget to build bottom navigation items with standard icons
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => onItemTapped(index), // Trigger the callback with index
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.backgroundBlue,
            size: 25, // Adjust the icon size to match reduced height
          ),
          const SizedBox(height: 2), // Reduced spacing between icon and text
          Text(
            label,
            style: const TextStyle(
              fontSize: 12, // Reduced font size for better fit
              color: AppTheme.backgroundBlue,
            ),
          ),
        ],
      ),
    );
  }

  // A reusable widget to build bottom navigation items with Font Awesome icons
  Widget _buildFontAwesomeNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () => onItemTapped(index), // Trigger the callback with index
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            color: AppTheme.backgroundBlue,
            size: 22, // Adjust icon size to match reduced height
          ),
          const SizedBox(height: 2), // Reduced spacing between icon and text
          Text(
            label,
            style: const TextStyle(
              fontSize: 12, // Reduced font size for better fit
              color: AppTheme.backgroundBlue,
            ),
          ),
        ],
      ),
    );
  }
}
