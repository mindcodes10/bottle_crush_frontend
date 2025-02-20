import 'dart:convert';
import 'package:bottle_crush/screens/business_dashboard.dart';
import 'package:bottle_crush/screens/business_email.dart';
import 'package:bottle_crush/screens/machine_view.dart';
import 'package:flutter/material.dart';
import 'package:bottle_crush/services/api_services.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';

class BusinessView extends StatefulWidget {
  final int id;
  const BusinessView({super.key, required this.id});

  @override
  State<BusinessView> createState() => _BusinessViewState();
}

class _BusinessViewState extends State<BusinessView> {
  Future<List<dynamic>>? _businessDetails;
  final ApiServices _apiServices = ApiServices();

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
        MaterialPageRoute(builder: (context) => BusinessDashboard(id: widget.id)),
      );
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MachineView(id: widget.id)),
      );
    }
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BusinessEmail(id: widget.id)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _businessDetails = fetchBusinessDetails();
  }

  Future<List<dynamic>> fetchBusinessDetails() async {
    try {
      final response = await _apiServices.getMyBusiness();
      debugPrint('Response Received : $response');

      // Ensure 'businesses' key exists in the response
      if (response.containsKey('businesses') && response['businesses'] is List) {
        return response['businesses'] as List<dynamic>;
      } else {
        throw Exception('Invalid response format: "businesses" key missing or invalid.');
      }
    } catch (e) {
      debugPrint("Error: $e");
      throw Exception('An error occurred: $e');
    }
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: businessDetails.length,
                      itemBuilder: (context, index) {
                        var business = businessDetails[index];
                        return Card(
                          elevation: 4,
                          color: AppTheme.backgroundCard,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: (business['logo_image'] != null && business['logo_image'].isNotEmpty)
                                      ? MemoryImage(base64Decode(business['logo_image']))
                                      : const AssetImage('assets/images/leaf.png'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        business['name'] ?? 'Company Name',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        softWrap: true,
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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