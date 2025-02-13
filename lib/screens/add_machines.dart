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
  const AddMachines({super.key, this.machine});

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

  _submitPressed() async {
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
              content: Text('Machine not updated'),
            ),
          );
          debugPrint('Failed to update machine: ${response.body}');
        }
      }
    } catch (e, stackTrace) {
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

      debugPrint('No match found for company name: $businessName');
      return null;
    } catch (e) {
      debugPrint('Error fetching company id: $e');
      return null;
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required double screenWidth,
    // TextInputType? keyboardType,
    // String? Function(String?)? validator,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double fontSize = MediaQuery.of(context).size.width > 600 ? 18 : 13;
    double iconSize = MediaQuery.of(context).size.width > 600 ? 30 : 20;

    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontSize: fontSize,
        color: isDark ? textWhite : textBlack
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: fontSize, color: isDark ? textWhite : Colors.grey.shade800),
        prefixIcon: Icon(
          icon,
          size: iconSize,
          color: isDark ? backgroundBlue : backgroundBlue,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: isDark ? textWhite : Colors.grey,
            width: 1.0,
          ),
        )
      ),
    );
  }

  void _showDialog(String title, List<String> items, ValueChanged<String?> onSelected) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double fontSize = MediaQuery.of(context).size.width > 600 ? 23 : 18;

        return AlertDialog(
          backgroundColor: isDark ? cardDark : backgroundWhite,
          title: Text(title, style: TextStyle(fontSize: fontSize, color: isDark ? textWhite : textBlack),), // Set the title dynamically
          content: SingleChildScrollView(
            child: ListBody(
              children: items.map((String item) {
                return GestureDetector(
                  onTap: () {
                    onSelected(item);
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 15, color: isDark ? textWhite : textBlack), // Adjust font size as needed
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required String labelText,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    required double screenWidth,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    double fontSize = MediaQuery.of(context).size.width > 600 ? 18 : 13;
    double iconSize = MediaQuery.of(context).size.width > 600 ? 30 : 20;

    return GestureDetector(
      onTap: () {
        _showDialog(
          labelText == 'Company Name' ? 'Select Company' : 'Select State', // Set title based on dropdown
          items,
              (selectedValue) {
            setState(() {
              if (labelText == 'Company Name') {
                _selectedBusinessName = selectedValue;
                _businessNameController.text = selectedValue!;
              } else if (labelText == 'State') {
                _selectedState = selectedValue;
              }
              onChanged(selectedValue);
            });
          },
        );
      },
      child: Container(
        height: 56.0, // Set the height to match the text fields
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isDark ? textBlack : backgroundWhite,
          border: Border.all(
              color: isDark? textWhite : Colors.grey
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(icon, size: iconSize,
              color: isDark ? backgroundBlue : backgroundBlue,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? 'Select $labelText',
                style: TextStyle(fontSize: fontSize,
                  color: isDark ? textWhite : Colors.grey.shade800
                ),
                overflow: TextOverflow.ellipsis, // Handle overflow for the selected value
                maxLines: 1, // Limit to one line for the selected value
              ),
            ),
            Icon(Icons.arrow_drop_down,
              color: isDark ? backgroundBlue : backgroundBlue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isTablet = screenWidth > 600;

    double fontSize = isTablet ? 20 : 14;
    double iconSize = isTablet ? 30 : 24;

    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
      backgroundColor: isDark ? textBlack : backgroundWhite,
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
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      color: isDark ? textWhite : textBlack
                    ),
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
                    onChanged: (value) {},
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildDropdown(
                    labelText: 'State',
                    icon: FontAwesomeIcons.solidFlag,
                    items: _states,
                    value: _selectedState,
                    onChanged: (value) {},
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
                      color: isDark ? textWhite : textBlack
                    ),
                    decoration: InputDecoration(
                      labelText: 'Pin Code',
                     labelStyle: TextStyle(fontSize: fontSize),
                      prefixIcon: Icon(
                        FontAwesomeIcons.locationDot,
                        size: iconSize,
                        color: isDark ? backgroundBlue : backgroundBlue,
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
                  onPressed: () async  {
                    Navigator.pop(context);
                  },
                  width: screenWidth * 0.4,
                  backgroundColor: isDark ? backgroundBlue : backgroundWhite,
                  textColor: isDark ? textWhite : backgroundBlue,
                  borderColor: isDark ? transparent : backgroundBlue,
                  icon: Icon(
                      Icons.cancel,
                      color: isDark? textWhite : backgroundBlue
                  ),
                ),
                CustomElevatedButton(
                  buttonText: widget.machine == null ? 'Add' : 'Update',
                  onPressed: () async {
                    await _submitPressed();  // Ensure that _submitPressed is an async function
                  },
                  width: screenWidth * 0.4,
                  backgroundColor: isDark ? backgroundBlue : backgroundBlue,
                  textColor: isDark ? textWhite : textWhite,
                  icon: Icon(
                    Icons.check,
                   color: isDark ? textWhite : textWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}