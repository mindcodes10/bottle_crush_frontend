import 'dart:convert'; // Import this for base64Decode
import 'dart:typed_data'; // Import this for Uint8List
import 'package:bottle_crush/screens/dashboard.dart';
import 'package:bottle_crush/screens/email.dart';
import 'package:bottle_crush/screens/view_business.dart';
import 'package:bottle_crush/screens/view_machines.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_services.dart';
import '../widgets/custom_elevated_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddBusiness extends StatefulWidget {
  final dynamic business;

  const AddBusiness({super.key, this.business});

  @override
  State<AddBusiness> createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {
  int _selectedIndex = 1; // Track the selected index for bottom nav items
  bool _isPasswordVisible = false;
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessEmailController = TextEditingController();
  final TextEditingController _businessMobileController = TextEditingController();
  final TextEditingController _businessPasswordController = TextEditingController();
  final TextEditingController _logoPathController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage; // Variable to hold the selected image file
  final ApiServices apiServices = ApiServices(); // Create an instance of ApiServices
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage(); // Create an instance of FlutterSecureStorage
  String? token; // Variable to hold the token
  final bool _isEditable = false; // Add this variable to track if fields are editable or not

  Uint8List? _logoImageBytes; // Variable to hold the logo image bytes

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
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ViewBusiness()),
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
    _loadToken(); // Load the token when the widget is initialized
    if (widget.business != null) {
      // Populate fields if editing
      _businessNameController.text = widget.business['name'] ?? '';
      _businessEmailController.text = widget.business['owner_email'] ?? '';
      _businessMobileController.text = widget.business['mobile'] ?? '';

      // Decode the logo image if it exists
      if (widget.business['logo_image'] != null) {
        _logoImageBytes = base64Decode(widget.business['logo_image']);
      }
    }
  }

  // Method to load the token from secure storage
  Future<void> _loadToken() async {
    token = await secureStorage.read(key: 'access_token');
    debugPrint('Token loaded: $token'); // Print the token for debugging
  }

  @override
  void dispose() {
    super.dispose();
  }

  submitPressed() async {
    try {
      if (widget.business == null) {
        // New business creation logic
        if (_businessNameController.text.isEmpty ||
            _businessEmailController.text.isEmpty ||
            _businessMobileController.text.isEmpty ||
            _businessPasswordController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill all fields')),
          );
          return;
        }
        final response = await apiServices.createBusiness(
          token: token!,
          name: _businessNameController.text,
          mobile: _businessMobileController.text,
          email: _businessEmailController.text,
          password: _businessPasswordController.text,
          logoImage: _selectedImage != null ? _selectedImage : null,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      } else {
        // Business update logic
        final response = await apiServices.updateBusiness(
          token!,
          widget.business['id'],
          _businessNameController.text,
          _businessMobileController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
      // Pop the current screen and return true to indicate success
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update company details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isTablet = screenWidth > 600;

    double fontSize = isTablet ? 20 : 14;
    double iconSize = isTablet ? 30 : 24;
    double fieldHeight = isTablet ? 70 : 50;

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: AppTheme.backgroundWhite,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                const EdgeInsets.only(left: 12.0, top: 8.0, right: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.business == null
                            ? 'Add Company'
                            : 'Update Company',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: fontSize,
                        ),
                      ),
                    ),
                    // 1
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 6.0),
                      child: TextFormField(
                        controller: _businessNameController,
                        enabled: widget.business == null
                            ? !_isEditable
                            : !_isEditable,
                        style: TextStyle(
                            fontSize: fontSize,
                            color: AppTheme.textBlack),
                        decoration: InputDecoration(
                          labelText: 'Company Name',
                          labelStyle: TextStyle(
                            fontSize: fontSize,
                          ),
                          prefixIcon: Icon(
                            FontAwesomeIcons.briefcase,
                            size: iconSize,
                            color: AppTheme.backgroundBlue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    // 2
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 6.0),
                      child: TextFormField(
                        controller: _businessEmailController,
                        enabled: widget.business == null
                            ? !_isEditable
                            : !_isEditable,
                        style: TextStyle(
                            fontSize: fontSize,
                            color: AppTheme.textBlack),
                        decoration: InputDecoration(
                          labelText: 'Company Email',
                          labelStyle: TextStyle(
                            fontSize: fontSize,
                          ),
                          prefixIcon: Icon(
                            FontAwesomeIcons.solidEnvelope,
                            size: iconSize,
                            color: AppTheme.backgroundBlue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    // 3
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 6.0),
                      child: TextFormField(
                        controller: _businessMobileController,
                        enabled: widget.business == null
                            ? !_isEditable
                            : !_isEditable,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            fontSize: fontSize,
                            color: AppTheme.textBlack),
                        decoration: InputDecoration(
                          labelText: 'Company Mobile',
                          labelStyle : TextStyle(fontSize: fontSize),
                          prefixIcon: Icon(
                            FontAwesomeIcons.phone,
                            size: iconSize,
                            color: AppTheme.backgroundBlue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    // 4
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 6.0),
                      child: TextFormField(
                        controller: _businessPasswordController,
                        enabled: widget.business == null
                            ? !_isEditable
                            : !_isEditable,
                        obscureText: !_isPasswordVisible,
                        style: TextStyle(
                            fontSize: fontSize,
                            color: AppTheme.textBlack),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle:
                          TextStyle(fontSize: fontSize),
                          prefixIcon: Icon(
                            FontAwesomeIcons.lock,
                            size: iconSize,
                            color: AppTheme.backgroundBlue,
                          ),
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
                    // 5
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 6.0),
                      child: TextFormField(
                        controller: _logoPathController,
                        enabled: true, // Disable editing for the logo path
                        style: TextStyle(
                          fontSize: fontSize,
                          color: AppTheme.textBlack,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Logo',
                          labelStyle:
                          TextStyle(fontSize: fontSize),
                          prefixIcon: Icon(
                            FontAwesomeIcons.solidFileImage,
                            size: iconSize,
                            color: AppTheme.backgroundBlue,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.cloudArrowUp,
                              size: iconSize,
                              color: AppTheme.backgroundBlue,
                            ),
                            onPressed: () async {
                              final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );

                              if (image != null) {
                                setState(() {
                                  _selectedImage = File(image.path);
                                  _logoPathController.text = image.path;
                                });
                                debugPrint('Selected image: ${image.path}');
                              } else {
                                debugPrint('Image selection canceled.');
                              }
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    // Display the logo image if available
                    if (_logoImageBytes != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 12.0),
                        child: Stack(
                          children: [
                            Image.memory(
                              _logoImageBytes!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _logoImageBytes = null; // Clear the logo image
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
                    // Display selected image if available
                    if (_selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 12.0),
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
                                  setState(() {
                                    _selectedImage = null; // Clear the selected image
                                    _logoPathController.clear(); // Clear the logo path
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
                    // Remove Spacer and use SizedBox for spacing
                    SizedBox(height: screenHeight * 0.12),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomElevatedButton(
                  buttonText: 'Cancel',
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const ViewBusiness()));
                  },
                  width: screenWidth * 0.4,
                  backgroundColor: AppTheme.backgroundWhite,
                  textColor: AppTheme.backgroundBlue,
                  borderColor: AppTheme.backgroundBlue,
                  icon: const Icon(Icons.cancel, color: AppTheme.backgroundBlue),
                ),
                CustomElevatedButton(
                  buttonText: widget.business == null ? 'Add ' : 'Update ',
                  onPressed: submitPressed,
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
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}