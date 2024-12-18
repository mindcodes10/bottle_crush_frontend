import 'dart:convert';
import 'package:bottle_crush/screens/add_business.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewBusiness extends StatefulWidget {
  const ViewBusiness({super.key});

  @override
  State<ViewBusiness> createState() => _ViewBusinessState();
}

class _ViewBusinessState extends State<ViewBusiness> {
  late Future<List<dynamic>> _businessDetails; // Future to hold business details

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
    _businessDetails = _loadBusinessDetails(); // Initialize the Future
  }

  // Method to load JSON from assets
  Future<List<dynamic>> _loadBusinessDetails() async {
    final String jsonString = await rootBundle.loadString('assets/json/business_details.json');
    final Map<String, dynamic> jsonResponse = json.decode(jsonString);

    // Print the business details for debugging
    print("Business Details: ${jsonResponse['business_details']}");

    return jsonResponse['business_details']; // Return the list of businesses
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
            return Center(child: CircularProgressIndicator());
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
                        return Card(
                          elevation: 4,
                          color: AppTheme.backgroundWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: Row(
                              children: [
                                // Left part (Content section)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // Replace CircleAvatar with Image.network to load profile photo
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundColor: Colors.grey[300],
                                            backgroundImage: business['profile_photo'] != null && business['profile_photo'].isNotEmpty
                                                ? NetworkImage(business['profile_photo'])
                                                : AssetImage('assets/images/leaf.png'), // Fallback image
                                          ),

                                          const SizedBox(width: 16),

                                          // The business name text with multiple lines if necessary
                                          Expanded(
                                            child: Text(
                                              business['business_name'] ?? 'Business Name',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2, // Allow the business name to span two lines
                                              softWrap: true, // Ensure text wraps when necessary
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        business['business_email'] ?? 'business@email.com',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          //color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        business['mobile_number'] ?? '+1 234 567 890',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          //color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Fixed-width vertical line
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Container(
                                    height: 100,
                                    width: 0.3,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Right part (Icons section)
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
                  // The "Add Business" button should stay at the bottom
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
            // If no data is available
            return const Center(child: Text('No business details available.'));
          }
        },
      ),
    );
  }
}
