import 'package:bottle_crush/screens/email.dart';
import 'package:bottle_crush/screens/view_business.dart';
import 'package:bottle_crush/screens/view_machines.dart';
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

    // Handle navigation logic based on the tapped index
    if (index == 1) {
      // Navigate to the ViewBusiness page when the "Business" tab is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewBusiness()),
      );
    } else if (index == 2) {
      // Navigate to the ViewMachines page when the "Machine" tab is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewMachines()),
      );
    } else if(index == 3) {
      // Navigate to the ViewMachines page when the "Machine" tab is tapped
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Email()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Use the custom app bar widget here
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped, selectedIndex: _selectedIndex, // Pass the callback for bottom nav
      ),
      // You can add the body of the Dashboard screen here if required
      body: Center(
        child: Text('Dashboard Content Here'), // Placeholder for dashboard content
      ),
    );
  }
}
