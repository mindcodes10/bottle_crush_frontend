import 'package:bottle_crush/screens/business_email.dart';
import 'package:bottle_crush/screens/business_view.dart';
import 'package:bottle_crush/screens/machine_view.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BusinessDashboard extends StatefulWidget {
  final int id;
  const BusinessDashboard({super.key, required this.id});

  @override
  State<BusinessDashboard> createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  int _selectedIndex = 0;

  // Sample data to simulate API results
  int totalBottleCount = 0;
  double totalBottleWeight = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    // Simulating a network/API call
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        totalBottleCount = 1400;
        totalBottleWeight = 320.5;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BusinessView(id:widget.id)),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MachineView(id:widget.id)),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BusinessEmail(id:widget.id)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Getting screen width and height for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Adjusting sizes based on screen size
    double cardWidth = screenWidth * 0.4;
    double cardHeight = screenHeight * 0.2;
    double iconSize = cardWidth * 0.2;
    double titleFontSize = cardWidth * 0.09;
    double valueFontSize = cardWidth * 0.1;
    // double titleFontSize = 18 * textScaleFactor;
    // double valueFontSize = 22 * textScaleFactor;

    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
      backgroundColor: AppTheme.backgroundWhite,
      body: SingleChildScrollView( // Wraps the content in a scrollable widget
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Business Dashboard',
                    style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                  ),
                  CustomElevatedButton(
                    buttonText: 'Export to Excel',
                    onPressed: (){}, // Call validateCredentials on submit
                    width: screenWidth * 0.45,
                    height: 45,
                    backgroundColor: AppTheme.backgroundBlue,
                    icon: const Icon(FontAwesomeIcons.solidFileExcel, color: AppTheme.backgroundWhite,),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDashboardCard(
                    title: "Total Bottles",
                    value: totalBottleCount.toString(),
                    icon: FontAwesomeIcons.bottleWater,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    iconSize: iconSize,
                    titleFontSize: titleFontSize,
                    valueFontSize: valueFontSize,
                  ),
                  _buildDashboardCard(
                    title: "Bottle Weight (kg)",
                    value: totalBottleWeight.toStringAsFixed(1),
                    icon: FontAwesomeIcons.weightHanging,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    iconSize: iconSize,
                    titleFontSize: titleFontSize,
                    valueFontSize: valueFontSize,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required double cardWidth,
    required double cardHeight,
    required double iconSize,
    required double titleFontSize,
    required double valueFontSize,
  }) {
    return Card(
      color: AppTheme.backgroundWhite,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: AppTheme.backgroundBlue),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: titleFontSize)),
            //const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
