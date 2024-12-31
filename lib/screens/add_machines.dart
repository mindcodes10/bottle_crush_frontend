import 'package:bottle_crush/screens/dashboard.dart';
import 'package:bottle_crush/screens/email.dart';
import 'package:bottle_crush/screens/view_business.dart';
import 'package:bottle_crush/screens/view_machines.dart';
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
  int _selectedIndex = 2;
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

    // Navigate to respective screen based on the selected index
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewBusiness()),
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

  // Fetch company names from API and populate the list
  Future<void> _fetchBusinessNames() async {
    try {
      final String? token = await _secureStorage.read(key: "access_token");
      if (token != null) {
        List<dynamic> businesses = await apiServices.fetchBusinessDetails(token);

        setState(() {
          _businessNames.clear();
          for (var business in businesses) {
            _businessNames.add(business['name']);
          }

          // Avoid overwriting if editing
          if (widget.machine != null) {
            _selectedBusinessName = widget.machine['business_name'];
          } else if (_businessNames.isNotEmpty) {
            _selectedBusinessName = _businessNames[0];
            _businessNameController.text = _selectedBusinessName!;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching company names: $e');
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
        ),
      );
      return;
    }

    // Validate pin code to be exactly 6 digits
    if (_pincodeController.text.length != 6 || !RegExp(r'^\d{6}$').hasMatch(_pincodeController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pin code must be exactly 6 digits!'),
        ),
      );
      return;
    }

    // Retrieve the token from secure storage
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "access_token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token is missing or expired! Please log in again.'),
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
          content: Text('Company name not found!'),
        ),
      );
      return;
    }

    try {
      // If updating an existing machine, check if the machine number has changed
      bool isMachineNumberExist = false;
      if (widget.machine == null || widget.machine!['number'] != _machineNumberController.text) {
        // Check for machine number uniqueness only if it is being changed
        isMachineNumberExist = await _checkMachineNumberExists(token, _machineNumberController.text);
      }

      if (isMachineNumberExist) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Machine number already exists! Please enter a unique machine number.'),
          ),
        );
        return;
      }

      if (widget.machine == null) {
        // Create new machine
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
            ),
          );
          Navigator.pop(context, true); // Return true on success
        } else {
          throw Exception('Failed to create machine. Unknown error occurred.');
        }
      } else {
        // Update existing machine
        var response = await apiServices.updateMachine(
          machineId: widget.machine['id'],
          name: _machineNameController.text,
          number: _machineNumberController.text,
          street: _streetController.text,
          city: _cityController.text,
          state: _selectedState!,
          pinCode: _pincodeController.text,
          businessId: businessId,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Machine updated successfully!'),
            ),
          );
          Navigator.pop(context, true); // Return true on success
        } else {
          // Handle the error response
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update machine'),
            ),
          );
          debugPrint('Failed to update machine: ${response.body}');
        }
      }
    }
    catch (e, stackTrace) {
      debugPrint('Error occurred: $e');
      debugPrint('Stack Trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong..please try again later'),
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
      debugPrint('Error checking machine number existence: $e');
      return false;
    }
  }

  Future<int?> _getBusinessIdByName(String token, String businessName) async {
    try {
      // Call the API to get all business details
      List<dynamic> businesses = await apiServices.fetchBusinessDetails(token);

      // Search for the business by name
      for (var business in businesses) {
        debugPrint('Comparing: user input "$businessName" with API value "${business['name']}"');

        if (business['name'] == businessName) {
          debugPrint('Match found for company name: ${business['name']}, ${business['id']}');
          return business['id']; // Return the business_id
        }
      }

      // If no business matches, log and return null
      debugPrint('No match found for company name: $businessName');
      return null;
    } catch (e) {
      debugPrint('Error fetching company id: $e');
      return null;
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
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
      backgroundColor: AppTheme.backgroundWhite,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 12.0, left: 14.0, right: 10.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.machine == null ? 'Add Machine' : 'Update Machine',
                    style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
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
                    labelText: 'Company Name',
                    icon: FontAwesomeIcons.briefcase,
                    items: _businessNames,
                    value: _selectedBusinessName,
                    onChanged: (value) {
                      setState(() {
                        _selectedBusinessName = value; // Update the state with the selected value
                        _businessNameController.text = value!; // Update the text controller
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
                      fontSize: fontSize,
                      color: AppTheme.textBlack,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Pin Code',
                      labelStyle: TextStyle(fontSize: fontSize),
                      prefixIcon: Icon(
                        FontAwesomeIcons.locationDot,
                        size: iconSize,
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
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomElevatedButton(
                  buttonText: 'Cancel',
                  onPressed: () {
                   Navigator.pop(context);
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isTablet = screenWidth > 600;

    double fontSize = isTablet ? 20 : 14;
    double iconSize = isTablet ? 30 : 24;
    double fieldHeight = isTablet ? 70 : 50;
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontSize: fontSize,
        color: AppTheme.textBlack,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: fontSize),
        prefixIcon: Icon(
          icon,
          size: iconSize,
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
    double screenWidth = MediaQuery.of(context).size.width;

    bool isTablet = screenWidth > 600;

    double fontSize = isTablet ? 18 : 14;
    double iconSize = isTablet ? 30 : 24;
    double fieldHeight = isTablet ? 70 : 50;

    return Container(
      color: AppTheme.backgroundWhite, // Set the background color
      //padding: const EdgeInsets.all(8.0), // Optional: Padding for spacing
      child: DropdownButtonFormField<String>(
        value: value ?? (items.isNotEmpty ? items[0] : null),
        items: items
            .map<DropdownMenuItem<String>>(
              (String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                color: AppTheme.textBlack,
              ),
            ),
          ),
        )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: fontSize),
          prefixIcon: Icon(
            icon,
            size: iconSize,
            color: AppTheme.backgroundBlue,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

}
