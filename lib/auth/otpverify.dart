import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:raithamithra/auth/phone.dart';
import 'package:raithamithra/pages/farmerPage.dart';
import 'package:raithamithra/pages/invetorPage.dart';
import 'package:raithamithra/pages/registration.dart';

import '../pages/adminPage.dart';

class OTPVerify extends StatefulWidget {
  const OTPVerify({super.key});

  @override
  State<OTPVerify> createState() => _OTPVerifyState();
}

class _OTPVerifyState extends State<OTPVerify> {


  TextEditingController textEditingController = TextEditingController();
  int _secondsRemaining = 60;

  bool enableResendOTP = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();
  StreamController<ErrorAnimationType>? errorController;
  bool hasError = false;
  bool enableVerifyOTP = false;


  Future<void> userDataCollectionDB()async{
    if(PhoneOTP.gotFirebaseUserData == null){
      print('Go to New registration');
      Get.offAll(() => RegPage(phoneNumber: PhoneOTP.userPhoneNumber));
    }else{
      storeDataLocalOfUser();
      if(PhoneOTP.gotFirebaseUserData['defaultRole']=='admin'){
        Get.offAll(const AdminHome());
      }
      if(PhoneOTP.gotFirebaseUserData['defaultRole']=='farmer'){
      Get.offAll(const FarmerHome());
      }else{
        Get.offAll(const InvestorHome());
      }
    }

    print('Login Sucessfull');
  }

  Future<void> storeDataLocalOfUser() async {
    await Hive.openBox('userData');
    var box = Hive.box('userData');
    await box.put('phoneNumber',  PhoneOTP.userPhoneNumber);
    var phoneNumber = box.get('phoneNumber');
    print('Hive Stored Phone Number in smsOTP Number Page: $phoneNumber');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFF8E2),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter OTP',
                    style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800)),

                SizedBox(height: 20,),

                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 0,
                    ),
                    child: PinCodeTextField(
                      autoFocus: true,
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      blinkWhenObscuring: true,
                      animationType: AnimationType.fade,
                      validator: (v) {
                        if(v.toString() == PhoneOTP.smsOTP_Number_Page.toString()){

                        }else{
                          return "Enter valid OTP";
                        }
                        if (v!.length < 3) {
                          return "Enter valid OTP";
                        } else {
                          return null;
                        }

                      },
                      pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                          selectedColor: Colors.black,
                          activeColor: Colors.black,
                          inactiveFillColor: Colors.white,
                          inactiveColor: Colors.grey.shade300,
                          selectedFillColor: Colors.white
                      ),
                      cursorColor: Colors.black,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      errorAnimationController: errorController,
                      controller: textEditingController,
                      keyboardType: TextInputType.number,
                      boxShadows: const [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.black12,
                          blurRadius: 10,
                        )
                      ],
                      onCompleted: (v) async {
                        debugPrint("Filled the Text Box $v");
                        if(v.toString() == PhoneOTP.smsOTP_Number_Page.toString()){
                          print('Valid OTP Has Entered......');
                          enableVerifyOTP = true;
                          setState(() {});
                          await userDataCollectionDB();

                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Center(
                              child: Text(
                                'Wrong OTP',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ));
                        }
                      },
                      onChanged: (value) {
                        print('OTP Entered Value $value');
                        setState(() {
                          currentText = value;
                        });
                      },
                      beforeTextPaste: (text) {
                        debugPrint("Allowing to paste $text");
                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                        return true;
                      },
                    ),
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    decoration: BoxDecoration(),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600),
                        onPressed: ()  async {
                          if(enableVerifyOTP == true){
                            await userDataCollectionDB();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Center(
                              child: Text(
                                'Wrong OTP',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ));
                        },
                        child: Text('Verify',
                            style: TextStyle(
                                fontFamily: 'mokoto', fontSize: 18,color: Colors.white)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
