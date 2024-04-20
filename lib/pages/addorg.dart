import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

import '../auth/phone.dart';

class AddOrg extends StatefulWidget {
  const AddOrg({super.key});

  @override
  State<AddOrg> createState() => _AddOrgState();
}

class _AddOrgState extends State<AddOrg> {
  var gotUserData;
  String? Userid;


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
            Userid = doc['userUUID'] as String?; // Assign value to Userid
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
  final _formKey = GlobalKey<FormState>(); // Key for the form

  String _landSize = '';
  String _street = '';
  String _city = '';
  String _district = '';
  String _state = '';
  String _pincode = '';
  String _ownerName='';

  bool _allFieldsFilled = false; // Flag to track whether all fields are filled


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              // Handle tapping on the profile icon
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),

            ),
          ),
        ],
        title: Row(
          children: [
            // Add your logo here
            Image.asset(
              'assets/logo.png', // Replace 'assets/logo.png' with your actual logo image path
              width: 60, // Adjust the width as needed
              height: 60, // Adjust the height as needed
            ),
            // Add some spacing between logo and title
            SizedBox(width: 8),
            Text(
              'Add Organisation',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        backgroundColor: Color(0xffC4AB62), // Set the background color of the app bar
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Your image and text here
                  Image.asset(
                    'assets/filllin.png', // Replace 'assets/image.jpg' with your image path
                    width: double.infinity, // Adjust the width as needed
                    height: 200, // Adjust the height as needed
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Enter Organisation details:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Set the key for the form
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Organisation Name'),
                          onChanged: (value) {
                            setState(() {
                              _ownerName = value;
                              _checkAllFieldsFilled();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Organisation age(in years)'),
                          onChanged: (value) {
                            setState(() {
                              _landSize = value;
                              _checkAllFieldsFilled();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Street'),
                          onChanged: (value) {
                            setState(() {
                              _street = value;
                              _checkAllFieldsFilled();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'City'),
                          onChanged: (value) {
                            setState(() {
                              _city = value;
                              _checkAllFieldsFilled();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'District'),
                          onChanged: (value) {
                            setState(() {
                              _district = value;
                              _checkAllFieldsFilled();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'State'),
                          onChanged: (value) {
                            setState(() {
                              _state = value;
                              _checkAllFieldsFilled();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Pincode'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _pincode = value;
                              _checkAllFieldsFilled();
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _allFieldsFilled ? _submitForm : null,
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _allFieldsFilled ? Colors.black : Colors.grey, // Change button color based on condition
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAllFieldsFilled() {
    setState(() {
      _allFieldsFilled = _ownerName.isNotEmpty &&
          _landSize.isNotEmpty &&
          _street.isNotEmpty &&
          _city.isNotEmpty &&
          _district.isNotEmpty &&
          _state.isNotEmpty &&
          _pincode.isNotEmpty;
    });
  }
  Future<String> generateSequenceNumber() async {
    final DocumentReference document = FirebaseFirestore.instance
        .collection('assetCounter')
        .doc('counter');
    String sequenceNumber = '0';
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(document);
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      print("Here is the Data");
      print(snapshot.data());
      final currentNumber = data['numb'];
      sequenceNumber = (currentNumber + 1).toString().padLeft(2, '0');
      transaction.update(document, {'numb': currentNumber + 1});
    });
    return '$sequenceNumber';
  }
  void _submitForm() async {
    var sqeNo = await generateSequenceNumber();
    var uuid = Uuid();
    var docID = uuid.v4();
    try {
      // Add data to Firestore
      await FirebaseFirestore.instance.collection('assets').doc(docID).set({
        'assetCode': sqeNo,
        'status':'pending',
        'entity': {
          'entityage': _landSize,
          'entityname': _ownerName,
        },
        'isCompany': true,
        'land': {
          'landsize': "",
          'ownername': "",
        },
        'location': {
          'address1': _street,
          'address2': _city,
          'city': _state,
          'district': _district,
          'pincode': int.parse(_pincode),
          'state': _state,
        },
        'userUUID': Userid,
        'assetUUID': docID,
      });

      // Reset form fields after submission
      _resetForm();

      // Show a dialog box and navigate back to investor page
      _showSuccessDialogAndNavigateBack();
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

  void _showSuccessDialogAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Your organization details have been submitted successfully. Your land needs some time to get approved. Please wait for 24 hours.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close the dialogue box and navigate back
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }




  void _resetForm() {
    setState(() {
      _landSize = '';
      _street = '';
      _city = '';
      _district = '';
      _state = '';
      _pincode = '';
      _ownerName='';
      _allFieldsFilled = false;
    });
  }
}


