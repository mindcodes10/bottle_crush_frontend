import 'package:bottle_crush/screens/dashboard.dart';
import 'package:bottle_crush/screens/view_business.dart';
import 'package:bottle_crush/screens/view_machines.dart';
import 'package:bottle_crush/utils/theme.dart';
import 'package:bottle_crush/widgets/custom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_bottom_app_bar.dart';
import 'package:bottle_crush/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Email extends StatefulWidget {
  const Email({super.key});

  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {
  int _selectedIndex = 3;
  String selectedFileName = '';

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageBodyController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewBusiness()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewMachines()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: const CustomAppBar(),
      bottomNavigationBar: CustomBottomAppBar(
          onItemTapped: _onItemTapped, selectedIndex: _selectedIndex),
      backgroundColor: AppTheme.backgroundWhite,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send Email',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBlack,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fromController,
                style: TextStyle(fontSize: screenWidth * 0.03),
                decoration: InputDecoration(
                  labelText: 'From',
                  labelStyle: TextStyle(color: Colors.grey,fontSize: screenWidth * 0.03),
                  contentPadding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 12.0),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _toController,
                style: TextStyle(fontSize: screenWidth * 0.03),
                decoration: InputDecoration(
                  labelText: 'To',
                  labelStyle: TextStyle(color: Colors.grey,fontSize: screenWidth * 0.03),
                  contentPadding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 12.0),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _subjectController,
                style: TextStyle(fontSize: screenWidth * 0.03),
                decoration: InputDecoration(
                  labelText: 'Subject',
                  labelStyle: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.03),
                  contentPadding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 12.0),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedFileName.isNotEmpty
                          ? selectedFileName
                          : '',
                      style: TextStyle(
                        color: AppTheme.backgroundBlue,
                        fontSize: screenWidth * 0.03,
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
                        });
                      }
                    },
                    width: screenWidth * 0.3,
                    backgroundColor: AppTheme.backgroundBlue,
                    textColor: AppTheme.backgroundWhite,
                    borderColor: AppTheme.backgroundBlue,
                    icon: const Icon(FontAwesomeIcons.paperclip, color: AppTheme.backgroundWhite),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _messageBodyController,
                maxLines: 10,
                style: TextStyle(fontSize: screenWidth * 0.03),
                decoration: InputDecoration(
                  labelText: 'Message',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.backgroundBlue),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: CustomElevatedButton(
                  buttonText: 'Send',
                  onPressed: () {

                  },
                  width: screenWidth * 0.3,
                  backgroundColor: AppTheme.backgroundBlue,
                  textColor: AppTheme.backgroundWhite,
                  borderColor: AppTheme.backgroundBlue,
                  icon: const Icon(FontAwesomeIcons.solidPaperPlane, color: AppTheme.backgroundWhite),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
