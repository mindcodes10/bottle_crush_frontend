import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_services.dart'; // Import ApiServices class
import '../utils/theme.dart';

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({super.key});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  late Future<Map<String, int>> stateMachineDataFuture;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? token;

  /// Mapping full state names to their abbreviations
  final Map<String, String> stateAbbreviations = {
    "Andhra Pradesh": "AP",
    "Arunachal Pradesh": "AR",
    "Assam": "AS",
    "Bihar": "BR",
    "Chhattisgarh": "CG",
    "Goa": "GA",
    "Gujarat": "GJ",
    "Haryana": "HR",
    "Himachal Pradesh": "HP",
    "Jharkhand": "JH",
    "Karnataka": "KA",
    "Kerala": "KL",
    "Madhya Pradesh": "MP",
    "Maharashtra": "MH",
    "Manipur": "MN",
    "Meghalaya": "ML",
    "Mizoram": "MZ",
    "Nagaland": "NL",
    "Odisha": "OR",
    "Punjab": "PB",
    "Rajasthan": "RJ",
    "Sikkim": "SK",
    "Tamil Nadu": "TN",
    "Telangana": "TG",
    "Tripura": "TR",
    "Uttar Pradesh": "UP",
    "Uttarakhand": "UK",
    "West Bengal": "WB",

    /// Union Territories
    "Andaman and Nicobar Islands": "AN",
    "Chandigarh": "CH",
    "Dadra and Nagar Haveli and Daman and Diu": "DN",
    "Lakshadweep": "LD",
    "Delhi": "DL",
    "Puducherry": "PY",
    "Jammu and Kashmir": "JK",
    "Ladakh": "LA"
  };


  @override
  void initState() {
    super.initState();
    stateMachineDataFuture = _fetchStateWiseMachineCount();
  }

  Future<Map<String, int>> _fetchStateWiseMachineCount() async {
    try {
      ApiServices apiServices = ApiServices();
      token = await _secureStorage.read(key: 'access_token');
      List<dynamic> machines = await apiServices.fetchMachineDetails(token!);

      Map<String, int> stateMachineCount = {};

      for (var machine in machines) {
        String state = machine["state"] ?? "Unknown"; /// Get state name
        String shortState = stateAbbreviations[state] ?? state; /// Convert to abbreviation if available
        stateMachineCount[shortState] = (stateMachineCount[shortState] ?? 0) + 1;
      }

      return stateMachineCount;
    } catch (e) {
      debugPrint("Error fetching machine data: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        const Text(
          "State-wise Machine Count",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textBlack),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 240,
          child: FutureBuilder<Map<String, int>>(
            future: stateMachineDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data!.isEmpty) {
                return const Center(child: Text("No data available", style: TextStyle(color: AppTheme.textBlack),));
              } else {
                return PieChart(
                  PieChartData(
                    sections: _getSections(snapshot.data!),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 70,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getSections(Map<String, int> stateMachineData) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> colors = [
      const Color(0xFF0B499E), /// Original primary color
      const Color(0xFF2D5FAA), /// Slightly lighter
      const Color(0xFF4D75B6), /// Medium shade
      const Color(0xFF6D8CC2), /// Lighter shade
      const Color(0xFF8DA3CC), /// Lightest shade
    ];

    int index = 0;
    return stateMachineData.entries.map((entry) {
      final sectionColor = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: sectionColor,
        value: entry.value.toDouble(),
        title: "${entry.key}\n(${entry.value})",
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppTheme.textWhite,
        ),
      );
    }).toList();
  }
}

