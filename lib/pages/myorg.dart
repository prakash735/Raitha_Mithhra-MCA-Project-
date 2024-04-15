
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../auth/phone.dart';

class MyOrg extends StatefulWidget {
  const MyOrg({super.key});

  @override
  State<MyOrg> createState() => _MyOrgState();
}

class _MyOrgState extends State<MyOrg> {
  List<Map<String, dynamic>> _lands = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('My Organisation'),
          backgroundColor: Color(0xffC4AB62)
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchInvestors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var investor = snapshot.data![index];
                bool isSelected = _lands.contains(investor);
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      investor['entity1'].toString().toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          'Org age: ${investor['entity']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Address: ${investor['location']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 2),
                        Text(
                          investor['location1'],
                          style:  TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 2),
                        Text(
                          investor['city'],
                          style:  TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 2),
                        Text(
                          investor['district'],
                          style:  TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 2),
                        Text(
                          investor['state'],
                          style:  TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 2),


                        SizedBox(height: 4),
                      ],
                    ),

                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchInvestors() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('assets')
          .where('isCompany', isEqualTo: true).where('userUUID', isEqualTo: PhoneOTP.useUUIDLocal) // Adjust the query to fetch based on 'entity' field
          .get();

      List<Map<String, dynamic>> investors = [];

      querySnapshot.docs.forEach((doc) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['isCompany'] == true) {
          investors.add({
            'location': data['location']['address1']?? '',
            'location1': data['location']['address2']?? '',
            'city': data['location']['city']?? '',
            'district': data['location']['district']?? '',
            'state': data['location']['state']?? '',
            'entity1': data['entity']['entityname'] ?? '',
            'entity': data['entity']['entityage'] ?? '',
          });
        }
      });

      return investors;
    } catch (error) {
      throw error;
    }
  }
}

