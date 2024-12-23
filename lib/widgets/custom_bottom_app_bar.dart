import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bottle_crush/utils/theme.dart';

class CustomBottomAppBar extends StatefulWidget {
  final Function(int) onItemTapped; // Callback for item tap actions
  final int selectedIndex; // Pass selected index to maintain consistency

  const CustomBottomAppBar({
    super.key,
    required this.onItemTapped,
    required this.selectedIndex,
  });

  @override
  _CustomBottomAppBarState createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  int _selectedIndex = 0; // Tracks the selected index

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // Initialize with the passed index
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8, // Add shadow elevation
      color: AppTheme.backgroundWhite, // Background color for the BottomAppBar
      child: SizedBox(
        height: 80, // Adjusted height of the BottomAppBar
        child: Stack(
          children: [
            Positioned.fill(
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
            Align(
              alignment: Alignment.topCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTopLine(0),
                  _buildTopLine(1),
                  _buildTopLine(2),
                  _buildTopLine(3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopLine(int index) {
    // Calculate dynamic width based on screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double lineWidth = screenWidth / 5; // Adjust line width proportionally

    return SizedBox(
      width: lineWidth, // Use calculated width
      child: Container(
        height: 4, // Height of the line
        color: _selectedIndex == index
            ? AppTheme.backgroundBlue
            : Colors.transparent, // Show blue line if selected
      ),
    );
  }

  // A reusable widget to build bottom navigation items with standard icons
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index; // Update the selected index
        });
        widget.onItemTapped(index); // Trigger the callback with index
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6), // Spacer for the blue line
          Icon(
            icon,
            color: _selectedIndex == index
                ? AppTheme.backgroundBlue
                : AppTheme.backgroundBlue, // Highlight selected icon
            size: 25, // Adjust the icon size to match reduced height
          ),
          const SizedBox(height: 2), // Reduced spacing between icon and text
          Text(
            label,
            style: TextStyle(
              fontSize: 12, // Reduced font size for better fit
              color: _selectedIndex == index
                  ? AppTheme.backgroundBlue
                  : AppTheme.backgroundBlue, // Highlight selected text
            ),
          ),
        ],
      ),
    );
  }

  // A reusable widget to build bottom navigation items with Font Awesome icons
  Widget _buildFontAwesomeNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index; // Update the selected index
        });
        widget.onItemTapped(index); // Trigger the callback with index
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6), // Spacer for the blue line
          FaIcon(
            icon,
            color: _selectedIndex == index
                ? AppTheme.backgroundBlue
                : AppTheme.backgroundBlue, // Highlight selected icon
            size: 22, // Adjust icon size to match reduced height
          ),
          const SizedBox(height: 2), // Reduced spacing between icon and text
          Text(
            label,
            style: TextStyle(
              fontSize: 12, // Reduced font size for better fit
              color: _selectedIndex == index
                  ? AppTheme.backgroundBlue
                  : AppTheme.backgroundBlue, // Highlight selected text
            ),
          ),
        ],
      ),
    );
  }
}
