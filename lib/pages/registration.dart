import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:raithamithra/pages/farmerPage.dart';
import 'package:uuid/uuid.dart';

class RegPage extends StatefulWidget {
  final String? phoneNumber;

  const RegPage({Key? key, this.phoneNumber}) : super(key: key);

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController adharNumberController = TextEditingController();
  String? _defaultRole;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Clear text controllers when the page is loaded
    fullNameController.clear();
    emailController.clear();
    // Set the fetched phone number to the phone number controller
    phoneNumberController.text = widget.phoneNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFF8E2),
      appBar: AppBar(
        title: Text(
          'Sign Up',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100, // Adjust height as needed
              width: double.infinity,
              child: Image.asset(
                'assets/text_logo.png', // Path to your logo image asset
                fit: BoxFit.cover, // Adjust how the image fits within the space
              ),
            ),
            SizedBox(height: 20,),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Name:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: fullNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Email ID (optional):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      // Allow empty string as a valid input
                      if (value == null || value.isEmpty) {
                        return null; // Return null if the field is empty
                      }
                      // Validate the email format if it's not empty
                      if (!isValidEmail(value)) {
                        return 'Please enter a valid email ID';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your email ID (optional)',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Phone Number:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Are you:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'farmer',
                        groupValue: _defaultRole,
                        onChanged: (value) {
                          setState(() {
                            _defaultRole = value;
                          });
                        },
                      ),
                      Text('Farmer'),
                      Radio<String>(
                        value: 'investor',
                        groupValue: _defaultRole,
                        onChanged: (value) {
                          setState(() {
                            _defaultRole = value;
                          });
                        },
                      ),
                      Text('Investor'),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Adhar Number:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: adharNumberController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your adhar number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your adhar number',
                    ),
                  ),

                  SizedBox(height: 20),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.black; // Change button color to black on hover
                          }
                          return Colors.grey.shade600; // Default button color
                        }),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          register();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => FarmerHome()), // Navigate to FarmerPage and replace current route
                          );
                        } else {
                          _scrollToFirstError();
                        }
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontFamily: 'mokoto',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void register() {
    String fullName = fullNameController.text;
    String emailID = emailController.text.isEmpty ? '' : emailController.text;
    String phoneNumber = phoneNumberController.text;
    String defaultRole = _defaultRole ?? '';
    int adharnumber = int.parse(adharNumberController.text);
    var uuid = Uuid();
    var docID = uuid.v4();
    // Store the registration data in Firestore
    FirebaseFirestore.instance.collection('users').doc(docID).set({
      'fullName': fullName,
      'emailID': emailID,
      'phoneNumber': int.tryParse(phoneNumber),
      'defaultRole': defaultRole,
      'adharnumber':adharnumber,
      'userUUID':docID,
      'profileUrl':'https://firebasestorage.googleapis.com/v0/b/raitha-mithra-e2eed.appspot.com/o/profilePic%2Fuser.jpeg?alt=media&token=c814973f-42b8-4cb9-9b71-eaf589c36a25'
    }).then((value) async {
      // Data added successfully
      await storeData();
      print('Registration data added to Firestore');
    }).catchError((error) {
      // Error occurred while adding data
      print('Error adding registration data: $error');
      const SnackBar(content: Text('Something Went wrong'));
    });
  }


  storeData() async {
    await Hive.openBox('userData');
    var box = Hive.box('userData');
    await box.put('phoneNumber',  phoneNumberController.text);
    Get.offAll(()=>const FarmerHome());
  }

  void _scrollToFirstError() {
    final scrollPosition = Scrollable.of(context)?.position;
    final firstErrorField = _formKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollPosition != null && firstErrorField != null) {
      final RenderAbstractViewport? viewport = RenderAbstractViewport.of(firstErrorField);
      final RevealedOffset revealedOffset = viewport!.getOffsetToReveal(firstErrorField, 0.0);
      scrollPosition.ensureVisible(
        firstErrorField,
        alignment: 0.5,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return true; // Allow empty string
    }
    // Regular expression for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
