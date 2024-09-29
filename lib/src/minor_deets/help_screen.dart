import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text('Help & Support'),
            backgroundColor: Colors.transparent, 
            elevation: 0, 
          ),
        ),
      ),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Here you can find answers to frequently asked questions (FAQs), get in touch with our support team, or find troubleshooting tips.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'How to Use the App for Attendance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'For parents or guardians and staff or teachers:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '1. Let staff or teacher scan your child\'s NFC sticker.',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                '2. Wait for a confirmation notification.',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                '3. View the attendance report in real time.',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                '4. Click "Generate Report" if you want to view historical attendance records.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'NFC Connection Problem',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. System Setting > Connected devices or More Connections > Connection preferences > NFC',
                    style: TextStyle(fontSize: 16),
                  ),
                  Image.asset(
                    'assets/images/help1.png',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '2. Tap on toggle to enable NFC',
                    style: TextStyle(fontSize: 16),
                  ),
                  Image.asset(
                    'assets/images/help2.png',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Action for contacting support
                },
                child: const Text('Contact Support'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
