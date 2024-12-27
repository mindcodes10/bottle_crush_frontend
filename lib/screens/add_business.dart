import 'package:bottle_crush/screens/dashboard.dart';
import 'package:bottle_crush/screens/email.dart';
import 'package:bottle_crush/screens/view_machines.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_services.dart';
import '../widgets/custom_elevated_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // <-- Add this import for File operations
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; // <-- Add this import for json encoding
import 'package:crypto/crypto.dart';


class AddBusiness extends StatefulWidget {
  const AddBusiness({super.key});

  @override
  State<AddBusiness> createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {
  int _selectedIndex = 1; // Track the selected index for bottom nav items
  bool _isPasswordVisible = false;
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessEmailController =
  TextEditingController();
  final TextEditingController _businessMobileController =
  TextEditingController();
  final TextEditingController _businessPasswordController =
  TextEditingController();
  final TextEditingController _logoPathController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage; // Variable to hold the selected image file
  final ApiServices apiServices =
  ApiServices(); // Create an instance of ApiServices
  final FlutterSecureStorage secureStorage =
  const FlutterSecureStorage(); // Create an instance of FlutterSecureStorage
  String? token; // Variable to hold the token

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to respective screen based on the selected index
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewMachines()),
      );
    }
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Email()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadToken(); // Load the token when the widget is initialized
  }

  // Method to load the token from secure storage
  Future<void> _loadToken() async {
    token = await secureStorage.read(key: 'access_token');
    print('Token loaded: $token'); // Print the token for debugging
  }

  @override
  void dispose() {
    _logoPathController.dispose();
    super.dispose();
  }

  // Function to hash the password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert password to bytes
    final hashedPassword = sha256.convert(bytes); // Hash the password using SHA256
    return hashedPassword.toString(); // Return the hashed password as a string
  }

  submitPressed() async {
    if (_businessNameController.text.isEmpty ||
        _businessEmailController.text.isEmpty ||
        _businessMobileController.text.isEmpty ||
        _businessPasswordController.text.isEmpty) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Hash the password before sending it
    String hashedPassword = _hashPassword(_businessPasswordController.text);

    try {
      final response = await apiServices.createBusiness(
        token: token!,
        name: _businessNameController.text,
        mobile: _businessMobileController.text,
        email: _businessEmailController.text,
       // password: hashedPassword,
        password: _businessPasswordController.text,
        logoImage: _selectedImage != null ? _selectedImage : null, // Updated line
      );

      // Handle success response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );

      // Optionally, navigate to another screen or reset the form
    } catch (e) {
      // Handle error response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: AppTheme.backgroundWhite,
      body: SingleChildScrollView(
        // Wrap the body in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0, right: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Set mainAxisSize to min
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                      fontSize: screenWidth * 0.03, color: AppTheme.textBlack),
                  decoration: InputDecoration(
                    labelText: 'Business Name',
                    labelStyle: TextStyle(fontSize: screenWidth * 0.03),
                    prefixIcon: Icon(
                      FontAwesomeIcons.briefcase,
                      size: screenWidth * 0.05,
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
                padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: TextFormField(
                  controller: _businessEmailController,
                  style: TextStyle(
                      fontSize: screenWidth * 0.03, color: AppTheme.textBlack),
                  decoration: InputDecoration(
                    labelText: 'Business Email',
                    labelStyle: TextStyle(fontSize: screenWidth * 0.03),
                    prefixIcon: Icon(
                      FontAwesomeIcons.solidEnvelope,
                      size: screenWidth * 0.05,
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
                padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: TextFormField(
                  controller: _businessMobileController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      fontSize: screenWidth * 0.03, color: AppTheme.textBlack),
                  decoration: InputDecoration(
                    labelText: 'Business Mobile',
                    labelStyle: TextStyle(fontSize: screenWidth * 0.03),
                    prefixIcon: Icon(
                      FontAwesomeIcons.phone,
                      size: screenWidth * 0.05,
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
                padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: TextFormField(
                  controller: _businessPasswordController,
                  obscureText: !_isPasswordVisible,
                  style: TextStyle(
                      fontSize: screenWidth * 0.03, color: AppTheme.textBlack),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(fontSize: screenWidth * 0.03),
                    prefixIcon: Icon(
                      FontAwesomeIcons.lock,
                      size: screenWidth * 0.05,
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
                padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                child: TextFormField(
                  controller: _logoPathController,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AppTheme.textBlack,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Logo',
                    labelStyle: TextStyle(fontSize: screenWidth * 0.03),
                    prefixIcon: Icon(
                      FontAwesomeIcons.solidFileImage,
                      size: screenWidth * 0.05,
                      color: AppTheme.backgroundBlue,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        FontAwesomeIcons.cloudArrowUp,
                        size: screenWidth * 0.06,
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
                        print('Selected image: ${image.path}');
                        } else {
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
                              _selectedImage = null;
                              _logoPathController.clear();
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomElevatedButton(
                      buttonText: 'Cancel',
                      onPressed: () {},
                      width: screenWidth * 0.4,
                      backgroundColor: AppTheme.backgroundWhite,
                      textColor: AppTheme.backgroundBlue,
                      borderColor: AppTheme.backgroundBlue,
                      icon: const Icon(Icons.cancel,
                          color: AppTheme.backgroundBlue),
                    ),
                    CustomElevatedButton(
                      buttonText: 'Submit',
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
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped, selectedIndex: _selectedIndex,
      ),
    );
  }
}