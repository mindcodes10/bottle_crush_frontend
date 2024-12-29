import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart'; // For file picker functionality
import 'package:bottle_crush/screens/email.dart';
import 'package:bottle_crush/screens/view_business.dart';
import 'package:bottle_crush/screens/view_machines.dart';
import 'package:bottle_crush/services/api_services.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  // Sample data to simulate API results
  int totalMachineCount = 0;
  int totalBusinessCount = 0;
  int totalBottleCount = 0;
  double totalBottleWeight = 0.0;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final ApiServices _apiService = ApiServices(); // Instance of ApiService
  String? token;
   // Replace with the actual token

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    token = await _secureStorage.read(key: 'access_token');
    try {
      // Fetch the business count using ApiService
      int businessCount = await _apiService.fetchBusinessCount(token!);

      // Fetch the machines count using ApiService
      int machineCount = await _apiService.fetchMachinesCount(token!);

      // Fetch the bottle statistics using the new function
      Map<String, dynamic> bottleStats = await _apiService.fetchAdminBottleStats(token!);

      // Update the state with the fetched values
      setState(() {
        totalBusinessCount = businessCount;
        totalMachineCount = machineCount;
        totalBottleCount = bottleStats['total_count'].toInt();  // Ensure the count is an integer
        totalBottleWeight = bottleStats['total_weight'];
      });
    } catch (e) {
      // Handle errors appropriately (e.g., show a snack bar)
      debugPrint('Error fetching dashboard data: $e');
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewBusiness()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewMachines()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Email()),
      );
    }
  }



  Future<void> exportToExcel() async {
    // Fetch the token from secure storage
    token = await _secureStorage.read(key: 'access_token');

    try {
      // Fetch the daywise bottle stats from the API
      Map<String, dynamic>? bottleStats = await _apiService.getDaywiseBottleStats(token!);

      var excel = Excel.createExcel(); // Create a new Excel file
      Sheet sheet = excel['Sheet1']; // Create a sheet

      // Set headers for the Excel sheet
      sheet.appendRow(['Date', 'Business Name', 'Machine Name', 'Bottle Count', 'Bottle Weight']);

      // Loop through the bottle stats and add data to the sheet
      bottleStats?.forEach((date, businesses) {
        businesses.forEach((businessName, machines) {
          for (var machine in machines) {
            sheet.appendRow([
              date,
              businessName,
              machine['machine_name'],
              machine['total_bottles'],
              machine['total_weight']
            ]);
          }
        });
      });

      // Encode the Excel file
      var bytes = await excel.encode();

      // Open file picker for user to select save location
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        // User selected a directory, save the file
        String filePath = '$selectedDirectory/bottle_stats.xlsx';
        File file = File(filePath);
        file.createSync(recursive: true);
        file.writeAsBytesSync(bytes!);

        // Notify user about the saved file
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved to $filePath')),
        );

        // Optionally open the file after saving
       // OpenFile.open(filePath);
      } else {
        // User canceled the save dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File save canceled.')),
        );
      }
    } catch (e) {
      // Handle any errors
      debugPrint('Error exporting to Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export file.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Getting screen width and height for responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjusting sizes based on screen size
    double cardWidth = screenWidth * 0.4;
    double cardHeight = screenHeight * 0.2;
    double iconSize = cardWidth * 0.2;
    double titleFontSize = cardWidth * 0.09;
    double valueFontSize = cardWidth * 0.1;

    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
      backgroundColor: AppTheme.backgroundWhite,
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData, // Calls the fetch data method
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Ensure the list can always be pulled down
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Admin Dashboard',
                      style: TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    ),
                    CustomElevatedButton(
                      buttonText: 'Export to Excel',
                      onPressed: exportToExcel, // Call validateCredentials on submit
                      width: screenWidth * 0.45,
                      height: 45,
                      backgroundColor: AppTheme.backgroundBlue,
                      icon: const Icon(
                        FontAwesomeIcons.solidFileExcel,
                        color: AppTheme.backgroundWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDashboardCard(
                      title: "Total Machines",
                      value: totalMachineCount.toString(),
                      icon: FontAwesomeIcons.box,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      iconSize: iconSize,
                      titleFontSize: titleFontSize,
                      valueFontSize: valueFontSize,
                    ),
                    _buildDashboardCard(
                      title: "Total Companies",
                      value: totalBusinessCount.toString(),
                      icon: FontAwesomeIcons.briefcase,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      iconSize: iconSize,
                      titleFontSize: titleFontSize,
                      valueFontSize: valueFontSize,
                      onTap: () {
                        // Navigate to ViewBusiness screen when the card is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ViewBusiness()),
                        );
                      },
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
    VoidCallback? onTap,  // Add an onTap callback
  }) {
    return GestureDetector(
      onTap: onTap,  // Trigger the onTap callback when the card is tapped
      child: Card(
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
      ),
    );
  }

}
