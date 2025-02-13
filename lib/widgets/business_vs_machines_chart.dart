import 'package:bottle_crush/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import '../services/api_services.dart';

class BusinessVsMachinesChart extends StatefulWidget {
  const BusinessVsMachinesChart({super.key, });

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

    data.forEach((date, businesses) {
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
      DateTime parsedDate = DateTime.parse(date);
      String formattedDate = "${parsedDate.day}/${parsedDate.month}";

      dates.add(formattedDate);
      businessTotals.add(totalBusinessBottles);
      machineTotals.add(totalMachineBottles);
    });

    setState(() {
      _dates = dates;
      _businessTotals = businessTotals;
      _machineTotals = machineTotals;
      debugPrint("Business Totals: $_businessTotals");
      debugPrint("Machine Totals: $_machineTotals");
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dates.isEmpty) {
      return Center(child: Text("No data found.", style: TextStyle(color: isDark? textWhite : textBlack),));
    }

    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
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
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    _buildLineChartBarData(
                        _businessTotals, Colors.blue.withOpacity(0.7), "Business",
                        offset: 0.2, isDashed: true),
                    _buildLineChartBarData(
                        _machineTotals, Colors.red.withOpacity(0.7), "Machines"),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Legend for the chart
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
