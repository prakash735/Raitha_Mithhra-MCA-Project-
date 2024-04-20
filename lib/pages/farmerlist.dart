import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:raithamithra/pages/iagreement.dart';

class Farmerlist extends StatefulWidget {
  const Farmerlist({super.key});

  static String farmerUUID = '';
  static String farmerAssetUUID = '';
  @override
  State<Farmerlist> createState() => _FarmerlistState();
}

class _FarmerlistState extends State<Farmerlist> {
  List<Map<String, dynamic>> _selectedInvestors = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Farmer List'),
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
                bool isSelected = _selectedInvestors.contains(investor);
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
                          'Land Size: ${investor['entity']}',
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
                        Text(  'Farmer name: ${investor['fname']}',

                          style:  TextStyle(color: Colors.grey[700]),
                        ),

                        SizedBox(height: 4),
                      ],
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        // Perform action when the button is clicked
                        print('Button clicked for investor: ${investor['userAssetUUID']}');
                        setState(() {
                          Farmerlist.farmerAssetUUID = investor['userAssetUUID'];
                          Farmerlist.farmerUUID = investor['userUUID'];
                        });
                        Get.to(()=>const InvAgreement());
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: isSelected ? Colors.white : Colors.black,
                      ),
                      child: Text(
                        'Select',
                        style: TextStyle(color: isSelected ? Colors.black : Colors.white),
                      ),
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
          .where('isCompany', isEqualTo: false)
          .where('status', isEqualTo: 'approved')
          .get();

      List<Map<String, dynamic>> investors = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['isCompany'] == false) {
          var userUUID = data['userUUID'];
          var userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userUUID)
              .get();

          if (userSnapshot.exists) {
            var userData = userSnapshot.data() as Map<String, dynamic>;
            var farmerName = userData['fullName'] ?? '';
            investors.add({
              'location': data['location']['address1'] ?? '',
              'location1': data['location']['address2'] ?? '',
              'city': data['location']['city'] ?? '',
              'district': data['location']['district'] ?? '',
              'state': data['location']['state'] ?? '',
              'fname': farmerName,
              'entity1': data['land']['ownername'] ?? '',
              'entity': data['land']['landsize'] ?? '',
              'userAssetUUID': doc.id,
              'userUUID': data['userUUID'] ?? '',
            });
          }
        }
      }

      return investors;
    } catch (error) {
      throw error;
    }
  }

}


