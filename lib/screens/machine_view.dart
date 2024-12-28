import 'package:bottle_crush/screens/business_dashboard.dart';
import 'package:bottle_crush/screens/business_email.dart';
import 'package:bottle_crush/screens/business_view.dart';
import 'package:flutter/material.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/services/api_services.dart';

class MachineView extends StatefulWidget {
  final int id;
  const MachineView({super.key, required this.id});

  @override
  State<MachineView> createState() => _MachineViewState();
}

class _MachineViewState extends State<MachineView> {
  final ApiServices apiService = ApiServices();
  int _selectedIndex = 2;
  List<dynamic> machineDetails = [];
  bool isLoading = true;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchMachines(); // Fetch machine details when the widget is initialized
  }

  // Fetch machine details
  Future<void> fetchMachines() async {
    String? token = await _secureStorage.read(key: 'access_token');

    try {
      List<dynamic> machines = await apiService.fetchMachineDetails(token!);

      setState(() {
        machineDetails = machines;
        isLoading = false; // Set loading to false once data is fetched
      });
    } catch (e) {
      debugPrint('Error loading machine details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to respective screen based on the selected index
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BusinessDashboard(id: widget.id,)), // Home or Dashboard screen
      );
    }
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BusinessView(id: widget.id,)), // Home or Dashboard screen
      );
    }
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BusinessEmail(id: widget.id)), // Home or Dashboard screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: CustomBottomAppBar(onItemTapped: _onItemTapped, selectedIndex: _selectedIndex),
      backgroundColor: AppTheme.backgroundWhite,
      body: Column(
        children: [
          // Machine List Section
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) // Show loading indicator
                : ListView.builder(
              itemCount: machineDetails.length,
              itemBuilder: (context, index) {
                final machine = machineDetails[index];

                // Concatenate address details
                String location = '${machine['street']}, ${machine['city']}, ${machine['state']} - ${machine['pin_code']}';

                return Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 14.0, right: 12.0, bottom: 10.0),
                  child: Card(
                    elevation: 4,
                    color: AppTheme.backgroundWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  machine['name'] ?? 'Machine Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Company Name: ${machine['business_name']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Machine Number: ${machine['number']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Location: $location',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
