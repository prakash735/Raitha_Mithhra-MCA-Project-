import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:raithamithra/pages/farmerStatus.dart';
import 'package:raithamithra/pages/profile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the fl_chart package

import '../auth/phone.dart';
import 'addland.dart';
import 'investorStatus.dart';
import 'myland.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  var gotUserData;
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
    getDataLocalOfUser();
  }

  Future<void> getDataLocalOfUser() async {
    await Hive.openBox('userData');
    var box = Hive.box('userData');
    var phoneNumber = box.get('phoneNumber');
    setState(() {
      PhoneOTP.userPhoneNumber = phoneNumber;
    });
    getUserData();
    print('Hive Stored Phone Number in smsOTP Number Page in Former Page: $phoneNumber');
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
            PhoneOTP.useUUIDLocal = gotUserData['userUUID'];
          });
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            CarouselSlider(
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
            Container(
              width: MediaQuery.of(context).size.width,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FarmerStatus(),
                            ),
                          );
                        },
                        icon: Column(
                          children: [
                            Icon(
                              CupertinoIcons.person,
                              color: Color(0xff575756),
                              size: 40,
                            ),
                            Text('Farmer'),
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
                              builder: (context) => InvestorStatus(),
                            ),
                          );
                        },
                        icon: Column(
                          children: [
                            Icon(
                              CupertinoIcons.building_2_fill,
                              color: Color(0xff575756),
                              size: 40,
                            ),
                            Text('Investor'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20), // Add some space below the button
            PieChartSample1(), // Display the pie chart widget
          ],
        ),
      ),
    );
  }
}

class PieChartSample1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Loading indicator while fetching data
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        // Extracting counts of farmers and investors
        int farmerCount = snapshot.data!.docs.where((doc) => doc['defaultRole'] == 'farmer').length;
        int investorCount = snapshot.data!.docs.where((doc) => doc['defaultRole'] == 'investor').length;

        return AspectRatio(
          aspectRatio: 1.3,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Count of Farmer and Investor',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: farmerCount.toDouble(),
                            title: 'Farmers: $farmerCount',
                            radius: 50,
                          ),
                          PieChartSectionData(
                            color: Colors.blue,
                            value: investorCount.toDouble(),
                            title: 'Investors: $investorCount',
                            radius: 50,
                          ),
                        ],
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        borderData: FlBorderData(show: false),
                        // PieTouchData is optional
                        // pieTouchData: PieTouchData(touchCallback: (pieTouchResponse, touchEvent) {}),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


