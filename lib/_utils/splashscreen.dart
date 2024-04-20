import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:raithamithra/auth/phone.dart';
import 'package:lottie/lottie.dart';
import 'package:raithamithra/pages/adminPage.dart';
import 'package:raithamithra/pages/farmerPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUpData();
  }

  void setUpData() async {
    await getStoreDataLocalOfUser();

  }

  Future<void> getStoreDataLocalOfUser() async {
    await Hive.openBox('userData');
    var box = Hive.box('userData');
    await box.put('phoneNumber',  '');
    var phoneNumber = box.get('phoneNumber');
    setState(() {
      PhoneOTP.userPhoneNumber = phoneNumber;
    });
    print('Hive Stored Phone Number in smsOTP Number Page: $phoneNumber');
    if(phoneNumber.toString().isEmpty){
      Get.offAll(()=>const PhoneOTP());
    }else{
      Get.offAll(()=>const FarmerHome());
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xffC4AB62) logo gold color
      // backgroundColor: Color(0xff575756) logo brown
      // backgroundColor: Color(0xffFFF8E2) logo brown lite for baground
      backgroundColor: Color(0xffFFF8E2),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/full_logo.png',height: MediaQuery.of(context).size.height*0.2,width: MediaQuery.of(context).size.width*0.9,),
                  Lottie.asset('assets/loading.json',height: 80),
                ],
              ),
            ),
          
    );
  }
}
