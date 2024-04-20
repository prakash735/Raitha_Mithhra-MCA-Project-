import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/phone.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DocumentSnapshot? userData;
  List<DocumentSnapshot>? assetData;

  bool _updateSuccess = false;

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
        setState(() {
          userData = querySnapshot.docs.first;
        });
        print(userData!.data());
        getAssetData();
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
          .where('userUUID', isEqualTo: userData!['userUUID'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          assetData = querySnapshot.docs.toList();
        });
        for (DocumentSnapshot doc in assetData!) {
          print(doc.data());
        }
      } else {
        print('No data found for userUUID');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffC4AB62),
        title: Text('Settings'),
      ),
      body: userData != null
          ? ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEditableCard(
                  'Full Name',
                  userData!['fullName'],
                  'fullName',
                ),
                _buildEditableCard(
                  'Email',
                  userData!['emailID'],
                  'emailID',
                ),
                _buildEditableCard(
                  'Phone Number',
                  userData!['phoneNumber'].toString(),
                  'phoneNumber',
                  editable: false,
                ),
                _buildEditableCard(
                  'Aadhar Number',
                  userData!['adharnumber'].toString(),
                  'adharnumber',
                ),
                _buildCard(
                  'Default Role',
                  userData!['defaultRole'],
                ),
              ],
            ),
          ),
          if (assetData != null)
            ...assetData!
                .map((asset) => _buildAssetCard(asset))
                .toList(),
        ],
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEditableCard(
      String label,
      String value,
      String fieldName, {
        bool editable = true,
      }) {
    TextEditingController _controller = TextEditingController(text: value);

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    enabled: editable,
                    onChanged: (newValue) {
                      print('$fieldName: $newValue');
                      // You can update the value in Firestore here
                    },
                  ),
                ),
                if (editable)
                  IconButton(
                    icon: _updateSuccess ? Icon(Icons.check) : Icon(Icons.save),
                    onPressed: () async {
                      // Save the changes to Firestore
                      print('Saving $fieldName: ${_controller.text}');
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userData!.id)
                            .update({
                          fieldName: _controller.text,
                        });
                        setState(() {
                          _updateSuccess = true;
                        });
                      } catch (error) {
                        print('Error updating $fieldName: $error');
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String label, String value) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(value),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetCard(DocumentSnapshot asset) {
    final bool isCompany = asset['isCompany'];
    final String assetType =
    isCompany ? 'Company Asset' : 'Agriculture Land';

    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$assetType: ${asset['assetCode']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            if (isCompany)
              ..._buildEntityDetails(asset)
            else
              ..._buildLandDetails(asset),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEntityDetails(DocumentSnapshot asset) {
    return [
      Text('Entity Name: ${asset['entity']['entityname']}'),
      Text('Entity Age: ${asset['entity']['entityage']}'),
      SizedBox(height: 8),
      Text('Address:'),
      Text(' ${asset['location']['address1']}'),
      Text(' ${asset['location']['address2']}'),
      Text(' ${asset['location']['city']}'),
      Text(' ${asset['location']['district']}'),
      Text(' ${asset['location']['pincode']}'),
      Text(' ${asset['location']['state']}'),
    ];
  }

  List<Widget> _buildLandDetails(DocumentSnapshot asset) {
    return [
      Text('Land Size: ${asset['land']['landsize']}'),
      Text('Owner Name: ${asset['land']['ownername']}'),
      SizedBox(height: 8),
      Text('Address:'),
      Text(' ${asset['location']['address1']}'),
      Text(' ${asset['location']['address2']}'),
      Text(' ${asset['location']['city']}'),
      Text(' ${asset['location']['district']}'),
      Text(' Pincode: ${asset['location']['pincode'].toString()}'), // Convert pincode to string
      Text(' ${asset['location']['state']}'),
    ];
  }
}

void main() {
  runApp(MaterialApp(
    home: SettingsPage(),
  ));
}
