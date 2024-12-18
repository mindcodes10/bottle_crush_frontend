import 'package:bottle_crush/screens/view_business.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

    // Handle navigation logic
    if (index == 1) {
      // Navigate to the ViewBusiness page when the "Business" tab is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewBusiness()),
      );
    } else {
      // Handle other navigation cases if needed
      print('Selected Index: $index');
    }
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
