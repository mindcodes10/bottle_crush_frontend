import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bottle_crush/utils/theme.dart';

class CustomBottomAppBar extends StatefulWidget {
  final Function(int) onItemTapped;
  final int selectedIndex;

  const CustomBottomAppBar({
    super.key,
    required this.onItemTapped,
    required this.selectedIndex,
  });

  @override
  State<CustomBottomAppBar> createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Adjust opacity for shadow
            blurRadius: 10, // Adjust the blur radius for shadow softness
            spreadRadius: 1, // Spread the shadow (0 means no spreading)
            offset: const Offset(0, 4), // Position the shadow (x, y)
          ),
        ],
      ),
      child: SizedBox(
        height: 85,
        child: Stack(
          children: [
            Positioned.fill(
              child: BottomAppBar(
                color: AppTheme.backgroundWhite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomNavItem(Icons.home, 'Home', 0),
                    _buildBottomNavItem(Icons.business_center, 'Company', 1),
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
    double screenWidth = MediaQuery.of(context).size.width;
    double lineWidth = screenWidth / 5;

    return SizedBox(
      width: lineWidth,
      child: Container(
        height: 4,
        color: _selectedIndex == index
            ? AppTheme.backgroundBlue
            : Colors.transparent,
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        widget.onItemTapped(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          Icon(
            icon,
            color: _selectedIndex == index
                ? AppTheme.backgroundBlue
                : AppTheme.backgroundBlue,
            size: 25,
          ),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: _selectedIndex == index
                    ? AppTheme.backgroundBlue
                    : AppTheme.backgroundBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontAwesomeNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        widget.onItemTapped(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          FaIcon(
            icon,
            color: _selectedIndex == index
                ? AppTheme.backgroundBlue
                : AppTheme.backgroundBlue,
            size: 22,
          ),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: _selectedIndex == index
                    ? AppTheme.backgroundBlue
                    : AppTheme.backgroundBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
