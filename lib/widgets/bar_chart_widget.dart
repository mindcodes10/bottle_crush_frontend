import 'dart:async';
import 'package:bottle_crush/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/theme.dart';

class BarChartWidget extends StatefulWidget {
  const BarChartWidget({super.key});

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  List<BarChartGroupData> barChartData = [];
  bool isLoading = true;
  bool hasTimeoutOccurred = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiServices _apiService = ApiServices();
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    startTimeout();
    fetchData();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (isLoading) {
        setState(() {
          isLoading = false;
          hasTimeoutOccurred = true;
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

      if (response != null && response is Map<String, dynamic>) {
        setState(() {
          barChartData = processBarChartData(response);
          isLoading = false;
        });
        _timeoutTimer?.cancel();
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

  List<BarChartGroupData> processBarChartData(Map<String, dynamic> response) {
    List<DateTime> last15Days = List.generate(15, (index) {
      return DateTime.now().subtract(Duration(days: index));
    }).reversed.toList();

    List<BarChartGroupData> barChartDataTemp = [];
    for (var date in last15Days) {
      String dateString = date.toIso8601String().split('T')[0];
      double totalBottlesForDay = 0;

      if (response[dateString] is Map<String, dynamic>) {
        response[dateString].forEach((businessName, machines) {
          if (machines is List) {
            totalBottlesForDay += machines.fold(0, (sum, machine) {
              return sum + (machine['total_bottles'] ?? 0);
            });
          }
        });
      }

      barChartDataTemp.add(
        BarChartGroupData(
          x: last15Days.indexOf(date),
          barRods: [
            BarChartRodData(
              toY: totalBottlesForDay,
              color: AppTheme.startColor,
              width: 8,
            )
          ],
        ),
      );
    }

    return barChartDataTemp;
  }

  double getDynamicInterval(double maxValue) {
    if (maxValue <= 0) return 1; // Default case for zero or negative values

    double rawInterval = (maxValue / 3).ceilToDouble(); // Ensures at most 3 intervals above 0
    double magnitude = (rawInterval / 10).floorToDouble() * 10;

    return magnitude > 0 ? magnitude : rawInterval; // Ensure minimum interval of 1
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundCard,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasTimeoutOccurred && barChartData.isEmpty) {
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

    double maxY = barChartData.isEmpty
        ? 1
        : barChartData.map((e) => e.barRods.first.toY).reduce((a, b) => a > b ? a : b);

    double interval = getDynamicInterval(maxY);

    return Scaffold(
      backgroundColor: AppTheme.backgroundCard,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bottle Count per day",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textBlack,
              ),
            ),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 16 / 6,
              child: BarChart(
                BarChartData(
                  backgroundColor: AppTheme.backgroundCard,
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
                          if (index % 2 == 0) {
                            DateTime date = DateTime.now().subtract(Duration(days: barChartData.length - 1 - index));
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(fontSize: 10.5, color: AppTheme.textBlack),
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
                          if (value % interval == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10.5, color: AppTheme.textBlack),
                            );
                          }
                          return const SizedBox();
                        },
                        showTitles: true,
                        interval: interval,
                        reservedSize: 70,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barChartData.isEmpty
                      ? [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 0.5,
                          color: AppTheme.backgroundBlue,
                          width: 8,
                        ),
                      ],
                    ),
                  ]
                      : barChartData,
                  groupsSpace: 10,
                  maxY: (interval * 3).toDouble(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

