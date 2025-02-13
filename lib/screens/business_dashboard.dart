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
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';


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

  Future<void> exportToExcel(BuildContext context) async {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    try {
      debugPrint('Starting exportToExcel function...');

      // Retrieve device information
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      debugPrint('Android Version: ${androidInfo.version.release}');

      // Request storage permissions based on the Android version
      if (androidInfo.version.release.compareTo('12') < 0) {
        // Request permission for Android versions below 12
        if (await Permission.storage.request().isGranted) {
          await _exportFileLogic(context);
        } else {
          debugPrint('Storage permission denied');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Storage permission denied. Please enable it in settings.', style: TextStyle(color: isDark ? textBlack : textWhite),), backgroundColor: isDark ? textWhite : textBlack, duration: const Duration(seconds: 1),),
          );
        }
      } else {
        // No permission request for Android 12 and above (due to Scoped Storage)
        await _exportFileLogic(context);
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Android Version not found',style: TextStyle(color: isDark ? textBlack : textWhite),), backgroundColor: isDark ? textWhite : textBlack, duration: const Duration(seconds: 1),),
      );
    }
  }




  Future<void> _exportFileLogic(BuildContext context) async {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    try {
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
          SnackBar(content: Text('You do not have any machines, so cannot create Excel.', style: TextStyle(color: isDark ? textBlack : textWhite),), backgroundColor: isDark ? textWhite : textBlack, duration: const Duration(seconds: 1),),
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

      List<int>? encodedFile = excel.encode();
      if (encodedFile == null) {
        throw Exception("Error encoding Excel file.");
      }

      String formattedDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      String fileName = 'CompanyBottleStats_$formattedDate.xlsx';

      // Proceed with file saving logic
      await _saveFileToDownloads(fileName, encodedFile, context);

    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export Excel file.', style: TextStyle(color: isDark ? textBlack : textWhite),), backgroundColor: isDark ? textWhite : textBlack, duration: const Duration(seconds: 1),),
      );
    }
  }

  Future<void> _saveFileToDownloads(String fileName, List<int> encodedFile, BuildContext context) async {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    try {
      final downloadDir = Directory('/storage/emulated/0/Download');

      // Ensure the directory exists
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Save file directly to the Downloads folder
      String filePath = '${downloadDir.path}/$fileName';
      File file = File(filePath);
      await file.writeAsBytes(encodedFile);

      debugPrint('Excel file saved at $filePath');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel file saved in "Downloads" folder', style: TextStyle(color: isDark ? textBlack : textWhite),), backgroundColor: isDark ? textWhite : textBlack, duration: const Duration(seconds: 1),),
      );
    } catch (e) {
      debugPrint('Error while saving the file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving Excel file.', style: TextStyle(color: isDark ? textBlack : textWhite),), backgroundColor: isDark ? textWhite : textBlack, duration: const Duration(seconds: 1),),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

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
      backgroundColor: isDark ? textBlack : backgroundWhite,
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
                      style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: isDark ? textWhite : textBlack),
                    ),
                    CustomElevatedButton(
                      buttonText: 'Export to Excel',
                      onPressed: () async {
                        await exportToExcel(context); // Ensure exportToExcel is async
                      },
                      width: screenWidth * 0.45,
                      height: 45,
                      backgroundColor: isDark ? backgroundBlue : backgroundBlue,
                      icon: Icon(
                        FontAwesomeIcons.solidFileExcel,
                        color: isDark ? backgroundWhite : backgroundWhite,
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? cardDark : backgroundCard,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize,
                //color: AppTheme.backgroundBlue
              color: isDark ? backgroundWhite : backgroundBlue,
            ),
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
