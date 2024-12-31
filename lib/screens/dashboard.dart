import 'dart:async';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  int totalMachineCount = 0;
  int totalBusinessCount = 0;
  int totalBottleCount = 0;
  double totalBottleWeight = 0.0;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final ApiServices _apiService = ApiServices(); // Instance of ApiService
  String? token;

  Timer? _refreshTimer;


  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _startAutoRefresh();
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
        totalBottleCount = bottleStats['total_count'].toInt(); // Ensure the count is an integer
        totalBottleWeight = bottleStats['total_weight'];
      });
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    }
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchDashboardData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
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

  // Example to get app-specific external storage path
  Future<String> getAppStoragePath() async {
    final directory = await getExternalStorageDirectory();
    return directory?.path ?? '/storage/emulated/0/';
  }

  Future<void> exportToExcel(BuildContext context) async {
    try {
      debugPrint('Starting exportToExcel function...');

      // Request storage permission
      if (await Permission.storage.request().isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required to save the file.')),
        );
        return;
      }

      // Retrieve the token from secure storage
      token = await _secureStorage.read(key: 'access_token');
      if (token == null || token!.isEmpty) {
        throw Exception("Access token is missing or invalid.");
      }
      debugPrint('Token retrieved: $token');

      // Fetch day-wise bottle stats
      Map<String, dynamic>? bottleStats = await _apiService.getDaywiseBottleStats(token!);
      if (bottleStats == null || bottleStats.isEmpty) {
        throw Exception("No data received from API.");
      }
      debugPrint('Response from getDaywiseBottleStats: $bottleStats');

      // Create Excel file
      var excel = Excel.createExcel();
      //excel.delete('Sheet1'); // Delete default sheet

      Sheet sheet = excel['Sheet1'];
      sheet.appendRow(['Date', 'Business Name', 'Machine Name', 'Bottle Count', 'Bottle Weight']);
      debugPrint('Excel headers added.');

      // Populate Excel file with data
      bottleStats.forEach((date, businesses) {
        businesses.forEach((businessName, machines) {
          for (var machine in machines) {
            sheet.appendRow([
              date,
              businessName,
              machine['machine_name'] ?? '',
              machine['total_bottles']?.toString() ?? '0',
              machine['total_weight']?.toString() ?? '0.0',
            ]);
          }
        });
      });

      List<int>? encodedFile = excel.encode();
      if (encodedFile == null) {
        throw Exception("Error encoding Excel file.");
      }

      // Generate a unique file name with the current date and time
      String formattedDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String fileName = 'BottleStats_$formattedDate.xlsx';

      // Save file to device storage (e.g., Download directory)
      Directory externalDir = Directory('/storage/emulated/0/Download/Bottle Crush'); // Common Download directory
      if (!await externalDir.exists()) {
        externalDir.createSync(recursive: true);
      }

      String filePath = '${externalDir.path}/$fileName';
      File file = File(filePath);
      file.writeAsBytesSync(encodedFile);

      debugPrint('Excel file saved at $filePath');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel file saved at $filePath')),
      );
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export Excel file.')),
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

    // For larger screens like tablets, adjust layout
    if (screenWidth > 800) {
      cardWidth = screenWidth * 0.3;
      cardHeight = screenHeight * 0.3;
      iconSize = cardWidth * 0.13;
      titleFontSize = cardWidth * 0.05;
      valueFontSize = cardWidth * 0.06;
    }

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
                      style: TextStyle(
                          fontSize: titleFontSize, fontWeight: FontWeight.bold),
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
      ),
    );
  }
}
