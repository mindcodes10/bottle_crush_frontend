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
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
//import 'package:android_intent_plus/android_intent.dart';
//import 'package:android_intent_plus/flag.dart';
//import 'package:android_intent_plus/action.dart';



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

      // Retrieve token from secure storage
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing or invalid.");
      }
      debugPrint('Token retrieved: $token');

      // Fetch day-wise bottle stats
      final data = await _apiServices.getDayWiseBottleStatsCompany(token);
      if (data == null || data.isEmpty) {
        throw Exception("No data received from API.");
      }
      debugPrint('Response from getDayWiseBottleStatsCompany: $data');

      if (data is Map<String, dynamic>) {
        var excel = Excel.createExcel();
        //excel.delete('Sheet1'); // Delete default Sheet1

        //Sheet sheetObject = excel['DayWiseStats'];
        Sheet sheet = excel['Sheet1'];
        sheet.appendRow(['Date', 'Machine Name', 'Total Bottle Count', 'Total Bottle Weight']);
        debugPrint('Excel headers added.');

        for (var date in data.keys) {
          List records = data[date];
          for (var record in records) {
            String machineId = record['machine_id']?.toString() ?? '';
            String machineName = '';

            if (machineId.isNotEmpty) {
              try {
                Map<String, dynamic> machineDetails =
                await _apiServices.getMachineDetails(machineId, token);
                machineName = machineDetails['name'] ?? 'Unknown Machine';
              } catch (e) {
                debugPrint('Error fetching machine details for ID $machineId: $e');
                machineName = 'Unknown Machine';
              }
            }

            sheet.appendRow([
              date,
              machineName,
              record['total_bottles']?.toString() ?? '0',
              record['total_weight']?.toString() ?? '0.0',
            ]);
          }
        }

        List<int>? encodedFile = excel.encode();
        if (encodedFile == null) {
          throw Exception("Error encoding Excel file.");
        }

        // Get the public directory for saving the file
        Directory? externalDir = Directory('/storage/emulated/0/Download/Bottle Crush'); // Example: Download folder
        if (!await externalDir.exists()) {
          externalDir.createSync(recursive: true);
        }

        // Generate a filename with the current date and time
        String formattedDateTime = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
        String filePath = '${externalDir.path}/CompanyBottleStats_$formattedDateTime.xlsx';

        // Save the Excel file in the device storage
        File file = File(filePath);
        file.writeAsBytesSync(encodedFile);

        debugPrint('Excel file saved at $filePath');

        //showFileSavedSnackBar(context, filePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel file saved at $filePath')),
        );
        // Delay opening the folder for 1 second
        // Future.delayed(Duration(seconds: 1), () {
        //   openFolder('/storage/emulated/0/Download/Bottle Crush');
        // });

      } else {
        throw Exception("Unexpected data format received from API.");
      }
    } catch (e) {
      debugPrint('Error occurred in exportToExcel: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not exported')),
      );
    }
  }

  // void openFolder(String folderPath) async {
  //   final intent = AndroidIntent(
  //     action: 'android.intent.action.VIEW',
  //     data: 'file://$folderPath',  // Pass the string URI directly
  //     type: 'resource/folder',  // Type for folder
  //   );
  //
  //   try {
  //     await intent.launch();
  //   } catch (e) {
  //     print("Could not open folder: $e");
  //   }
  // }

  void showFileSavedSnackBar(BuildContext context, String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Excel file saved at $filePath'),
        action: SnackBarAction(
          label: 'Open Folder',
          onPressed: () async {
            try {
              // Get the directory path from the file path
              final directoryPath = filePath.substring(0, filePath.lastIndexOf(Platform.pathSeparator));

              // Check if the directory exists
              final directory = Directory(directoryPath);
              if (!directory.existsSync()) {
                debugPrint('Directory does not exist at $directoryPath');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Directory does not exist')),
                );
                return;
              }

              // Call platform-specific code to open the directory
              await openDirectory(directoryPath);
            } catch (e) {
              debugPrint('Error: ${e.toString()}');
              // Handle any errors and provide the user with feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('An error occurred while opening the directory')),
              );
            }
          },
        ),
      ),
    );
  }

// Method to open the directory using platform channels
  Future<void> openDirectory(String path) async {
    try {
      const platform = MethodChannel('com.example.openDirectory');
      // Check if the path is not empty
      if (path.isEmpty) {
        debugPrint('The directory path is empty');
        throw PlatformException(code: 'INVALID_PATH', message: 'Invalid directory path');
      }
      await platform.invokeMethod('openDirectory', {'path': path});
    } on PlatformException catch (e) {
      debugPrint("Failed to open directory: '${e.message}'");
    } catch (e) {
      debugPrint('Error: $e');
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
