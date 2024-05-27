import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raithamithra/pages/farmerPage.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/widgets.dart' as pw;
import '../auth/phone.dart';
import 'farmerlist.dart';
import 'iagreement.dart';
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
  String? _pdfPath;
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
          'phoneNumber': int.parse(PhoneOTP.userPhoneNumber),
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

      await _generatePDF();

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
  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: _buildContent(),
          );
        },
      ),
    );

    // Save the PDF to disk
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/agreement.pdf');
    await file.writeAsBytes(await pdf.save());

    // Update the _pdfPath variable
    setState(() {
      _pdfPath = file.path;
    });

    // Show the PDF viewer dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('PDF Generated'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Would you like to download the PDF?'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      _openPDF(_pdfPath!); // Open the PDF viewer
                    },
                    child: Text('View PDF'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog
                      await _downloadPDF(file.path); // Download the PDF
                    },
                    child: Text('Download PDF'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  List<pw.Widget> _buildContent() {
    return [
      pw.Text('Agreement Between Farmer and Investor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
      pw.SizedBox(height: 20),
      pw.Text('Date: ${DateTime.now()}', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 20),
      pw.Text('Parties:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Text('This Agreement is entered into on ${DateTime.now()} between:', style: pw.TextStyle(fontSize: 16)),
      pw.Text('Farmer\'s Name: [Farmer\'s Full Name]', style: pw.TextStyle(fontSize: 16)),
      pw.Text('Address: [Farmer\'s Address]', style: pw.TextStyle(fontSize: 16)),
      pw.Text('AND', style: pw.TextStyle(fontSize: 16)),
      pw.Text('Investor\'s Name: [Investor\'s Full Name]', style: pw.TextStyle(fontSize: 16)),
      pw.Text('Address: [Investor\'s Address]', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 20),
      pw.Text('Background:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Text('The Farmer and Investor desire to enter into an agreement whereby the Farmer agrees to grow a specific crop or crops with the financial support of the Investor. This agreement outlines the terms and conditions governing their relationship.', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 20),
      pw.Text('Terms and Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Text('Crop to be Grown:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Text('The Farmer agrees to grow the following crop(s): [Specify Crop(s)] on the agricultural land located at [Location] for the purpose of commercial production.', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 10),
      pw.Text('Investment:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Text('The Investor agrees to provide financial support for the cultivation of the specified crop(s) as outlined in Schedule A attached hereto.', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 10),
      pw.Text('Responsibilities of the Farmer:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Text('Utilize the funds provided by the Investor solely for the cultivation of the specified crop(s) in accordance with best agricultural practices.', style: pw.TextStyle(fontSize: 16)),
      pw.Text('Maintain the agricultural land in good condition and ensure proper irrigation, fertilization, and pest control measures are undertaken.', style: pw.TextStyle(fontSize: 16)),
      pw.Text('Provide regular updates to the Investor on the progress of the crop cultivation, including any challenges faced.', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 10),
      pw.Text('Responsibilities of the Investor:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Text('Provide the necessary funds to the Farmer as outlined in Schedule A attached hereto.', style: pw.TextStyle(fontSize: 16)),
      pw.Text('Have the right to inspect the agricultural land and crops during reasonable times upon prior notice to the Farmer.', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 10),
      pw.Text('Profit Sharing:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Text('Any profits generated from the sale of the harvested crop(s) shall be shared between the Farmer and the Investor as per the terms agreed upon in Schedule A.', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 10),
      pw.Text('Duration:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Text('This Agreement shall commence on [Start Date] and continue until the harvest of the specified crop(s) or termination by either party as per the terms herein.', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 10),
      pw.Text('Termination:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Text('Either party may terminate this Agreement upon written notice to the other party in case of a material breach of any terms herein or upon mutual agreement.', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 10),
      pw.Text('Governing Law:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.Text('This Agreement shall be governed by and construed in accordance with the laws of [Jurisdiction].', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 20),
      pw.Text('In Witness Whereof, the parties hereto have executed this Agreement as of the date first above written.', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 20),
      pw.Text('Farmer:', style: pw.TextStyle(fontSize: 16)),
      pw.Text('[Signature]________________________', style: pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 20),
      pw.Text('Investor:', style: pw.TextStyle(fontSize: 16)),
      pw.Text('[Signature]________________________', style: pw.TextStyle(fontSize: 16)),
    ];
  }

  void _openPDF(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PDFViewerScreen(pdfPath: path)), // Navigate to PDF viewer screen
    );
  }

  Future<void> _downloadPDF(String filePath) async {
    final output = await getExternalStorageDirectory();
    final file = File('${output?.path}/agreement.pdf');
    await file.writeAsBytes(await File(filePath).readAsBytes());

    Fluttertoast.showToast(
      msg: "PDF Downloaded!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
class PDFViewerScreen extends StatelessWidget {
  final String? pdfPath;

  PDFViewerScreen({Key? key, this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Add a WillPopScope widget to intercept the back button press
      onWillPop: () async {
        // Navigate to InvestorHome when the back button is pressed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FarmerHome()),
        );
        return false; // Return false to prevent default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffC4AB62),
          title: Text('Agreement'),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                if (pdfPath != null) {
                  // Perform saving action
                  _savePDF(pdfPath!);
                }
              },
            ),
          ],
        ),
        body: pdfPath != null ? PDFView(filePath: pdfPath!) : Center(child: Text('PDF path is null')),
      ),
    );
  }

  Future<void> _savePDF(String path) async {
    final outputDirectory = await getExternalStorageDirectory();
    final outputDirectoryPath = outputDirectory?.path;
    final outputDirectoryExists = await Directory(outputDirectoryPath!).exists();

    if (!outputDirectoryExists) {
      await Directory(outputDirectoryPath).create(recursive: true);
    }

    final file = File('$outputDirectoryPath/agreement.pdf');
    await file.writeAsBytes(await File(path).readAsBytes());

    Fluttertoast.showToast(
      msg: "PDF Saved!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

}
void main() {
  runApp(MaterialApp(
    home: FamAgreement(),
  ));
}
