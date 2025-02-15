import 'dart:async';

import 'package:bottle_crush/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/theme.dart';

class BarChartForCompany extends StatefulWidget {
  const BarChartForCompany({super.key});

  @override
  State<BarChartForCompany> createState() => _BarChartForCompanyState();
}

class _BarChartForCompanyState extends State<BarChartForCompany> {
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

      final response = await _apiService.getDayWiseBottleStatsCompany(token);

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
              color: startColor,
              width: 8,
            )
          ],
        ),
      );
    }

    return barChartDataTemp;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return Scaffold(
        backgroundColor: isDark ? cardDark :backgroundCard,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (hasTimeoutOccurred && barChartData.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? cardDark :backgroundCard,
        body: Center(
          child: Text(
            "No data found",
            style: TextStyle(fontSize: 16, color: isDark ? textWhite :textBlack),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? cardDark :backgroundCard,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Bottle Count per day", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark? textWhite: textBlack)),
            const SizedBox(height: 20),
            AspectRatio(
              aspectRatio: 16 / 6,
              child: BarChart(
                BarChartData(
                  backgroundColor: isDark ? cardDark : backgroundCard,
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
                                style: TextStyle(fontSize: 10.5,
                                    color: isDark ? textWhite : textBlack
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
                          if (value % 10 == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 10.5,
                                  color: isDark ? textWhite : textBlack
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        showTitles: true,
                        interval: 10,
                        reservedSize: 40,
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
                          toY: 0.5, // A small value to show a visible placeholder line
                          color: isDark? backgroundBlue : backgroundBlue, // Distinct color for visibility
                          width: 8,
                        ),
                      ],
                    ),
                  ]
                      : barChartData,
                  groupsSpace: 10,
                  maxY: barChartData.isEmpty
                      ? 1 // Set a small positive maxY to render the placeholder bar
                      : barChartData.map((e) => e.barRods.first.toY).reduce((a, b) => a > b ? a : b),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
