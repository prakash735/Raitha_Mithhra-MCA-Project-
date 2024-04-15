import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:raithamithra/pages/agreement.dart';

import '../auth/phone.dart';





Future<List<Map<String, dynamic>>> fetchInvestorsDWN() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('assets')
        .where('isCompany', isEqualTo: false)
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
        });
      }
    });

    // Filter out duplicate investors based on 'entity1' field
    List<Map<String, dynamic>> uniqueInvestors = [];
    Set<String> investorNames = Set();

    investors.forEach((investor) {
      if (!investorNames.contains(investor['entity1'])) {
        uniqueInvestors.add(investor);
        investorNames.add(investor['entity1']);
      }
    });

    return uniqueInvestors;
  } catch (error) {
    throw error;
  }
}

class InvestorList extends StatefulWidget {
  const InvestorList({Key? key}) : super(key: key);
  static String investorUUID = '';
  static String investorAssetUUID = '';
  @override
  State<InvestorList> createState() => _InvestorListState();
}

class _InvestorListState extends State<InvestorList> {
  List<Map<String, dynamic>> _investors = [];
  List<String> _selectedInvestors = [];

  @override
  void initState() {
    super.initState();
    _loadInvestors();
  }

  Future<void> _loadInvestors() async {
    try {
      List<Map<String, dynamic>> investors = await fetchInvestorsDWN();
      setState(() {
        _investors = investors;
      });
    } catch (error) {
      // Handle error
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investor List'),
        backgroundColor: Color(0xffC4AB62),
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
                          'Company age: ${investor['entity']}',
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
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 2),
                        Text(
                          investor['city'],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 2),
                        Text(
                          investor['district'],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 2),
                        Text(
                          investor['state'],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 2),
                        SizedBox(height: 4),
                      ],
                    ),
                    trailing: TextButton(
                      onPressed: () {

                        // Perform action when the button is clicked
                        print('Button clicked for investor: ${investor['entityUUID']}');
                        setState(() {
                          InvestorList.investorAssetUUID = investor['entityUUID'];
                          InvestorList.investorUUID = investor['userUUID'];

                        });
                        Get.to(()=>const FamAgreement());
                        // setState(() {
                        //   showDialog(
                        //     context: context,
                        //     builder: (context) {
                        //       String dropdownValue = 'Option 1';
                        //       String contentText =
                        //           "Paragraph 1: Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                        //           "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
                        //           "Paragraph 2: Ut enim ad minim veniam, quis nostrud exercitation ullamco "
                        //           "laboris nisi ut aliquip ex ea commodo consequat. "
                        //           "Paragraph 3: Duis aute irure dolor in reprehenderit in voluptate velit esse "
                        //           "cillum dolore eu fugiat nulla pariatur.";
                        //
                        //       bool isChecked = false;
                        //
                        //       return AlertDialog(
                        //         title: Text("Investor Agreement"),
                        //         content: SingleChildScrollView(
                        //           child: Column(
                        //             crossAxisAlignment: CrossAxisAlignment.start,
                        //             children: [
                        //               Text(contentText),
                        //               SizedBox(height: 20),
                        //               Row(
                        //                 children: [
                        //                   Checkbox(
                        //                     value: isChecked,
                        //                     onChanged: (bool? value) {
                        //                       setState(() {
                        //                         isChecked = value!;
                        //                       });
                        //                     },
                        //                     activeColor: isChecked ? Colors.blue: null, // Set blue color when isChecked is true, otherwise use default color
                        //                   ),
                        //
                        //
                        //                   Text('I agree to the T&C*.'),
                        //                 ],
                        //               ),
                        //               SizedBox(height: 20),
                        //             ],
                        //           ),
                        //         ),
                        //         actions: <Widget>[
                        //           TextButton(
                        //             onPressed: () => Navigator.pop(context),
                        //             child: Text("Cancel"),
                        //           ),
                        //           TextButton(
                        //             onPressed: () {
                        //               // Add your logic for OK button here
                        //               print('Checkbox Value: $isChecked');
                        //               print('Dropdown Value: $dropdownValue');
                        //               Navigator.pop(context); // Close dialog
                        //             },
                        //             child: Text("OK"),
                        //           ),
                        //         ],
                        //       );
                        //     },
                        //
                        //   );
                        // });

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
  Future<List<Map<String, dynamic>>> fetchInvestorsDROP() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('assets')
          .where('isCompany', isEqualTo: false)
          .where('status', isEqualTo: 'approved')
          .where('userUUID', isEqualTo: PhoneOTP.useUUIDLocal)
          .get();

      List<Map<String, dynamic>> investors = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        print(data);
        if (data['isCompany'] == false) {
          investors.add({
            'location': data['location']['address1'] ?? '',
            'location1': data['location']['address2'] ?? '',
            'city': data['location']['city'] ?? '',
            'district': data['location']['district'] ?? '',
            'state': data['location']['state'] ?? '',
            'entity1': data['land']['ownername'] ?? '',
            'entity': data['land']['landsize'] ?? '',
          });
        }
      }

      // Filter out duplicate investors based on 'entity1' field
      List<Map<String, dynamic>> uniqueInvestors = [];
      Set<String> investorNames = {};

      for (var investor in investors) {
        if (!investorNames.contains(investor['entity1'])) {
          uniqueInvestors.add(investor);
          investorNames.add(investor['entity1']);
        }
      }

      return uniqueInvestors;
    } catch (error) {
      throw error;
    }
  }
  Future<List<Map<String, dynamic>>> fetchInvestors() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('assets')
          .where('isCompany', isEqualTo: true)
          .where('status', isEqualTo: 'approved')
          .get();

      List<Map<String, dynamic>> investors = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['isCompany'] == true) {
          investors.add({
            'location': data['location']['address1'] ?? '',
            'location1': data['location']['address2'] ?? '',
            'city': data['location']['city'] ?? '',
            'district': data['location']['district'] ?? '',
            'state': data['location']['state'] ?? '',
            'entity1': data['entity']['entityname'] ?? '',
            'entity': data['entity']['entityage'] ?? '',
            'entityUUID':doc.id,
            'userUUID':data['userUUID'],
          });
        }
      }

      return investors;
    } catch (error) {
      throw error;
    }
  }
}
