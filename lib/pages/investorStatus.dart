import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvestorStatus extends StatefulWidget {
  const InvestorStatus({Key? key}) : super(key: key);

  @override
  State<InvestorStatus> createState() => _InvestorStatusState();
}

class _InvestorStatusState extends State<InvestorStatus> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investor Status'),
        backgroundColor: Color(0xffC4AB62),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              children: [
                _buildPendingPage(), // Pending Page
                _buildApprovedPage(), // Approved Page
                _buildCanceledPage(), // Canceled Page
              ],
            ),
          ),
          Container(
            color: Color(0xffC4AB62),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBottomNavItem('Pending', 0),
                _buildBottomNavItem('Approved', 1),
                _buildBottomNavItem('Canceled', 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(String title, int index) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _currentPageIndex == index ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _currentPageIndex == index ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchInvestorData(true, 'pending'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // Display fetched details here
          return _buildList(snapshot, showButtons: true);
        }
      },
    );
  }

  Widget _buildApprovedPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchInvestorData(true, 'approved'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // Display fetched details here
          return _buildList(snapshot, showButtons: false);
        }
      },
    );
  }

  Widget _buildCanceledPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchInvestorData(true, 'canceled'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // Display fetched details here
          return _buildList(snapshot, showButtons: false);
        }
      },
    );
  }

  Widget _buildList(AsyncSnapshot<List<Map<String, dynamic>>> snapshot, {required bool showButtons}) {
    if (snapshot.data!.isEmpty) {
      return Center(child: Text('No data available for canceled status.'));
    } else {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          var data = snapshot.data![index];
          return ListTile(
            title: Text(data['entity1'].toString()),
            subtitle: Text(data['entity'].toString()),
            trailing: showButtons
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _updateStatus(data['assetUUID'], 'approved');
                  },
                  child: Text('Approve'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _updateStatus(data['assetUUID'], 'canceled');
                  },
                  child: Text('Cancel'),
                ),
              ],
            )
                : null,
          );
        },
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchInvestorData(bool isCompany, String status) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('assets')
          .where('status', isEqualTo: status)
          .where('isCompany', isEqualTo: isCompany)
          .get();

      List<Map<String, dynamic>> data = [];

      querySnapshot.docs.forEach((doc) {
        var docData = doc.data() as Map<String, dynamic>;
        data.add({
          'entity1': docData['entity']['entityname'] ?? '',
          'entity': docData['entity']['entityage'] ?? '',
          'assetUUID': doc.id, // Added assetUUID for update
        });
      });

      return data;
    } catch (error) {
      throw error;
    }
  }

  Future<void> _updateStatus(String assetUUID, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('assets')
          .doc(assetUUID)
          .update({'status': status});
    } catch (error) {
      print('Error updating status: $error');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: InvestorStatus(),
  ));
}
