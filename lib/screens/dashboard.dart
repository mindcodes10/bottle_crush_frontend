import 'dart:async';
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
import '../widgets/export_to_excel.dart';
import '../widgets/line_chart_widget.dart';



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
        totalBottleCount = bottleStats['total_count'].toInt();
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
    // Cancel timer to prevent memory leaks
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ViewBusiness()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ViewMachines()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Email()),
      );
    }
  }

  //Use the ExportToExcel class for exporting
  Future<void> exportToExcel(BuildContext context) async {
    await ExportToExcel.exportDataToExcel(context, () async {
      String? token = await _secureStorage.read(key: 'access_token');
      if (token == null || token.isEmpty) {
        throw Exception("Access token is missing or invalid.");
      }
      return await _apiService.getDaywiseBottleStats(token);
    });
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
    double containerHeight = screenHeight * 0.28;

    // For larger screens like tablets, adjust layout
    if (screenWidth > 800) {
      cardWidth = screenWidth * 0.3;
      cardHeight = screenHeight * 0.3;
      iconSize = cardWidth * 0.13;
      titleFontSize = cardWidth * 0.05;
      valueFontSize = cardWidth * 0.06;
      containerHeight = screenHeight * 0.95;
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
      backgroundColor: AppTheme.backgroundWhite,
      body: Column(
        children: [
          // Fixed Header with "Dashboard" and "Export to Excel"
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomElevatedButton(
                  buttonText: 'Export to Excel',
                  onPressed: () async {
                    await exportToExcel(context); // Ensure exportToExcel is async
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
          ),
          const SizedBox(height: 10),
          // Scrollable Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ViewBusiness(),
                                ),
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.backgroundCard,
                            border: Border.all(
                              color: AppTheme.backgroundCard, // Set the background color
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35), // Shadow color with opacity
                                blurRadius: 10, // Spread of the shadow
                                offset: const Offset(0, 4), // Position of the shadow (x, y)
                              ),
                            ],
                          ),
                          height: containerHeight,
                          child: const LineChartScreen(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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