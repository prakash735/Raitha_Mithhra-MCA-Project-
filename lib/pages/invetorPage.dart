import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raithamithra/pages/addorg.dart';
import 'package:raithamithra/pages/myorg.dart';
import 'package:raithamithra/pages/profile.dart';

import '../auth/phone.dart';
import 'addland.dart';
import 'farmerlist.dart';
import 'investorAgreement.dart';
import 'investorlist.dart';
import 'myland.dart';

class InvestorHome extends StatefulWidget {
  const InvestorHome({super.key});

  @override
  State<InvestorHome> createState() => _InvestorHomeState();
}

class _InvestorHomeState extends State<InvestorHome> {
  var gotUserData;
  bool isLandDataAvl = false;
  final List<String> imageUrls = [
    'assets/image1.jpeg',
    'assets/image2.jpeg',
    'assets/image6.jpeg',
    'assets/image5.jpeg',
    'assets/image7.jpeg',
    'assets/image10.jpeg',
  ];
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: int.parse(PhoneOTP.userPhoneNumber))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in querySnapshot.docs) {
          setState(() {
            gotUserData = doc;
            PhoneOTP.useUUIDLocal= gotUserData['userUUID'];
            isLandDataAvl = true;
          });
          print(doc.data());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFF8E2),
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(CupertinoIcons.profile_circled),
            ),
          ),
        ],
        title: Row(
          children: [
            Image.asset(
              'assets/text_logo.png',
              width: 110,
              height: 110,
            ),
          ],
        ),
        backgroundColor: Color(0xffC4AB62),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  aspectRatio: MediaQuery.of(context).size.width,
                  height: 200,
                  enlargeCenterPage: true,
                  viewportFraction: 1.0,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                ),
                items: imageUrls.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'My Assets',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddOrg(),
                                ),
                              );
                            },
                            icon: Column(
                              children: [
                                Icon(
                                  CupertinoIcons.news_solid,
                                  color: Color(0xff575756),
                                  size: 40,
                                ),
                                Text('Add Org'),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyOrg(),
                                ),
                              );
                            },
                            icon: Column(
                              children: [
                                Icon(
                                  CupertinoIcons.doc_checkmark_fill,
                                  color: Color(0xff575756),
                                  size: 40,
                                ),
                                Text('My Org'),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () {Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InvestorAgreement(),
                              ),
                            );},
                            icon: Column(
                              children: [
                                Icon(
                                  Icons.fiber_dvr,
                                  color: Color(0xff575756),
                                  size: 40,
                                ),
                                Text('My Score'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Farmers',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Farmerlist(),
                      ),
                    );
                  },
                  child: Text(
                    'see more>>',
                    style: TextStyle(fontSize: 10),
                  ),
                )
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('defaultrole', isEqualTo: 'investor')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var investors = snapshot.data!.docs;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: investors.length,
                        itemBuilder: (context, index) {
                          var fullName = investors[index]['fullName'];
                          var profileUrl = investors[index]['profileUrl'];
                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: profileUrl != null
                                    ? NetworkImage(profileUrl!)
                                    : AssetImage('assets/profile_placeholder.jpg') as ImageProvider,
                              ),
                              SizedBox(height: 5),
                              Text(
                                fullName,
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
