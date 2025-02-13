import 'package:bottle_crush/screens/add_machines.dart';
import 'package:bottle_crush/screens/dashboard.dart';
import 'package:bottle_crush/screens/email.dart';
import 'package:bottle_crush/screens/view_business.dart';
import 'package:flutter/material.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_elevated_button.dart';
import 'package:bottle_crush/services/api_services.dart';

class ViewMachines extends StatefulWidget {
  const ViewMachines({super.key});

  @override
  State<ViewMachines> createState() => _ViewMachinesState();
}

class _ViewMachinesState extends State<ViewMachines> {
  final ApiServices apiService = ApiServices();
  int _selectedIndex = 2;
  List<dynamic> machineDetails = [];
  bool isLoading = true;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchMachines();
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

  // Delete machine function
  Future<void> deleteMachine(int machineId) async {
    bool success = await apiService.deleteMachine(machineId);
    if (success) {
      // If the deletion is successful, refresh the machine list
      fetchMachines();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Machine deleted successfully!'),),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete machine!'),),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to respective screen based on the selected index
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()), // Home or Dashboard screen
      );
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ViewBusiness()), // Home or Dashboard screen
      );
    }
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Email()), // Home or Dashboard screen
      );
    }
  }

  void _showDeleteConfirmationDialog(int machineId) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark? cardDark : backgroundCard,
          title: const Text(
            'Are you sure you want to delete this machine?\n\n This action cannot be undone',
            style: TextStyle(fontSize: 13),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          content: const SizedBox(
            height: 25,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomElevatedButton(
                  buttonText: 'Cancel',
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 100));

                    Navigator.of(context).pop();
                  },
                  backgroundColor: isDark ? backgroundBlue : backgroundWhite,
                  textColor: isDark ? backgroundWhite : backgroundBlue,
                  borderColor: isDark ? transparent : backgroundBlue,
                  width: 120,
                  height: 38,
                  icon: Icon(
                    Icons.cancel,
                    color: isDark? backgroundWhite : backgroundBlue,
                  ),
                ),
                const SizedBox(width: 16),
                CustomElevatedButton(
                  buttonText: 'Delete',
                  onPressed: () async {
                    // Call deleteMachine function when "Delete" is pressed
                    await deleteMachine(machineId);
                    Navigator.of(context).pop(); // Close the dialog after deletion
                  },
                  backgroundColor: isDark ? backgroundBlue : backgroundBlue,
                  textColor: Colors.white,
                  width: 120,
                  height: 38,
                  icon: Icon(
                    Icons.delete,
                    color: isDark ? textWhite : textWhite,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: CustomBottomAppBar(onItemTapped: _onItemTapped, selectedIndex: _selectedIndex),
      backgroundColor: isDark ? textBlack : backgroundWhite,
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
                    color: isDark ? cardDark : backgroundCard,
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark ? textWhite : textBlack,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Company Name: ${machine['business_name']}',
                                  style: TextStyle(fontSize: 12, color: isDark ? textWhite : textBlack,),
                                ),
                                Text(
                                  'Machine Number: ${machine['number']}',
                                  style: TextStyle(fontSize: 12, color: isDark ? textWhite : textBlack,),
                                ),
                                Text(
                                  'Location: $location',
                                  style: TextStyle(fontSize: 12, color: isDark ? textWhite : textBlack,),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 85,
                            color: Colors.grey,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.solidPenToSquare,
                                  color: isDark ? textWhite : backgroundBlue,
                                ),
                                onPressed: () async {
                                  // Navigate to the AddMachines page and wait for the result
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddMachines(machine: machine),
                                    ),
                                  );

                                  // Check if the result indicates a successful update
                                  if (result == true) {
                                    fetchMachines(); // Refresh the machine list
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.solidTrashCan,
                                  color: isDark ? textWhite : backgroundBlue,
                                ),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(machine['id']);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Button at the bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomElevatedButton(
              buttonText: 'ADD MACHINE',
              onPressed: () async {
                // Wait for the result from AddMachines
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddMachines()),
                );

                // If the result is true, refresh the machine list
                if (result == true) {
                  fetchMachines(); // Refresh the machine list
                }
              },
              icon: Icon(
                Icons.add,
                color: isDark ? backgroundWhite : backgroundWhite,
              ),
              width: double.infinity,
              height: 50,
              backgroundColor: isDark ? backgroundBlue : backgroundBlue,
            ),
          ),
        ],
      ),
    );
  }
}
