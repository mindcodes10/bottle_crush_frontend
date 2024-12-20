import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/custom_elevated_button.dart';
import 'package:image_picker/image_picker.dart';

class AddBusiness extends StatefulWidget {
  const AddBusiness({super.key});

  @override
  State<AddBusiness> createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {
  int _selectedIndex = 0; // Track the selected index for bottom nav items
  bool _isPasswordVisible = false;
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessEmailController =
      TextEditingController();
  final TextEditingController _businessMobileController =
      TextEditingController();
  final TextEditingController _businessPasswordController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation logic here based on the index
    print('Selected Index: $index'); // Example print statement
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor:
          AppTheme.backgroundWhite, // Use the custom app bar widget here
      body: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 8.0, right: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0), // Adjust padding as needed
              child: Text(
                'Add New Business',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: screenWidth * 0.04,
                ),
              ),
            ),
            // 1
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: TextFormField(
                controller: _businessNameController,
                style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AppTheme
                        .textBlack), // Set the font size for entered text
                decoration: InputDecoration(
                  labelText: 'Business Name',
                  labelStyle: TextStyle(fontSize: screenWidth * 0.03),
                  prefixIcon: Icon(
                    FontAwesomeIcons.briefcase,
                    size: screenWidth * 0.05,
                    color: AppTheme.backgroundBlue,
                  ), // FontAwesome icon
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            //2
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: TextFormField(
                controller: _businessEmailController,
                style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AppTheme
                        .textBlack), // Set the font size for entered text
                decoration: InputDecoration(
                  labelText: 'Business Email',
                  labelStyle: TextStyle(fontSize: screenWidth * 0.03),
                  prefixIcon: Icon(
                    FontAwesomeIcons.solidEnvelope,
                    size: screenWidth * 0.05,
                    color: AppTheme.backgroundBlue,
                  ), // FontAwesome icon
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            //3
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: TextFormField(
                controller: _businessMobileController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AppTheme
                        .textBlack), // Set the font size for entered text
                decoration: InputDecoration(
                  labelText: 'Business Mobile',
                  labelStyle: TextStyle(fontSize: screenWidth * 0.03),
                  prefixIcon: Icon(
                    FontAwesomeIcons.phone,
                    size: screenWidth * 0.05,
                    color: AppTheme.backgroundBlue,
                  ), // FontAwesome icon
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            //4
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: TextFormField(
                controller: _businessPasswordController,
                obscureText: !_isPasswordVisible,
                style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AppTheme
                        .textBlack), // Set the font size for entered text
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(fontSize: screenWidth * 0.03),
                  prefixIcon: Icon(
                    FontAwesomeIcons.lock,
                    size: screenWidth * 0.05,
                    color: AppTheme.backgroundBlue,
                  ), // FontAwesome icon
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppTheme.backgroundBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            //5
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: TextFormField(
                //controller: _businessMobileController,
                style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AppTheme
                        .textBlack), // Set the font size for entered text
                decoration: InputDecoration(
                  labelText: 'Logo',
                  labelStyle: TextStyle(fontSize: screenWidth * 0.03),
                  prefixIcon: Icon(
                    FontAwesomeIcons.solidFileImage,
                    size: screenWidth * 0.05,
                    color: AppTheme.backgroundBlue,
                  ), // FontAwesome icon
                  suffixIcon: IconButton(
                    icon: Icon(
                      FontAwesomeIcons.cloudArrowUp,
                      size: screenWidth * 0.06,
                      color: AppTheme.backgroundBlue,
                    ),
                    onPressed: () async {
                      // Open image picker on click
                      final XFile? image = await _picker.pickImage(
                        source: ImageSource
                            .gallery, // You can use ImageSource.camera to pick from the camera
                      );

                      if (image != null) {
                        // Image selected
                        print('Selected image: ${image.path}');
                        // Handle the image here (e.g., display it, upload it, etc.)
                      } else {
                        // User canceled the picker
                        print('Image selection canceled.');
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),

            // Add the Cancel and Submit buttons at the bottom of the screen
            const Spacer(), // Push buttons to the bottom
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomElevatedButton(
                    buttonText: 'Cancel',
                    onPressed: () {},
                    width: screenWidth * 0.4,
                    backgroundColor:
                        AppTheme.backgroundWhite, // White background for Cancel
                    textColor:
                        AppTheme.backgroundBlue, // Blue text for Cancel button
                    borderColor: AppTheme
                        .backgroundBlue, // Blue border for Cancel button
                    icon: const Icon(Icons.cancel,
                        color:
                            AppTheme.backgroundBlue), // Cancel icon as prefix
                  ),
                  CustomElevatedButton(
                    buttonText: 'Submit',
                    onPressed: () {},
                    width: screenWidth * 0.4,
                    backgroundColor:
                        AppTheme.backgroundBlue, // Blue background for Submit
                    textColor:
                        AppTheme.textWhite, // White text for Submit button
                    icon: const Icon(Icons.check,
                        color: AppTheme.textWhite), // Check icon as prefix
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped, // Pass the callback
      ),
    );
  }
}
