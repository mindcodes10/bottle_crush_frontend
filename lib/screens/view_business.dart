import 'dart:convert';
import 'package:bottle_crush/screens/email.dart';
import 'package:flutter/material.dart';
import 'package:bottle_crush/screens/dashboard.dart';
import 'package:bottle_crush/screens/view_machines.dart';
import 'package:bottle_crush/screens/add_business.dart';
import 'package:bottle_crush/services/api_services.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_elevated_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewBusiness extends StatefulWidget {
  const ViewBusiness({super.key});

  @override
  State<ViewBusiness> createState() => _ViewBusinessState();
}

class _ViewBusinessState extends State<ViewBusiness> {
  Future<List<dynamic>>? _businessDetails;
  final ApiServices _apiServices = ApiServices();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();


  int _selectedIndex = 1;

  // Callback for bottom nav item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to respective screen based on the selected index
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ViewMachines()),
      );
    }
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Email()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTokenAndBusinessDetails();
  }

  Future<void> _fetchTokenAndBusinessDetails() async {
    String? token = await _secureStorage.read(key: 'access_token');
    if (token != null) {
      setState(() {
        _businessDetails = _apiServices.fetchBusinessDetails(token);
      });
    } else {
      debugPrint('No token found. Please log in.');
      setState(() {
        _businessDetails = Future.value([]); // Initialize to an empty list
      });
    }
  }

  void _showBusinessDetailsPopup(String businessId) async {
    String? token = await _secureStorage.read(key: 'access_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated.')),
      );
      return;
    }

    // Fetch business stats using the API
    final businessStats = await ApiServices.getBusinessStats(businessId, token);

    debugPrint('Response of getBusinessStats : $businessStats');

    if (businessStats != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppTheme.backgroundWhite,
            title: Text(
              'Company Name: ${businessStats['business_name']?.toString() ?? 'N/A'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: null, // Allows unlimited lines
              overflow: TextOverflow.visible, // Text wraps to the next line
            ),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Machine Count: ${businessStats['total_machines']?.toString() ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Bottle Count: ${businessStats['total_bottle_count']?.toString() ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Bottle Weight: ${businessStats['total_bottle_weight']?.toStringAsFixed(1) ?? 'N/A'} kg',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              CustomElevatedButton(
                buttonText: 'Close',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                backgroundColor: AppTheme.backgroundBlue,
                textColor: Colors.white,
                width: 100,
                height: 40,
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business not found.')),
      );
    }
  }





  // Function to show confirmation dialog before deletion
  void _showDeleteConfirmationDialog(int businessId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundWhite,
          title: const Text(
            'Are you sure you want to delete this company?\n\n This action cannot be undone',
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  backgroundColor: AppTheme.backgroundWhite,
                  textColor: AppTheme.backgroundBlue,
                  borderColor: AppTheme.backgroundBlue,
                  width: 120,
                  height: 38,
                  icon: const Icon(
                    Icons.cancel,
                    color: AppTheme.backgroundBlue,
                  ),
                ),
                const SizedBox(width: 16),
                CustomElevatedButton(
                  buttonText: 'Delete',
                  onPressed: () async {
                    // Call the API to delete the business
                    bool isDeleted = await _apiServices.deleteBusiness(businessId);
                    if (isDeleted) {
                      // Refresh the business details after deletion

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Company deleted successfully'),),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete company'), ),
                      );
                    }
                    Navigator.of(context).pop();
                    _fetchTokenAndBusinessDetails();
                  },
                  backgroundColor: AppTheme.backgroundBlue,
                  textColor: Colors.white,
                  width: 120,
                  height: 38,
                  icon: const Icon(
                    Icons.delete,
                    color: AppTheme.textWhite,
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;


    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
      backgroundColor: AppTheme.backgroundWhite,
      body: FutureBuilder<List<dynamic>>(
        future: _businessDetails,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint('Error: ${snapshot.error}');
            return const Center(child: Text('No company details available'));
          } else if (snapshot.hasData) {
            List<dynamic> businessDetails = snapshot.data!;
            if (businessDetails.isEmpty) {
              return const Center(child: Text('No company details available.'));
            }

            return Container(
              width: double.infinity,
              height: screenHeight,
              color: AppTheme.backgroundWhite,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Inside the ListView.builder in ViewBusiness
                  Expanded(
                    child: ListView.builder(
                      itemCount: businessDetails.length,
                      itemBuilder: (context, index) {
                        var business = businessDetails[index];
                        return GestureDetector(
                          onTap: () {
                            _showBusinessDetailsPopup(business['id'].toString()); // Pass the 'id' as a string (or use it as a string directly)
                          },
                          child: Card(
                            elevation: 4,
                            color: AppTheme.backgroundCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 25,
                                              backgroundColor: Colors.grey[300],
                                              backgroundImage: business['logo_image'] != null && business['logo_image'].isNotEmpty
                                                  ? MemoryImage(base64Decode(business['logo_image']))
                                                  : null, // Set to null to use the child widget instead
                                              child: business['logo_image'] == null || business['logo_image'].isEmpty
                                                  ? const Icon(
                                                FontAwesomeIcons.briefcase,
                                                size: 25, // Adjust size as needed
                                                color: AppTheme.backgroundBlue, // Set the color of the icon
                                              )
                                                  : null, // No child if logo_image is available
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                business['name'] ?? 'Company Name',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          business['owner_email'] ?? 'company@email.com',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          business['mobile'] ?? '+1 234 567 890',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      height: 100,
                                      width: 0.3,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          FontAwesomeIcons.solidPenToSquare,
                                          color: AppTheme.backgroundBlue,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddBusiness(business: business),
                                            ),
                                          ).then((result) {
                                            if (result == true) {
                                              _fetchTokenAndBusinessDetails(); // Refresh the business details
                                            }
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          FontAwesomeIcons.solidTrashCan,
                                          color: AppTheme.backgroundBlue,
                                        ),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(business['id']);
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

                  CustomElevatedButton(
                    buttonText: ' + ADD COMPANY',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddBusiness()),
                      ).then((result) {
                        if (result == true) {
                          _fetchTokenAndBusinessDetails(); // Refresh the business details
                        }
                      });
                    },
                    width: double.infinity,
                    height: 50,
                    backgroundColor: AppTheme.backgroundBlue,
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No company details available.'));
          }
        },
      ),
    );
  }
}
