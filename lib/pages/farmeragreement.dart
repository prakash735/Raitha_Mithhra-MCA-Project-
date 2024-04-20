import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/phone.dart';

class FarmerAgreement extends StatefulWidget {
  const FarmerAgreement({Key? key}) : super(key: key);

  @override
  State<FarmerAgreement> createState() => _FarmerAgreementState();
}

class _FarmerAgreementState extends State<FarmerAgreement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xffC4AB62),
        title: Text('Agreements'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('userPhoneNumber', isEqualTo: PhoneOTP.userPhoneNumber)
            .get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
          }
          if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
            return Center(child: Text('Agreements not found'));
          }
          final userDoc = userSnapshot.data!.docs.first;
          final userUUID = userDoc['userUUID'];
          final defaultRole = userDoc['defaultRole'];

          // Determine the field and value to filter based on defaultRole
          String fieldToFilter = '';
          String valueToFilter = '';
          if (defaultRole == 'farmer') {
            fieldToFilter = 'farmerUUID';
            valueToFilter = userUUID;
          } else if (defaultRole == 'investor') {
            fieldToFilter = 'investorUUID';
            valueToFilter = userUUID;
          } else {
            return Center(child: Text('Invalid default role'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('agreements')
                .where(fieldToFilter, isEqualTo: valueToFilter)
                .snapshots(),
            builder: (context, agreementSnapshot) {
              if (agreementSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (agreementSnapshot.hasError) {
                return Center(child: Text('Error: ${agreementSnapshot.error}'));
              }
              if (!agreementSnapshot.hasData || agreementSnapshot.data!.docs.isEmpty) {
                return Center(child: Text('No agreements found'));
              }

              // Displaying only the first agreement found, you can modify this as needed
              final agreementDoc = agreementSnapshot.data!.docs.first;
              return Card(
                child: ListTile(
                  title: Text('Agreement UUID: ${agreementDoc['agreUUID']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${agreementDoc['date'].toDate()}'),
                      Text('Farmer AST UUID: ${agreementDoc['farmerAstUUID']}'),
                      Text('Farmer UUID: ${agreementDoc['farmerUUID']}'),
                      // Add more fields as needed
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
