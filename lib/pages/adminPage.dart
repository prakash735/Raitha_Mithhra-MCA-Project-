import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raithamithra/pages/farmerStatus.dart';
import 'package:raithamithra/pages/profile.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'addland.dart';
import 'allAgreements.dart';
import 'investorStatus.dart';
import 'myland.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final List<String> imageUrls = [
    'assets/image1.jpeg',
    'assets/image2.jpeg',
    'assets/image6.jpeg',
    'assets/image5.jpeg',
    'assets/image7.jpeg',
    'assets/image10.jpeg',
  ];

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
      body: Column(
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
                  Expanded(
                    child: IconButton(
                      onPressed: () {Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllAgreements(),
                        ),
                      );},
                      icon: Column(
                        children: [
                          Icon(
                            Icons.file_copy,
                            color: Color(0xff575756),
                            size: 40,
                          ),
                          Text('Agreements'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
