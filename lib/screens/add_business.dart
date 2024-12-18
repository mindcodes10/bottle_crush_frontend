import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:flutter/material.dart';

class AddBusiness extends StatefulWidget {
  const AddBusiness({super.key});

  @override
  State<AddBusiness> createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {
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
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped, // Pass the callback
      ),
    );
  }
}
