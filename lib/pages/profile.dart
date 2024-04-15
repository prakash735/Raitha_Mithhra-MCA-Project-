import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:raithamithra/_utils/splashscreen.dart';
import 'package:raithamithra/pages/aboutus.dart';
import 'package:raithamithra/pages/settingspage.dart';

import '../auth/phone.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var gotUserData;
  String? profileUrl; // Holds the profile image URL
  String? fullName; // Holds the full name

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: PhoneOTP.userPhoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in querySnapshot.docs) {
          setState(() {
            gotUserData = doc;
            PhoneOTP.useUUIDLocal= gotUserData['userUUID'];
            profileUrl = doc['profileUrl'] as String?; // Retrieve profile image URL
            fullName = doc['fullName'] as String?; // Retrieve full name
          });
          getAssetData();
        }
      } else {
        print('No data found for phone number');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void getAssetData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('assets')
          .where('userUUID', isEqualTo: gotUserData['userUUID'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in querySnapshot.docs) {
          print(doc.data());
        }
      } else {
        print('No data found for phone number');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Function to handle image picking from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await uploadImage(imageFile);
    } else {
      print('No image selected.');
    }
  }
  Future<void> lougout() async {
    await Hive.openBox('userData');
    var box = Hive.box('userData');
    await box.put('phoneNumber',  '');
      Get.offAll(()=>const SplashScreen());
  }
  // Function to upload image to Firebase Storage
  Future<void> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref =
      firebase_storage.FirebaseStorage.instance.ref().child('profilePic/$fileName');
      await ref.putFile(imageFile);
      String imageUrl = await ref.getDownloadURL();
      setState(() {
        profileUrl = imageUrl;
      });
      await updateProfileImageUrl(imageUrl);
    } catch (error) {
      print('Error uploading image: $error');
    }
  }



  // Function to update profile image URL in Firestore
  Future<void> updateProfileImageUrl(String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(gotUserData.id).update({
        'profileUrl': imageUrl,
      });
      print('Profile image URL updated successfully.');
    } catch (error) {
      print('Error updating profile image URL: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Color(0xffC4AB62),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Show a dialog to choose image source
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Choose Image Source'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              GestureDetector(
                                child: Text('Gallery'),
                                onTap: () {
                                  _pickImage(ImageSource.gallery);
                                  Navigator.of(context).pop();
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                              ),
                              GestureDetector(
                                child: Text('Camera'),
                                onTap: () {
                                  _pickImage(ImageSource.camera);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: profileUrl != null
                      ? NetworkImage(profileUrl!)
                      : AssetImage('assets/profile_placeholder.jpg') as ImageProvider,
                ),
              ),
              SizedBox(height: 20),
              Text(
                fullName ?? 'Loading...', // Display the full name or 'Loading...' if not fetched yet
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
              // Enhanced UI for options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) => AboutUs()),);
                    },
                    child: Column(
                      children: [
                        Icon(Icons.info, size: 30, color: Colors.blue),
                        Text('About Us', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage()),);
                    },
                    child: Column(
                      children: [
                        Icon(Icons.settings, size: 30, color: Colors.blue),
                        Text('Settings', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Implement logout functionality here
                      await lougout();
                    },
                    child: Column(
                      children: [
                        Icon(Icons.logout, size: 30, color: Colors.red),
                        Text('Logout', style: TextStyle(fontSize: 16, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilePage(),
    );
  }
}
