import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 16, fontFamily: 'Roboto')),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/nfc.jpg',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'About Smartkids Tracker',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "SmartKids Tracker is a state-of-the-art attendance management system specifically designed to enhance the security and safety of preschool children during drop-off and pick-up times. Utilizing Near Field Communication (NFC) technology, this innovative solution ensures that only authorized parents or guardians can drop off and pick up children, providing peace of mind to both parents and educational institutions.",
              style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 24),
            const Text(
              'About Near Field Communication',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "NFC (Near Field Communication) is a wireless technology that enables short-range communication between compatible devices within a few centimeters. Operating at a frequency of 13.56 MHz, NFC allows devices to exchange information quickly and securely. It works in two modes: active, where both devices generate their own RF field, and passive, where one device generates the RF field and the other uses it to communicate. Commonly used in applications such as contactless payments, access control, and information sharing, NFC supports secure communication protocols, making it ideal for sensitive transactions and enhancing user convenience through fast and efficient data exchange.",
              style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeatureItem(icon: Icons.security, text: 'Enhanced Security'),
                FeatureItem(icon: Icons.speed, text: 'Quick Check-in/Check-out'),
                FeatureItem(icon: Icons.notifications_active, text: 'Real-time Notifications'),
                FeatureItem(icon: Icons.history, text: 'Attendance History'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'For more information or support, please contact us:',
              style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Email: shienajoy88@gmail.com',
              style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
            ),
            const Text(
              'Phone: 0915 838 6852',
              style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 14, fontFamily: 'Roboto', color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}