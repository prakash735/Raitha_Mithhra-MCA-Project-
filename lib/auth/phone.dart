import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:raithamithra/auth/otpverify.dart';

import '../_utils/splashscreen.dart';

class PhoneOTP extends StatefulWidget {
  const PhoneOTP({super.key});

  static int smsOTP_Number_Page = 0;
  static var userPhoneNumber;
  static int smsGeneratedOTP = 0;
  static var gotFirebaseUserData;

  @override
  State<PhoneOTP> createState() => _PhoneOTPState();
}

class _PhoneOTPState extends State<PhoneOTP> {

  TextEditingController phoneNumberController = TextEditingController();



  var gotFirebaseUserData;
  Future<void> checkAndFetchData() async {
    try {
      // Reference to the Firestore collection
      CollectionReference users = FirebaseFirestore.instance
          .collection('users');
      print(phoneNumberController.text);
      // Query to check if the phone number exists in any document
      QuerySnapshot querySnapshot = await users
          .where('phoneNumber', isEqualTo: int.tryParse(phoneNumberController.text))
          .get();
      print(querySnapshot.docs);
      if (querySnapshot.docs.isNotEmpty) {
        // Phone number exists, fetch and print data
        setState(() {
          PhoneOTP.gotFirebaseUserData = null;
        });
        var userData = querySnapshot.docs.first.data();
        setState(() {
          gotFirebaseUserData = querySnapshot.docs.first.data();
          PhoneOTP.gotFirebaseUserData = querySnapshot.docs.first.data();
          // SmsOTP_Number_Page.gotUserIDFireBaseData = querySnapshot.docs.first.id;
        });
        await sendSmsOTP();
        print("User Data got From Firebase : $userData");
        print("User Data Stored in Local Variable: $gotFirebaseUserData");
        //if membership found, find it's new invite code or already login
      } else {
        // Phone number doesn't exist, and no membership is not available
        //Send to registration page
        print("No User Data");
        await sendSmsOTP();
        //Get
      }
    } catch (e) {
      print("Error: $e");
    }
  }

// Future<void> storeDataLocalOfUser() async {
  //   await Hive.openBox('userData');
  //   var box = Hive.box('userData');
  //   await box.put('phoneNumber',  gotFirebaseUserData['phoneNumber']);
  //   var phoneNumber = box.get('phoneNumber');
  //   print('Hive Stored Phone Number in smsOTP Number Page: $phoneNumber');
  // }

  checkAndSendOTP() async {
    await sendSmsOTP();
  }

  bool isLoading = false;
  bool enableOtpBtn = false;


  Future sendSmsOTP() async {
    setState(() {
      isLoading = true;
    });
    PhoneOTP.smsOTP_Number_Page = generateRandomSixDigitNumber();
    print('Generated OTP: ${PhoneOTP.smsOTP_Number_Page}');
    final String url = 'https://control.msg91.com/api/v5/flow/';
    // Define your request body
    Map<String, dynamic> requestBody = {
      'template_id': '657d07abd6fc0508cd3a5dc2',
      'short_url': '1',
      'recipients': [
        {
          'mobiles': '91${phoneNumberController.text}',
          'OTP': PhoneOTP.smsOTP_Number_Page.toString(),
          'appName': 'Ritha Mithra'
        }
      ]
    };
    // Encode the request body to JSON
    String jsonBody = json.encode(requestBody);
    // Define your headers
    Map<String, String> headers = {
      'accept': 'application/json',
      'content-type': 'application/json',
      'authkey': '396204AUbmNcHrYc657c6ee6P1',
    };

    try {
      // Make the POST request
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonBody,
      );
      // Handle the response
      if (response.statusCode == 200) {
        // Successful response, you can process the result here
        print('Response: ${response.body}');
        Get.to(()=>const OTPVerify());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Color(0xffBEFE45),
          content: Center(
            child: Text(
              'Try again',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
        // Handle error response
        print('Error(Sending SMS at sendSmsOTP()): ${response.statusCode}');
      }
    } catch (error) {
      // Handle any exceptions that occur
      print('Error(try Api sendSmsOTP()): $error');

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Color(0xffBEFE45),
        content: Center(
          child: Text(
            'Something Went wrong',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Color(0xffBEFE45),
        content: Center(
          child: Text(
            'Try again later',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ));
    }
  }

  int generateRandomSixDigitNumber() {
    print('Generating OTP');
    Random random = Random();
    // Generate a random number between 100,000 and 999,999
    return random.nextInt(900000) + 100000;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffFFF8E2),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/full_logo.png',height: MediaQuery.of(context).size.height*0.2,width: MediaQuery.of(context).size.width*0.8,),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: TextFormField(
            //       autofocus: true,
            //       keyboardType: TextInputType.number,
            //       inputFormatters: [
            //         LengthLimitingTextInputFormatter(
            //             10), // Limit input to 10 characters
            //       ],
            //       onChanged: (c) {
            //         print(c);
            //         if (c.length >= 10) {
            //           setState(() {
            //             enableOtpBtn = true;
            //           });
            //         } else if (c.length <= 10) {
            //           setState(() {
            //             enableOtpBtn = false;
            //           });
            //         }
            //       },
            //       controller: phoneNumberController,
            //       decoration: InputDecoration(
            //           prefixText: '+91 ',
            //           labelText: 'Enter 10-digit Number',
            //           border: OutlineInputBorder())),
            // ),
            // ElevatedButton(onPressed: () async {
            //   await sendSmsOTP();
            // }, child: Text('Send OTP')),
            Positioned(
              bottom: 0,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(

                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Text('Enter Mobile Number',
                            style: TextStyle(
                                fontFamily: 'mokoto', fontSize: 24)),
                        SizedBox(
                          height: 5,
                        ),
                        Text('We\'ll send on OTP through SMS',
                            style: TextStyle(
                                fontFamily: 'mokoto', fontSize: 12)),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                  10), // Limit input to 10 characters
                            ],
                            onChanged: (c) {
                              print(c);
                              if (c.length >= 10) {
                                setState(() {
                                  enableOtpBtn = true;
                                });
                              } else if (c.length <= 10) {
                                setState(() {
                                  enableOtpBtn = false;
                                });
                              }
                            },
                            controller: phoneNumberController,
                            decoration: InputDecoration(
                                prefixText: '+91 ',
                                labelText: 'Enter 10-digit Number',
                                border: OutlineInputBorder())),
                        SizedBox(
                          height: 10,
                        ),
                        enableOtpBtn
                            ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration: BoxDecoration(),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black),
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                    PhoneOTP.userPhoneNumber = phoneNumberController.text;
                                  });
                                  await checkAndFetchData();
                                  // await sendSmsOTP();
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                                child: const Text('Send OTP',
                                    style: TextStyle(
                                        fontFamily: 'mokoto',
                                        fontSize: 18, color: Colors.white))))
                            : Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration: BoxDecoration(),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.grey.shade600),
                                onPressed: () async {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    backgroundColor: Color(0xffBEFE45),
                                    content: Center(
                                      child: Text(
                                        'Enter 10 Digit Number',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ));
                                },
                                child: Text('Send OTP',
                                    style: TextStyle(
                                        fontFamily: 'mokoto',
                                        fontSize: 18, color: Colors.white)))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
