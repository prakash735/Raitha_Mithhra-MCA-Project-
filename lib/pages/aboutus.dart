import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffC4AB62),
        title: Text('About Us'),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // Image
          Container(
            padding: EdgeInsets.only(bottom: 16.0),
            alignment: Alignment.center,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/text_logo.png',
                width: 300,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Introduction Card
          _buildCard(
            title: 'Introduction',
            content: Text(
              "Introducing Raitha Mithra, the game-changer in agricultural commerce, where farmers and investors unite under one revolutionary mobile app. Our mission? To disrupt the traditional agricultural trade model by enabling direct transactions that cut out the middlemen, guaranteeing fair prices and unrivaled transparency for all involved.",
            ),
          ),
          // Catalyst for Change Card
          _buildCard(
            title: 'Catalyst for Change',
            content: Text(
              "But wait, there's more! Raitha Mithra isn't just another trading platform; it's a catalyst for change. For investors, it's an invitation to explore a world of opportunity, where they can browse through a diverse array of farming projects and invest directly in the ones that resonate with their values and passions. Whether it's supporting organic farms or backing innovative agricultural practices, investors have the power to shape the future of farming while reaping potentially lucrative returns on their investments.",
            ),
          ),
          // Lifeline for Farmers Card
          _buildCard(
            title: 'Lifeline for Farmers',
            content: Text(
              "And for farmers, Raitha Mithra is a lifeline. No longer bound by the limitations of traditional markets, they can now showcase their produce to a global audience, securing fair prices and accessing much-needed capital to fuel their agricultural endeavors. With the touch of a button, farmers can connect with investors who share their vision for sustainable, ethical farming, opening doors to new opportunities and partnerships that were once unimaginable.",
            ),
          ),
          // Bridge the Gap Card
          _buildCard(
            title: 'Bridge the Gap',
            content: Text(
              "But perhaps the most remarkable aspect of Raitha Mithra is its potential to bridge the gap between farmers and investors, fostering collaboration and mutual growth. By leveraging the power of mobile technology, we're not just facilitating transactions; we're building a community—a community dedicated to creating a more equitable and sustainable future for agriculture.",
            ),
          ),
          // Join Us Card
          _buildCard(
            title: 'Join Us',
            content: Text(
              "So join us as we embark on this journey of innovation and empowerment. With Raitha Mithra, the future of agriculture is brighter than ever before, and the possibilities are limitless. Let's revolutionize the way we think about farming, one transaction at a time.",
            ),
          ),
          // Team Section
          _buildTeamMembers(context),
          SizedBox(height: 16.0), // Add spacing after the last card
          // Call to Action Button
          ElevatedButton(
            onPressed: () {
              // Implement your action here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffC4AB62), // Background color of button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text('Join Us'), // Add text to the button
            ),
          ),
        ],
      ),
    );
  }

  // Function to build team members section
  Widget _buildTeamMembers(BuildContext context) {
    // You can customize this function to load team members dynamically
    // For now, I'll just hard-code two team members
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Raitha Mithra Team',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.0),
        _buildTeamMember(
          name: 'Prakash R',
          position: 'CEO',
          imagePath: 'assets/prakash.jpg',
          description: 'Experienced leader with a passion for agriculture.',
        ),
        SizedBox(height: 8.0),
        _buildTeamMember(
          name: 'Thejas Prasad A H',
          position: 'CTO',
          imagePath: 'assets/thejas.JPG',
          description: 'Tech enthusiast dedicated to innovation in farming.',
        ),
      ],
    );
  }

  // Function to build a single team member card
  Widget _buildTeamMember({
    required String name,
    required String position,
    required String imagePath,
    required String description,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 80.0,
              backgroundImage: AssetImage(imagePath),
            ),
            SizedBox(height: 8.0),
            Text(
              name,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              position,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build a card with title and content
  Widget _buildCard({required String title, required Widget content}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.0),
            content,
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AboutUs(),
  ));
}
