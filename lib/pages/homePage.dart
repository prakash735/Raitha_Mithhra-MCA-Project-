import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../auth/phone.dart';
import 'farmerLand.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'more.dart'; // Import FirebaseFirestore for Firebase Firestore operations

class FarmerPage extends StatefulWidget {
  const FarmerPage({Key? key}) : super(key: key);

  @override
  State<FarmerPage> createState() => _FarmerPageState();
}

class _FarmerPageState extends State<FarmerPage> {
  late VideoPlayerController _controller;

  // Define a variable to store user data fetched from Firestore
  late Map<String, dynamic> _userData = {};

  var userData;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/nature.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });

    // Fetch user details based on phone number when the page loads
    checkAndFetchData();
  }

  // Function to fetch user details from Firestore
  // Initialize with an empty map
  Future<void> checkAndFetchData() async {
    try {
      // Reference to the Firestore collection
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      // Query to check if the phone number exists in any document
      QuerySnapshot querySnapshot = await users
          .where('phoneNumber', isEqualTo: int.tryParse(PhoneOTP.userPhoneNumber))
          .get();
      print(querySnapshot.docs);
      if (querySnapshot.docs.isNotEmpty) {
        // Phone number exists, fetch and print data
        setState(() {
          PhoneOTP.gotFirebaseUserData = null;
        });
        var userData = querySnapshot.docs.first.data();
        setState(() {
          PhoneOTP.gotFirebaseUserData = querySnapshot.docs.first.data();
          _userData = userData as Map<String, dynamic>; // Store the fetched user data
          // SmsOTP_Number_Page.gotUserIDFireBaseData = querySnapshot.docs.first.id;
        });
        print("User Data got From Firebase : $userData");
        //if membership found, find it's new invite code or already login
      } else {
        print("No User Data");
        //Get
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffefd27e),
        elevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                SizedBox(width: 80),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hi, ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          _userData['fullName'] ?? '', // Display user's full name
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          ' ! 👋',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Handle notification icon tap
              },
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xffFFF8E2),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xffefd27e),
        child: Container(
          height: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  // Navigate to home screen
                },
              ),
              IconButton(
                icon: Icon(Icons.local_offer),
                onPressed: () {
                  // Navigate to search screen
                },
              ),
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MorePage()),
                  );
                  // Navigate to settings screen
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 350,
                  height: 150,
                  color: Colors.grey,
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                      : Container(),
                ),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandFill()),
                );
              },
              child: Material(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.0),
                child: Stack(
                  children: [
                    Container(
                      width: 400,
                      height: 150,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/farmerland.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Click here to fill the land details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 100,
                      left: 10,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          'My Land',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: 200, // Adjust position as needed
              child: Container(
                width: 100, // Adjust width as needed
                height: 100, // Adjust height as needed
                child: Image.asset('assets/select1.png'), // Replace 'your_image.png' with your PNG image asset
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 350,
                  height: 150,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FarmerPage(),
  ));
}
