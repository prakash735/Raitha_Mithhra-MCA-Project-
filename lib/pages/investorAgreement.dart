import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auth/phone.dart';

class InvestorAgreement extends StatefulWidget {
  const InvestorAgreement({Key? key}) : super(key: key);

  @override
  State<InvestorAgreement> createState() => _InvestorAgreementState();
}

class _InvestorAgreementState extends State<InvestorAgreement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffC4AB62),
        title: Text('Investor Agreement'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('agreements')
            .where('phoneNumber', isEqualTo: int.parse(PhoneOTP.userPhoneNumber))
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          int totalAgreements = snapshot.data!.docs.length;

          if (totalAgreements == 0) {
            return Center(child: Text('No agreements found for the user.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Total Number of Agreements: $totalAgreements'),
              ),
              Expanded(
                child: ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    String agreUUID = data['agreUUID'];
                    Timestamp agreementDate = data['date'];
                    DateTime expireDate = agreementDate.toDate().add(Duration(days: 152)); // Add 152 days (approximately 5 months) to the agreement date
                    return Card(
                      margin: EdgeInsets.all(16),
                      child: ListTile(
                        title: Text('Agreement UUID: $agreUUID'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${_formatDate(agreementDate.toDate())}'),
                            Text('Expiration Date: ${_formatDate(expireDate)}'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date); // Format date
  }
}
