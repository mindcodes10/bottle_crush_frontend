import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_services.dart';
import '../utils/theme.dart';
import 'dart:async';

class LineChartScreen extends StatefulWidget {
  const LineChartScreen({super.key});

  @override
  LineChartScreenState createState() => LineChartScreenState();
}

class LineChartScreenState extends State<LineChartScreen> {
  List<FlSpot> chartData = [];
  bool isLoading = true;
  bool hasTimeoutOccurred = false; // Track if the timeout occurred
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiServices _apiService = ApiServices();
  Timer? _timeoutTimer; // Timer to track timeout
  double maxCrushedBottles = 0; // Declare maxCrushedBottles at class level


  @override
  void initState() {
    super.initState();
    startTimeout(); // Start the timeout timer
    fetchData();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  void startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (isLoading) {
        setState(() {
          isLoading = false; // Stop loading
          hasTimeoutOccurred = true; // Mark timeout
        });
      }
    });
  }

  Future<void> fetchData() async {
    try {
      String? token = await _secureStorage.read(key: 'access_token');

      if (token == null) {
        throw Exception("No access token found");
      }

      final response = await _apiService.getDaywiseBottleStats(token);

      debugPrint('API Response: $response');

      if (response != null && response is Map<String, dynamic>) {
        // Process and populate chart data
        setState(() {
          chartData = processChartData(response);
          maxCrushedBottles = getMaxCrushedBottles(chartData);
          isLoading = false;
        });
        _timeoutTimer?.cancel(); // Cancel the timer as data is loaded
        debugPrint("Maximum number of bottle crushed : $maxCrushedBottles");
      } else {
        throw Exception('Failed to load data or empty response');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasTimeoutOccurred = true;
      });
      debugPrint('Error fetching data: $e');
    }
  }

  List<FlSpot> processChartData(Map<String, dynamic> response) {
    // Process chart data here (same as existing logic)
    List<DateTime> last15Days = List.generate(15, (index) {
      return DateTime.now().subtract(Duration(days: index));
    });

    List<FlSpot> chartDataTemp = [];
    List<DateTime> reversedLast15Days = last15Days.reversed.toList();

    for (var date in reversedLast15Days) {
      double totalBottlesForDay = 0;
      String dateString = date.toIso8601String().split('T')[0];
      if (response.containsKey(dateString)) {
        var businesses = response[dateString];

        if (businesses is Map<String, dynamic>) {
          businesses.forEach((businessName, machines) {
            if (machines is List) {
              for (var machine in machines) {
                if (machine['total_bottles'] != null) {
                  totalBottlesForDay += machine['total_bottles'];
                }
              }
            }
          });
        }
      }

      int index = reversedLast15Days.indexOf(date);
      chartDataTemp.add(FlSpot(index.toDouble(), totalBottlesForDay));
    }
    return chartDataTemp;
  }

  double getMaxCrushedBottles(List<FlSpot> chartData) {
    if (chartData.isEmpty) return 0;
    return chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
  }

  double getDynamicInterval(double maxValue) {
    if (maxValue <= 0) return 1; // Default case for zero or negative values

    double rawInterval = (maxValue / 3).ceilToDouble(); // Ensure at most 3 intervals above 0
    double magnitude = (rawInterval / 10).floorToDouble() * 10;

    return magnitude > 0 ? magnitude : rawInterval; // Ensure minimum interval of 1
  }


  @override
  Widget build(BuildContext context) {
    double dynamicInterval = getDynamicInterval(maxCrushedBottles);

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundCard,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasTimeoutOccurred && chartData.isEmpty) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundCard,
        body: Center(
          child: Text(
            "No data found",
            style: TextStyle(fontSize: 16, color: AppTheme.textBlack),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundCard,
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10,bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bottle Count per day", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textBlack)),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 16 / 6,
              child: LineChart(
                LineChartData(
                  backgroundColor: AppTheme.backgroundCard,
                  lineTouchData: const LineTouchData(
                    handleBuiltInTouches: true,
                  ),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < chartData.length) {
                            DateTime date = DateTime.now().subtract(Duration(days: chartData.length - 1 - index));
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(fontSize: 10.5,
                                    color: AppTheme.textBlack
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        getTitlesWidget: (value, meta) {
                          if (value % dynamicInterval == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10.5, color: AppTheme.textBlack),
                            );
                          }
                          return const SizedBox();
                        },
                        showTitles: true,
                        interval: dynamicInterval, // Use dynamically determined interval
                        reservedSize: 70,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false,),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      barWidth: 2,
                      color: AppTheme.startColor,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.startColor.withOpacity(0.5),
                            AppTheme.transparent,
                          ],
                        ),
                      ),
                      dotData: const FlDotData(show: true),
                    )
                  ],
                  minX: 0,
                  maxX: chartData.isEmpty ? 0 : chartData.length - 1,
                  minY: 0,
                  maxY: chartData.isEmpty
                      ? 0
                      : chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

