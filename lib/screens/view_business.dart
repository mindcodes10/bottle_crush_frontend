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
  Future<List<dynamic>>? _businessDetails; // Change to nullable Future
  final ApiServices _apiServices = ApiServices();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print('Selected Index: $index');
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
      // Handle the case where the token is not found
      print('No token found. Please log in.');
      setState(() {
        _businessDetails = Future.value([]); // Initialize to an empty list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(),
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _businessDetails,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<dynamic> businessDetails = snapshot.data!;
            if (businessDetails.isEmpty) {
              return const Center(child: Text('No business details available.'));
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
                    'Business Details',
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
                          color: AppTheme.backgroundWhite,
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
                                            backgroundImage: business['logo_image'] != null &&
                                                business['logo_image'].isNotEmpty
                                                ? MemoryImage(base64Decode(business['logo_image']))
                                                : const AssetImage('assets/images/leaf.png'),
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
                                        business['owner_email'] ?? 'business@email.com',
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
