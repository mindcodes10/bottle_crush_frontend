import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
  late Future<List<dynamic>> _businessDetails; // Future to hold business details
  final ApiServices _apiServices = ApiServices(); // Create an instance of ApiServices
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Create an instance of FlutterSecureStorage

  int _selectedIndex = 0; // Track the selected index for bottom nav items

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation logic here based on the index
    print('Selected Index: $index'); // Example print statement
  }

  @override
  void initState() {
    super.initState();
    _fetchTokenAndBusinessDetails(); // Fetch token and business details
  }

  Future<void> _fetchTokenAndBusinessDetails() async {
    String? token = await _secureStorage.read(key: 'access_token'); // Retrieve the token
    if (token != null) {
      setState(() {
        _businessDetails = _apiServices.fetchBusinessDetails(token); // Use the API service to load business details
      });
    } else {
      // Handle the case where the token is not found (e.g., navigate to login)
      print('No token found. Please log in.');
      // Optionally navigate to login screen or show a message
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height for responsive font size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const CustomAppBar(), // Use the custom app bar widget here
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped, // Pass the callback
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _businessDetails, // The Future that loads the business details
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while waiting for data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if there is an error
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Display the business details if data is available
            List<dynamic> businessDetails = snapshot.data!;

            return Container(
              width: double.infinity,
              height: screenHeight,
              color: AppTheme.backgroundWhite,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04, // Responsive font size
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Use Expanded to ensure business details take full height
                  Expanded(
                    child: ListView.builder(
                      itemCount: businessDetails.length,
                      itemBuilder: (context, index) {
                        var business = businessDetails[index];
                        // Add print statements to debug the email and mobile values
                        print('Business Email: ${business['email']}');
                        print('Business Mobile: ${business['mobile']}');
                        return Card(
                          elevation: 4,
                          color: AppTheme .backgroundWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: Row(
                              children: [
                                // Left part ( Content section)
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
                                                : const AssetImage('assets/images/leaf.png'), // Fallback image
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              business['name'] ?? 'Business Name',
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
                                        business['email'] ?? 'business@email.com',
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
                                        // Handle Edit action here
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        FontAwesomeIcons.solidTrashCan,
                                        color: AppTheme.backgroundBlue,
                                      ),
                                      onPressed: () {
                                        // Handle Delete action here
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  CustomElevatedButton(
                    buttonText: ' + ADD BUSINESS',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddBusiness()),
                      );
                    },
                    width: double.infinity,
                    height: 50,
                    backgroundColor: AppTheme.backgroundBlue,
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No business details available.'));
          }
        },
      ),
    );
  }
}