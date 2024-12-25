import 'package:bottle_crush/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_elevated_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddMachines extends StatefulWidget {
  final dynamic machine;
  const AddMachines({super.key,this.machine});

  @override
  State<AddMachines> createState() => _AddMachinesState();
}

class _AddMachinesState extends State<AddMachines> {
  int _selectedIndex = 0;
  final TextEditingController _machineNameController = TextEditingController();
  final TextEditingController _machineNumberController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  String? _selectedState;

  final ApiServices apiServices = ApiServices();
  final List<String> _businessNames = []; // List to store business names
  String? _selectedBusinessName;

  final List<String> _states = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi",
    "Lakshadweep",
    "Puducherry",
    "Jammu and Kashmir",
    "Ladakh"
  ];

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(); // Secure Storage instance

  @override
  void initState() {
    super.initState();
    _fetchBusinessNames(); // Fetch business names when the widget is first initialized
    if (widget.machine != null) {
      // Populate fields if editing
      _machineNameController.text = widget.machine['name'];
      _machineNumberController.text = widget.machine['number'];
      _businessNameController.text = widget.machine['business_name'];
      _streetController.text = widget.machine['street'];
      _cityController.text = widget.machine['city'];
      _pincodeController.text = widget.machine['pin_code'];
      _selectedState = widget.machine['state'];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fetch business names from API and populate the list
  Future<void> _fetchBusinessNames() async {
    try {
      final String? token = await _secureStorage.read(key: "access_token");
      if (token != null) {
        List<dynamic> businesses =
            await apiServices.fetchBusinessDetails(token);

        setState(() {
          _businessNames.clear();
          for (var business in businesses) {
            _businessNames.add(business['name']);
          }

          // Optionally set the first business name as the default selection
          if (_businessNames.isNotEmpty) {
            _selectedBusinessName = _businessNames[0];
            _businessNameController.text = _selectedBusinessName!;
          }
        });
      }
    } catch (e) {
      print('Error fetching business names: $e');
    }
  }

  void _submitPressed() async {
    // Validate form fields
    if (_machineNameController.text.isEmpty ||
        _machineNumberController.text.isEmpty ||
        _businessNameController.text.isEmpty ||
        _streetController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _pincodeController.text.isEmpty ||
        _selectedState == null ||
        _selectedState!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Validate pin code to be exactly 6 digits
    if (_pincodeController.text.length != 6 || !RegExp(r'^\d{6}$').hasMatch(_pincodeController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pin code must be exactly 6 digits!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Retrieve the token from secure storage
    final storage = FlutterSecureStorage();
    String? token = await storage.read(key: "access_token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token is missing or expired! Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate machine number uniqueness
    bool isMachineNumberExist =
        await _checkMachineNumberExists(token, _machineNumberController.text);
    if (isMachineNumberExist) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Machine number already exists! Please enter a unique machine number.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Fetch the business ID by business name
    String businessName = _businessNameController.text;
    int? businessId = await _getBusinessIdByName(token, businessName);

    if (businessId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business name not found!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare machine data for API request
    try {
      if(widget.machine == null) {
        bool success = await apiServices.createMachine(
          token: token,
          name: _machineNameController.text,
          number: _machineNumberController.text,
          street: _streetController.text,
          city: _cityController.text,
          state: _selectedState!,
          pinCode: _pincodeController.text,
          businessId: businessId,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Machine created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Optionally clear form fields or navigate away
        } else {
          throw Exception('Failed to create machine. Unknown error occurred.');
        }
      }
      else {
        // Update existing machine
        bool success = (await apiServices.updateMachine(
          machineId: widget.machine['id'],
          name: _machineNameController.text,
          number: _machineNumberController.text,
          street: _streetController.text,
          city: _cityController.text,
          state: _selectedState!,
          pinCode: _pincodeController.text,
          businessId: businessId, // Replace with actual business ID logic
        )) as bool;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Machine updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      Navigator.pop(context); // Go back after saving
    }
    catch (e, stackTrace) {
      print('Error occurred: $e');
      print('Stack Trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create machine. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _checkMachineNumberExists(
      String token, String machineNumber) async {
    try {
      // Fetch machine details
      List<dynamic> machines = await apiServices.fetchMachineDetails(token);

      // Check if the machine number exists in the fetched list
      bool exists = machines.any((machine) {
        // Assuming each machine has a 'machineNumber' field in its data
        return machine['number'] == machineNumber;
      });

      return exists;
    } catch (e) {
      print('Error checking machine number existence: $e');
      return false;
    }
  }

  Future<int?> _getBusinessIdByName(String token, String businessName) async {
    try {
      // Call the API to get all business details
      List<dynamic> businesses = await apiServices.fetchBusinessDetails(token);

      // Search for the business by name
      for (var business in businesses) {
        print(
            'Comparing: user input "$businessName" with API value "${business['name']}"');

        if (business['name'] == businessName) {
          print(
              'Match found for business name: ${business['name']}, ${business['id']}');
          return business['id']; // Return the business_id
        }
      }

      // If no business matches, log and return null
      print('No match found for business name: $businessName');
      return null;
    } catch (e) {
      print('Error fetching business id: $e');
      return null;
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  top: 12.0, left: 14.0, right: 10.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.machine == null ? 'Add Machine' : 'Update Machine',
                    style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildTextFormField(
                    controller: _machineNameController,
                    labelText: 'Machine Name',
                    icon: FontAwesomeIcons.box,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildTextFormField(
                    controller: _machineNumberController,
                    labelText: 'Machine Number',
                    icon: FontAwesomeIcons.box,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildDropdown(
                    labelText: 'Business Name',
                    icon: FontAwesomeIcons.briefcase,
                    items: _businessNames,
                    value: _selectedBusinessName,
                    onChanged: (value) {
                      setState(() {
                        _selectedBusinessName =
                            value; // Update the state with the selected value
                        _businessNameController.text =
                            value!; // Update the text controller
                      });
                    },
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildDropdown(
                    labelText: 'State',
                    icon: FontAwesomeIcons.solidFlag,
                    items: _states,
                    value: _selectedState,
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                      });
                    },
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildTextFormField(
                    controller: _cityController,
                    labelText: 'City',
                    icon: FontAwesomeIcons.city,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildTextFormField(
                    controller: _streetController,
                    labelText: 'Street',
                    icon: FontAwesomeIcons.road,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextFormField(
                    controller: _pincodeController,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: AppTheme.textBlack,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Pin Code',
                      labelStyle: TextStyle(fontSize: screenWidth * 0.03),
                      prefixIcon: Icon(
                        FontAwesomeIcons.locationDot,
                        size: screenWidth * 0.05,
                        color: AppTheme.backgroundBlue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the pin code';
                      }
                      if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                        return 'Pin code must be exactly 6 digits';
                      }
                      return null;
                    },
                  ),

                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomElevatedButton(
                  buttonText: 'Cancel',
                  onPressed: () {
                    print("Cancel button pressed");
                  },
                  width: screenWidth * 0.4,
                  backgroundColor: AppTheme.backgroundWhite,
                  textColor: AppTheme.backgroundBlue,
                  borderColor: AppTheme.backgroundBlue,
                  icon: const Icon(
                    Icons.cancel,
                    color: AppTheme.backgroundBlue,
                  ),
                ),
                CustomElevatedButton(
                  buttonText: widget.machine == null ? 'Add ' : 'Update ',
                  onPressed: _submitPressed,
                  width: screenWidth * 0.4,
                  backgroundColor: AppTheme.backgroundBlue,
                  textColor: AppTheme.textWhite,
                  icon: const Icon(
                    Icons.check,
                    color: AppTheme.textWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required double screenWidth,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontSize: screenWidth * 0.03,
        color: AppTheme.textBlack,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: screenWidth * 0.03),
        prefixIcon: Icon(
          icon,
          size: screenWidth * 0.05,
          color: AppTheme.backgroundBlue,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String labelText,
    required IconData icon,
    required List<String> items,
    required String? value, // Change to nullable String
    required ValueChanged<String?> onChanged,
    required double screenWidth,
  }) {
    return DropdownButtonFormField<String>(
      value: value ??
          (items.isNotEmpty ? items[0] : null), // Correct grouping of condition
      items: items
          .map<DropdownMenuItem<String>>(
            (String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: AppTheme.textBlack,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: screenWidth * 0.03),
        prefixIcon: Icon(
          icon,
          size: screenWidth * 0.05,
          color: AppTheme.backgroundBlue,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
