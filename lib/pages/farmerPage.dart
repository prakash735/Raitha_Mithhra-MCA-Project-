import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raithamithra/pages/investorlist.dart';
import 'package:raithamithra/pages/profile.dart';
import 'package:raithamithra/pages/addland.dart';
import 'package:raithamithra/pages/farmeragreement.dart';
import 'package:raithamithra/pages/myland.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hive/hive.dart';
import '../auth/phone.dart';

class FarmerHome extends StatefulWidget {
  const FarmerHome({Key? key}) : super(key: key);

  @override
  State<FarmerHome> createState() => _FarmerHomeState();
}

class _FarmerHomeState extends State<FarmerHome> {
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

  void navigateBackToInvestorPage(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
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
                          image: DecorationImage(
                            image: AssetImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Assets',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeatureButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddLand(),
                            ),
                          );
                        },
                        icon: CupertinoIcons.news_solid,
                        label: 'Add Land',
                      ),
                      _buildFeatureButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyLand(),
                            ),
                          );
                        },
                        icon: CupertinoIcons.doc_checkmark_fill,
                        label: 'My Lands',
                      ),
                      _buildFeatureButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FarmerAgreement(),
                            ),
                          );
                        },
                        icon: Icons.handshake,
                        label: 'Agreements',
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Investors',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InvestorList(),
                            ),
                          );
                        },
                        child: Text(
                          'See more>',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildInvestorsList(),
                ],
              ),
            ),
          ],
        ),

      ),
    );
  }

  Widget _buildFeatureButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Color(0xff575756),
              size: 40,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvestorsList() {
    return Container(
      height: 120,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('defaultRole', isEqualTo: 'investor')
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
                return Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'investor_$index',
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: profileUrl != null
                              ? NetworkImage(profileUrl)
                              : AssetImage(
                              'assets/profile_placeholder.jpg') as ImageProvider,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        fullName.length > 10
                            ? '${fullName.substring(0, 10)}...'
                            : fullName,
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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
    );
  }
}
