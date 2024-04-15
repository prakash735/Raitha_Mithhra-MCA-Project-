import 'package:flutter/material.dart';

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
                Placeholder(), // Pending Page
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
}

void main() {
  runApp(MaterialApp(
    home: InvestorStatus(),
  ));
}
