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
                Placeholder(), // Approved Page
                Placeholder(), // Canceled Page
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
      future: fetchInvestors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
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
                        // Implement approve functionality
                        print('Approve button pressed for ${investor['entity1']}');
                      },
                      child: Text('Approve'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Implement cancel functionality
                        print('Cancel button pressed for ${investor['entity1']}');
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }


  Future<List<Map<String, dynamic>>> fetchInvestors() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('assets')
          .where('isCompany', isEqualTo: false)
          .where('status', isEqualTo: 'pending')
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

      return investors;
    } catch (error) {
      throw error;
    }
  }
}



