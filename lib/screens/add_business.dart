import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_services.dart';
import '../widgets/custom_elevated_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // <-- Add this import for File operations

class AddBusiness extends StatefulWidget {
  const AddBusiness({super.key});

  @override
  State<AddBusiness> createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {
  int _selectedIndex = 0; // Track the selected index for bottom nav items
  bool _isPasswordVisible = false;
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessEmailController = TextEditingController();
  final TextEditingController _businessMobileController = TextEditingController();
  final TextEditingController _businessPasswordController = TextEditingController();
  final TextEditingController _logoPathController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage; // Variable to hold the selected image file

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation logic here based on the index
    print('Selected Index: $index'); // Example print statement
  }

  @override
  void dispose() {
    _logoPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: AppTheme.backgroundWhite, // Use the custom app bar widget here
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: TextFormField(
                controller: _businessNameController,
                style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AppTheme.textBlack), // Set the font size for entered text
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: TextFormField(
                controller: _businessEmailController,
                style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AppTheme.textBlack), // Set the font size for entered text
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: TextFormField(
                controller: _businessMobileController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AppTheme.textBlack), // Set the font size for entered text
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: TextFormField(
                controller: _businessPasswordController,
                obscureText: !_isPasswordVisible,
                style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AppTheme.textBlack), // Set the font size for entered text
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: TextFormField(
                controller: _logoPathController,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: AppTheme.textBlack,
                ), // Set the font size for entered text
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
                        source: ImageSource.gallery, // You can use ImageSource.camera to pick from the camera
                      );

                      if (image != null) {
                        // Image selected
                        setState(() {
                          _selectedImage = File(image.path); // Save the selected image file
                          _logoPathController.text = image.path; // Update the TextField
                        });
                        print('Selected image: ${image.path}');
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
            // Display selected image if available
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Stack(
                  children: [
                    Image.file(
                      File(_selectedImage!.path),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Remove the selected image
                          setState(() {
                            _selectedImage = null;
                            _logoPathController.clear(); // Clear the TextField
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppTheme.backgroundBlue,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4.0),
                          child: const Icon(
                            Icons.close,
                            size: 16.0,
                            color: AppTheme.backgroundWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),


            // Add the Cancel and Submit buttons at the bottom of the screen
            const Spacer(), // Push buttons to the bottom
            Padding(padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomElevatedButton(
                    buttonText: 'Cancel',
                    onPressed: () {},
                    width: screenWidth * 0.4,
                    backgroundColor: AppTheme.backgroundWhite, // White background for Cancel
                    textColor: AppTheme.backgroundBlue, // Blue text for Cancel button
                    borderColor: AppTheme.backgroundBlue, // Blue border for Cancel button
                    icon: const Icon(Icons.cancel, color: AppTheme.backgroundBlue), // Cancel icon as prefix
                  ),
                  CustomElevatedButton(
                    buttonText: 'Submit',
                    onPressed: (){},
                    // onPressed: () async {
                    //   print("Submit button clicked");
                    //
                    //   if (_businessNameController.text.isEmpty ||
                    //       _businessEmailController.text.isEmpty ||
                    //       _businessMobileController.text.isEmpty ||
                    //       _businessPasswordController.text.isEmpty ||
                    //       _selectedImage == null) {
                    //     print("Validation failed: One or more fields are empty");
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(content: Text("Please fill all fields and select an image")),
                    //     );
                    //     return;
                    //   }
                    //
                    //   print("Validation passed: All fields are filled");
                    //
                    //   final apiServices = ApiServices();
                    //   print("Calling createBusiness API...");
                    //   print("Input Details:");
                    //   print(" - Business Name: ${_businessNameController.text}");
                    //   print(" - Business Email: ${_businessEmailController.text}");
                    //   print(" - Business Mobile: ${_businessMobileController.text}");
                    //   print(" - Business Password: ${_businessPasswordController.text}");
                    //   print(" - Logo Path: ${_selectedImage?.path}");
                    //
                    //   final result = await apiServices.createBusiness(
                    //     businessName: _businessNameController.text,
                    //     businessEmail: _businessEmailController.text,
                    //     businessMobile: _businessMobileController.text,
                    //     businessPassword: _businessPasswordController.text,
                    //     logo: _selectedImage!,
                    //   );
                    //
                    //   if (result != null) {
                    //     print("API Response: $result");
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(content: Text("Business created successfully!")),
                    //     );
                    //     // Clear the form or navigate
                    //   } else {
                    //     print("API call failed. Result is null.");
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(content: Text("Failed to create business")),
                    //     );
                    //   }
                    // },
                    width: screenWidth * 0.4,
                    backgroundColor: AppTheme.backgroundBlue,
                    textColor: AppTheme.textWhite,
                    icon: const Icon(Icons.check, color: AppTheme.textWhite),
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
