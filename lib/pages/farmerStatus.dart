import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerStatus extends StatefulWidget {
  const FarmerStatus({Key? key}) : super(key: key);

  @override
  State<FarmerStatus> createState() => _FarmerStatusState();
}

class _FarmerStatusState extends State<FarmerStatus> {
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
        title: Text('Farmer Status'),
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
      future: fetchFarmer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          if (snapshot.data!.isEmpty) {
            return Center(child: Text('No data available for pending status.'));
          } else {
            // Display fetched details here
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var investor = snapshot.data![index];
                return ListTile(
                  title: Text(investor['entity1'].toString()),
                  subtitle: Text(investor['entity'].toString()),
                  // Customize the display according to your requirements
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _updateStatus(investor['assetUUID'], 'approved');
                        },
                        child: Text('Approve'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _updateStatus(investor['assetUUID'], 'canceled');
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  Widget _buildApprovedPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchApprovedData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          if (snapshot.data!.isEmpty) {
            return Center(child: Text('No data available for approved status.'));
          } else {
            // Display fetched details here
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var data = snapshot.data![index];
                return ListTile(
                  title: Text(data['entity1'].toString()),
                  subtitle: Text(data['entity'].toString()),
                  // Customize the display according to your requirements
                );
              },
            );
          }
        }
      },
    );
  }

  Widget _buildCanceledPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchCanceledData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // Display fetched details here
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
                  // Customize the display according to your requirements
                );
              },
            );
          }
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchFarmer() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('assets')
          .where('status', isEqualTo: 'pending')
          .where('isCompany', isEqualTo: false) // Filter for isCompany false
          .get();

      List<Map<String, dynamic>> investors = [];

      querySnapshot.docs.forEach((doc) {
        var data = doc.data() as Map<String, dynamic>;
        investors.add({
          'location': data['location']['address1'] ?? '',
          'location1': data['location']['address2'] ?? '',
          'city': data['location']['city'] ?? '',
          'district': data['location']['district'] ?? '',
          'state': data['location']['state'] ?? '',
          'entity1': data['land']['ownername'] ?? '',
          'entity': data['land']['landsize'] ?? '',
          'assetUUID': doc.id, // Added assetUUID for update
        });
      });

      return investors;
    } catch (error) {
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> fetchApprovedData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('assets')
          .where('status', isEqualTo: 'approved')
          .where('isCompany', isEqualTo: false)
          .get();

      List<Map<String, dynamic>> approvedData = [];

      querySnapshot.docs.forEach((doc) {
        var data = doc.data() as Map<String, dynamic>;
        approvedData.add({
          'entity1': data['land']['ownername'] ?? '',
          'entity': data['land']['landsize'] ?? '',
        });
      });

      return approvedData;
    } catch (error) {
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCanceledData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('assets')
          .where('status', isEqualTo: 'canceled')
          .where('isCompany', isEqualTo: false)
          .get();

      List<Map<String, dynamic>> canceledData = [];

      querySnapshot.docs.forEach((doc) {
        var data = doc.data() as Map<String, dynamic>;
        canceledData.add({
          'entity1': data['land']['ownername'] ?? '',
          'entity': data['land']['landsize'] ?? '',
        });
      });

      return canceledData;
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
