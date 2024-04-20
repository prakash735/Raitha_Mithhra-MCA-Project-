import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../auth/phone.dart';
import 'farmerlist.dart';
import 'investorlist.dart';

class FamAgreement extends StatefulWidget {
  const FamAgreement({Key? key}) : super(key: key);

  @override
  State<FamAgreement> createState() => _FamAgreementState();
}

class _FamAgreementState extends State<FamAgreement> {
  List<Map<String, dynamic>> _lands = [];
  List<bool> _isCheckedList = [];
  bool _isAgreed = false;
  String assetUUID ='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffC4AB62),
        title: Text('Investor Agreement'),
      ),
      body: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Farmer is the owner of agricultural land located at [Location of Land], suitable for crop cultivation, while the Investor seeks to invest in agricultural activities and requires a reliable partner for crop cultivation.',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Parties Responsibilities:'
                        'The Farmer is responsible for providing access to the agricultural land for cultivation, undertaking all necessary agricultural activities, maintaining compliance with best practices and legal requirements, and ensuring the lands good condition throughout the cultivation period. On the other hand, the Investors responsibilities include providing financial support for crop cultivation activities, offering necessary equipment and machinery, if applicable, and monitoring the progress of cultivation while providing guidance and support.',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Term and Termination:'
                        'The Agreement shall commence on [commencement date] and continue until the harvest and sale of crops, unless terminated earlier by mutual agreement. Either party may terminate the Agreement with [number] days written notice in case of breach of terms, force majeure events, or other valid reasons.',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    ' Governing Law and Dispute Resolution:'
                        'This Agreement shall be governed by the laws of [State/Country], and any disputes shall be resolved amicably through negotiations. If the parties fail to reach a resolution, the matter shall be referred to arbitration in accordance with the rules of [Arbitration Institution].',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Select your Land',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchInvestors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true, // Set shrinkWrap to true
                    physics: NeverScrollableScrollPhysics(), // Disable scrolling for the ListView
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var investor = snapshot.data![index];
                      bool isSelected = _lands.contains(investor);
                      _isCheckedList.add(false); // Initialize checkbox state for each card
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
                            ],
                          ),
                          trailing: Checkbox(
                            value: _isCheckedList[index],
                            onChanged: (value) {
                              print( investor['entityUUID']);
                              setState(() {
                                assetUUID = investor['entityUUID'];
                                // Update the state of the checkbox
                                _isCheckedList[index] = value!;
                                // Disable other checkboxes when one is selected
                                for (int i = 0; i < _isCheckedList.length; i++) {
                                  if (i != index) {
                                    _isCheckedList[i] = false;
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xffC4AB62),
        child: Row(

          children: [
            Checkbox(
              value: _isAgreed,
              onChanged: (value) {
                setState(() {
                  _isAgreed = value!;
                });
              },
            ),
            Text('I agree to T & C'),
            SizedBox(width: 120),
            ElevatedButton(
              onPressed: () {
                if (_isAgreed) {
                  _submitForm();
                  print('Agreement Accepted');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please agree to the Terms & Conditions.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();

                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Okay'),
            ),
          ],
        ),
      ),
    );
  }
  void _submitForm() async {
    if (_isCheckedList.every((isChecked) => !isChecked)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please select your land.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return; // Exit the method if no land is selected
    }

    var uuid = Uuid();
    var docID = uuid.v4();
    try {
      // Add data to Firestore
      await FirebaseFirestore.instance.collection('agreements').doc(docID).set(
        {
          'farmerAstUUID': Farmerlist.farmerAssetUUID,
          'farmerUUID': Farmerlist.farmerUUID,
          'investorAstUUID': assetUUID,
          'investorUUID': PhoneOTP.useUUIDLocal,
          'date': DateTime.now(),
          'agreUUID': docID,
        },
      );

      Fluttertoast.showToast(
        msg: "Data saved successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Navigate back to the investor list page
      Navigator.pop(context);

    } catch (error) {
      print('Error submitting form: $error');
      // Display an error message
      Fluttertoast.showToast(
        msg: "Error saving data: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }


}

Future<List<Map<String, dynamic>>> fetchInvestors() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('assets')
        .where('isCompany', isEqualTo: false)
        .where('status', isEqualTo: 'approved')
        .where('userUUID', isEqualTo: PhoneOTP.useUUIDLocal)
        .get();

    List<Map<String, dynamic>> investors = [];

    querySnapshot.docs.forEach((doc) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['isCompany'] == false) {
        investors.add({
          'location': data['location']['address1'] ?? '',
          'location1': data['location']['address2'] ?? '',
          'city': data['location']['city'] ?? '',
          'district': data['location']['district'] ?? '',
          'state': data['location']['state'] ?? '',
          'entity1': data['land']['ownername'] ?? '',
          'entity': data['land']['landsize'] ?? '',
          'entityUUID': doc.id,
        });
      }
    });

    return investors;
  } catch (error) {
    throw error;
  }
}

void main() {
  runApp(MaterialApp(
    home: FamAgreement(),
  ));
}
