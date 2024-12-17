import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(),  // Use the custom app bar widget here
      body: Center(
        child: Text('Dashboard Content'),
      ),

    );
  }
}
