import 'package:bottle_crush/screens/dashboard.dart';
import 'package:bottle_crush/screens/view_business.dart';
import 'package:bottle_crush/screens/view_machines.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_elevated_button.dart';
import 'package:bottle_crush/services/api_services.dart';

class Email extends StatefulWidget {
  const Email({super.key});

  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {
  int _selectedIndex = 3;
  String selectedFileName = '';
  String? selectedFilePath;

  bool _isLoading = false;

  final TextEditingController _toController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageBodyController = TextEditingController();

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ViewBusiness()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ViewMachines()),
      );
    }
  }

  Future<void> _sendEmail() async {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String? token = await secureStorage.read(key: 'access_token');
    final toEmail = _toController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageBodyController.text.trim();

    if (toEmail.isEmpty || subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all the required fields.", style: TextStyle(color: isDark ? textBlack : textWhite),), backgroundColor: isDark ? textWhite : textBlack, duration: const Duration(seconds: 1),),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sending email... Please wait.",style: TextStyle(color: isDark ? textBlack : textWhite),), backgroundColor: isDark ? textWhite : textBlack, duration: const Duration(seconds: 1),),
    );

    try {

      final response = await ApiServices.sendEmail(
        token: token!,
        toEmail: toEmail,
        subject: subject,
        message: message,
        filePath: selectedFilePath,
      );

      if (response.containsKey('message')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email sent successfully!",style: TextStyle(color: isDark ? textBlack : textWhite),), backgroundColor: isDark ? textWhite : textBlack, duration: const Duration(seconds: 1),),
        );

        // Clear all input fields and file selection
        _toController.clear();
        _subjectController.clear();
        _messageBodyController.clear();
        setState(() {
          selectedFileName = '';
          selectedFilePath = null;
        });

        // Navigate to the dashboard
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
      } else {
        debugPrint("Error : ${response['error']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email not sent",style: TextStyle(color: isDark ? textBlack : textWhite),), backgroundColor: isDark ? textWhite : textBlack,duration: const Duration(seconds: 1),),
        );
      }
    } catch (e) {
      debugPrint("Error: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email not sent",style: TextStyle(color: isDark ? textBlack : textWhite),), backgroundColor: isDark ? textWhite : textBlack, duration: const Duration(seconds: 1),),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

    double fontSize = isTablet ? 20 : 14;
    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: CustomBottomAppBar(
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
      backgroundColor: isDark ? textBlack : backgroundWhite,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send Email',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: isDark ? textWhite :textBlack
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _toController,
                    style: TextStyle(fontSize: fontSize),
                    decoration: InputDecoration(
                      labelText: 'To',
                      labelStyle: TextStyle(color: isDark ? backgroundWhite : backgroundBlue, fontSize: fontSize),
                      contentPadding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 12.0),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _subjectController,
                    style: TextStyle(fontSize: fontSize),
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      labelStyle: TextStyle(color: isDark ? backgroundWhite : backgroundBlue, fontSize: fontSize),
                      contentPadding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 12.0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedFileName.isNotEmpty ? selectedFileName : 'No file selected',
                          style: TextStyle(
                            color: isDark ? backgroundWhite : backgroundBlue,
                            fontSize: fontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CustomElevatedButton(
                        buttonText: 'Attach',
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'xls', 'xlsx'],
                          );

                          if (result != null && result.files.isNotEmpty) {
                            setState(() {
                              selectedFileName = result.files.single.name;
                              selectedFilePath = result.files.single.path;
                            });
                          }
                        },
                        width: screenWidth * 0.3,
                        backgroundColor: isDark? backgroundBlue : backgroundBlue,
                        textColor: isDark ? textWhite : textWhite,
                        icon: Icon(FontAwesomeIcons.paperclip,
                           color: isDark ? textWhite : textWhite
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _messageBodyController,
                    maxLines: 10,
                    style: TextStyle(fontSize: fontSize),
                    decoration: InputDecoration(
                      labelText: 'Message',
                      labelStyle: TextStyle(color: isDark ? backgroundWhite : backgroundBlue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDark ? textWhite: textWhite
                        ),
                      ),

                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomElevatedButton(
                      buttonText: 'Send',
                      onPressed: _sendEmail,
                      width: screenWidth * 0.3,
                      backgroundColor: isDark ? backgroundBlue : backgroundBlue,
                      textColor: isDark ? textWhite : textWhite,
                      icon: Icon(FontAwesomeIcons.solidPaperPlane,
                          color: isDark ? textWhite : textWhite
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

