import 'package:bottle_crush/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import '../services/api_services.dart';

class BusinessVsMachinesChart extends StatefulWidget {
  const BusinessVsMachinesChart({super.key});

  @override
  State<BusinessVsMachinesChart> createState() =>
      _BusinessVsMachinesChartState();
}

class _BusinessVsMachinesChartState extends State<BusinessVsMachinesChart> {
  final ApiServices _apiServices = ApiServices();
  List<String> _dates = [];
  List<double> _businessTotals = [];
  List<double> _machineTotals = [];
  bool _isLoading = true;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? token;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    token = await _secureStorage.read(key: 'access_token');
    final data = await _apiServices.getDaywiseBottleStats(token!);
    if (data != null) {
      _processData(data);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _processData(Map<String, dynamic> data) {
    List<String> dates = [];
    List<double> businessTotals = [];
    List<double> machineTotals = [];

    DateTime now = DateTime.now();
    DateTime oneMonthAgo = now.subtract(Duration(days: 30));

    data.forEach((date, businesses) {
      DateTime parsedDate = DateTime.parse(date);

      // Filter only last 30 days' data
      if (parsedDate.isAfter(oneMonthAgo) || parsedDate.isAtSameMomentAs(oneMonthAgo)) {
        double totalBusinessBottles = 0;
        double totalMachineBottles = 0;

        businesses.forEach((businessName, machines) {
          double businessBottleCount = 0;
          for (var machine in machines) {
            businessBottleCount += machine["total_bottles"] ?? 0;
            totalMachineBottles += machine["total_bottles"] ?? 0;
          }
          totalBusinessBottles += businessBottleCount;
        });

        /// Convert date from 'YYYY-MM-DD' to 'D/M' format
        String formattedDate = "${parsedDate.day}/${parsedDate.month}";

        dates.add(formattedDate);
        businessTotals.add(totalBusinessBottles);
        machineTotals.add(totalMachineBottles);
      }
    });

    setState(() {
      _dates = dates.reversed.toList(); // Reverse to start from left to right
      _businessTotals = businessTotals.reversed.toList();
      _machineTotals = machineTotals.reversed.toList();

      debugPrint("Filtered Business Totals (Last Month): $_businessTotals");
      debugPrint("Filtered Machine Totals (Last Month): $_machineTotals");
    });
  }



  double getDynamicInterval(double maxValue) {
    if (maxValue <= 0) return 1; // Default case for zero or negative values

    double rawInterval = (maxValue / 3).ceilToDouble(); // Ensure at most 3 intervals above 0
    double magnitude = (rawInterval / 10).floorToDouble() * 10;

    return magnitude > 0 ? magnitude : rawInterval; // Ensure minimum interval of 1
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dates.isEmpty) {
      return const Center(
          child: Text(
            "No data found.",
            style: TextStyle(color: AppTheme.textBlack),
          ));
    }

    // Determine the max value for dynamic interval
    double maxValue = [
      ..._businessTotals,
      ..._machineTotals
    ].reduce((a, b) => a > b ? a : b);

    debugPrint("MAxValue : $maxValue");

    double dynamicInterval = getDynamicInterval(maxValue);

    // // Calculate a suitable interval (rounded to nearest 10)
    // double interval = (maxValue / 4).ceilToDouble();
    // if (interval < 10) interval = 10; // Ensure minimum interval of 10 for clarity

    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
                  minY: 0, // Ensures Y-axis starts from 0
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < _dates.length) {
                            return Transform.translate(
                              offset: const Offset(0, 8),
                              child: Text(
                                _dates[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: dynamicInterval, // Dynamic interval applied here
                        reservedSize: 70,
                        getTitlesWidget: (value, meta) {
                          if (value % dynamicInterval == 0) { // Show only interval values
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10.5),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    _buildLineChartBarData(
                        _businessTotals, Colors.blue.withOpacity(1.0), "Business",
                        offset: 0.2, isDashed: true),
                    _buildLineChartBarData(
                        _machineTotals, Colors.red.withOpacity(0.5), "Machines"),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.blue.withOpacity(0.7), "Business"),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.red.withOpacity(0.7), "Machines"),
            ],
          ),
        ),
      ],
    );
  }

  LineChartBarData _buildLineChartBarData(List<double> values, Color color, String label,
      {double offset = 0, bool isDashed = false}) {
    if (values.isEmpty) {
      return LineChartBarData(spots: []);
    }

    return LineChartBarData(
      spots: values.asMap().entries.map((entry) =>
          FlSpot(entry.key.toDouble(), entry.value + offset)).toList(),
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      belowBarData: BarAreaData(show: false),
      dotData: const FlDotData(show: true),
      dashArray: isDashed ? [5, 5] : null, // Dashed effect for Business line
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

