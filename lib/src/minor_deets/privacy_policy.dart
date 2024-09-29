import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    double baseFontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', 
          style: TextStyle(fontSize: baseFontSize * 1.2, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: baseFontSize * 1.2, 
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
          '''
Effective Date: [2024.09.05]

This Privacy Policy ("Policy") describes how we collect, use, and disclose your information in connection with your use of the [Preschool Name] NFC Attendance Tracker App ("App").

1. Information We Collect
We collect the following information when you use the App:
- Student ID
- Timestamps of arrival and departure
- Parent/guardian name
- Parent/guardian contact information

2. Use of Information
We use the information we collect to:
- Track student attendance
- Ensure the safety and security of students
- Communicate with parents/guardians about their child's attendance

3. Information Sharing
We will not share your information with any third party without your consent, except as required by law. We may share your information with:
- Authorized personnel at [Preschool Name]
- Law enforcement agencies, if required by law

4. Data Security
We take reasonable steps to protect your information from unauthorized access, disclosure, alteration, or destruction. However, no internet or electronic storage system is 100% secure.

5. Your Choices
You can access and update your information through the App settings. You can also choose to delete your account at any time.

6. Changes to this Policy
We may update this Policy from time to time. We will notify you of any changes by posting the new Policy on the App.

7. Contact Us
If you have any questions about this Policy, please contact us at:

[Shienajoy88@gmail.com

[Shiena Joy Terrobias, 
Vanessa Mae Tardecilla,
Jennie Mae Vargas,
Kriza Barrios,
Jonalyn Panaligan,
Jechnova Dela Cruz]
...
          ''',
          style: TextStyle(fontSize: baseFontSize),
            ),
            SizedBox(height: screenHeight * 0.02),
          ]
        ),
      ),
    );
  }
}