import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:clipboard/clipboard.dart';

import '../auth/phone.dart';

class MorePage extends StatefulWidget {
  const MorePage({Key? key}) : super(key: key);

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final String farmerID = '123456'; // Example ID, replace with actual ID

  late Map<String, dynamic> _userData = {};

  var userData;

  @override
  void initState() {
    super.initState();
    // Fetch user details based on phone number when the page loads
    checkAndFetchData();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Color(0xffFFF8E2),
              height: 24,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 24),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Color(0xffFFF8E2),
                      height: 170,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 60,
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.supervised_user_circle),
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userData['fullName'] ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'Farmer ID: $farmerID',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {
                                            FlutterClipboard.copy(farmerID); // Copy the Farmer ID to clipboard
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Copied to clipboard'), // Display a message
                                                duration: Duration(seconds: 1), // Adjust duration as needed
                                              ),
                                            );
                                          },
                                          child: Icon(Icons.copy, color: Colors.black, size: 20), // Decrease icon size
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        // Navigate to MyProfile page
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            'My Profile',
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blue),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildRow('Land OverView', Icons.assignment_turned_in_outlined),
                          SizedBox(height: 15), // Increased vertical gap between rows
                          buildRow('Agreement Statement', Icons.agriculture_sharp),
                          SizedBox(height: 15),
                          buildRow('All Investors', Icons.people),
                          SizedBox(height: 15),
                          buildRow('Learn', Icons.school),
                          SizedBox(height: 15),
                          buildRow('Gift Voucher', Icons.card_giftcard),
                          SizedBox(height: 15),
                          buildRow('About Us', Icons.info),
                          SizedBox(height: 15),
                          buildRow('Rate Us', Icons.star),
                          SizedBox(height: 15),
                          buildLogoutRow(context), // Logout row
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                color: Color(0xffefd27e),
                child: Container(
                  height: 36,
                  child: Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(Icons.home, size: 24),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.local_offer, size: 24),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.menu, size: 24),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRow(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 20), // Increased gap between icon and text
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Icon(Icons.arrow_forward_ios, size: 20), // Arrow icon
        ],
      ),
    );
  }

  Widget buildLogoutRow(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show confirmation dialog before logout
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirmation"),
              content: Text("Are you sure you want to log out?"),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                ),
                TextButton(
                  child: Text("Logout"),
                  onPressed: () {
                    // Perform logout action
                    // For example, you can navigate to the login screen and clear any user authentication data
                    Navigator.pushNamedAndRemoveUntil(context, '_utils/splashscreen', (route) => true);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 20), // Increased gap between icon and text
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, size: 20), // Arrow icon
          ],
        ),
      ),
    );
  }
}
