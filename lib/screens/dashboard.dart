import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0; // Track the selected index for bottom nav items

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation logic here based on the index
    print('Selected Index: $index'); // Example print statement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // Use the custom app bar widget here
      body: Center(
        child: Text(
          'Dashboard Content - Tab $_selectedIndex',
          style: const TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped, // Pass the callback
      ),
    );
  }
}
