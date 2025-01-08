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
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';


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

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchDashboardData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BusinessView(id: widget.id)),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MachineView(id: widget.id)),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BusinessEmail(id: widget.id)),
      );
    }
  }

  Future<void> _fetchDashboardData() async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');
      final stats = await _apiServices.fetchBottleStats(token!);

      setState(() {
        totalBottleCount = stats['total_count']?.toInt() ?? 0;
        totalBottleWeight = stats['total_weight']?.toDouble() ?? 0.0;
      });
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');

    }
  }


  Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      debugPrint('Permission granted');
    } else if (status.isDenied) {
      debugPrint('Permission denied');
    } else if (status.isPermanentlyDenied) {
      openAppSettings(); // Let the user open settings to enable permission
    }
  }


  Future<void> exportToExcel(BuildContext context) async {
    try {
      debugPrint('Starting exportToExcel function...');

      // Retrieve token from secure storage
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing or invalid.");
      }
      debugPrint('Token retrieved: $token');

      // Fetch day-wise bottle stats
      final Map<String, List<Map<String, dynamic>>> data = await _apiServices.getDayWiseBottleStatsCompany(token);
      if (data.isEmpty) {
        // No machines found
        debugPrint('No machines found for this company.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You do not have any machines, so cannot create Excel.')),
        );
        return;
      }
      debugPrint('Response from getDayWiseBottleStatsCompany: $data');

      // Initialize Excel file
      var excel = Excel.createExcel();
      Sheet sheet = excel['Sheet1'];
      sheet.appendRow(['Date', 'Machine Name', 'Total Bottle Count', 'Total Bottle Weight']);
      debugPrint('Excel headers added.');

      // Process the data
      data.forEach((date, records) {
        for (var record in records) {
          sheet.appendRow([
            date,
            record['machine_name'] ?? 'Unknown Machine',
            record['total_bottles']?.toString() ?? '0',
            record['total_weight']?.toString() ?? '0.0',
          ]);
        }
      });

      // Encode the Excel file
      List<int>? encodedFile = excel.encode();
      if (encodedFile == null) {
        throw Exception("Error encoding Excel file.");
      }

      // Save the file in the device storage
      Directory externalDir = Directory('/storage/emulated/0/Download/BottleCrush');
      if (!await externalDir.exists()) {
        externalDir.createSync(recursive: true);
      }

      String formattedDateTime = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      String filePath = '${externalDir.path}/CompanyBottleStats_$formattedDateTime.xlsx';
      File file = File(filePath);
      file.writeAsBytesSync(encodedFile);

      debugPrint('Excel file saved at $filePath');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel file saved at $filePath')),
      );
    } catch (e) {
      debugPrint('Error occurred in exportToExcel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not exported')),
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
                      'Dashboard',
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
      color: AppTheme.backgroundCard,
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
