import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:flutter/material.dart';

class AddMachines extends StatefulWidget {
  const AddMachines({super.key});

  @override
  State<AddMachines> createState() => _AddMachinesState();
}

class _AddMachinesState extends State<AddMachines> {
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
      appBar: const CustomAppBar(),
      bottomNavigationBar: CustomBottomAppBar(onItemTapped: _onItemTapped, selectedIndex: _selectedIndex),
    );
  }
}
