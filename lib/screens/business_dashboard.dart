import 'package:bottle_crush/screens/business_email.dart';
import 'package:bottle_crush/screens/business_view.dart';
import 'package:bottle_crush/screens/machine_view.dart';
import 'package:bottle_crush/services/api_services.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:excel/excel.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class BusinessDashboard extends StatefulWidget {
  final int id;
  const BusinessDashboard({super.key, required this.id});

  @override
  State<BusinessDashboard> createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  int _selectedIndex = 0;

  int totalBottleCount = 0;
  double totalBottleWeight = 0.0;

  final ApiServices _apiServices = ApiServices();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      final stats = await _apiServices.fetchBottleStats(token!);

      setState(() {
        totalBottleCount = stats['total_count']?.toInt() ?? 0;
        totalBottleWeight = stats['total_weight']?.toDouble() ?? 0.0;

        debugPrint('Total Bottle Count : $totalBottleCount');
        debugPrint('Total Bottle Weight : $totalBottleWeight');
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar or a message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dashboard data: $e')),
      );
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchDashboardData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BusinessView(id: widget.id)),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MachineView(id: widget.id)),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BusinessEmail(id: widget.id)),
      );
    }
  }

  Future<void> exportToExcel(BuildContext context) async {
    try {
      print('Starting exportToExcel function...');

      // Retrieve token from secure storage
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing or invalid.");
      }
      print('Token retrieved: $token');

      // Fetch day-wise bottle stats
      final data = await _apiServices.getDayWiseBottleStatsCompany(token);
      if (data == null || data.isEmpty) {
        throw Exception("No data received from API.");
      }
      print('Response from getDayWiseBottleStatsCompany: $data');

      if (data is Map<String, dynamic>) {
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['DayWiseStats'];

        // Add headers
        sheetObject.appendRow(['Date', 'Machine Name', 'Total Bottle Count', 'Total Bottle Weight']);
        print('Excel headers added.');

        // Process each date and its corresponding records
        for (var date in data.keys) {
          List records = data[date];
          for (var record in records) {
            String machineId = record['machine_id']?.toString() ?? '';
            String machineName = '';

            if (machineId.isNotEmpty) {
              try {
                // Fetch machine details using machine_id
                Map<String, dynamic> machineDetails =
                await _apiServices.getMachineDetails(machineId, token);
                machineName = machineDetails['name'] ?? 'Unknown Machine';
              } catch (e) {
                print('Error fetching machine details for ID $machineId: $e');
                machineName = 'Unknown Machine';
              }
            }

            // Append row to Excel
            sheetObject.appendRow([
              date,
              machineName,
              record['total_bottles']?.toString() ?? '0',
              record['total_weight']?.toString() ?? '0.0',
            ]);
          }
        }

        // Encode the Excel file
        List<int>? encodedFile = excel.encode();
        if (encodedFile == null) {
          throw Exception("Error encoding Excel file.");
        }

        // Open file picker for user to select save location
        String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
        if (selectedDirectory != null) {
          // User selected a directory, save the file
          String filePath = '$selectedDirectory/DayWiseBottleStats.xlsx';
          File file = File(filePath);
          file.createSync(recursive: true);
          file.writeAsBytesSync(encodedFile);

          // Notify user about the saved file
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Excel file saved at $filePath')),
          );
        } else {
          // User canceled the save dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File save operation canceled.')),
          );
        }
      } else {
        throw Exception("Unexpected data format received from API.");
      }
    } catch (e) {
      print('Error occurred in exportToExcel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data to Excel: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Company Dashboard',
                      style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                    ),
                    CustomElevatedButton(
                      buttonText: 'Export to Excel',
                      onPressed: () {
                        exportToExcel(context);
                      },
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
