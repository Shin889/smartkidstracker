import 'package:flutter/material.dart';

class UserAgreement extends StatelessWidget {
  const UserAgreement({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    double baseFontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text('User Services Agreement', 
          style: TextStyle(fontSize: baseFontSize * 1.2, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Services Agreement',
              style: TextStyle(
                fontSize: baseFontSize * 1.2, 
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              '''
You are welcome to sign this User Service Agreement (hereinafter referred to as "this Agreement") with Smartkids Tracker and use our platform services! In order to protect your own rights and interests, it is recommended that you carefully read the specific expressions of each clause. Before you click to agree to this agreement in the application registration process, you should read carefully and fully understand the contents of each clause, especially the clauses that exempt or limit liability will be underlined in bold and you should read them carefully. If you have any questions about the agreement, you can consult our platform customer service. When you fill in the information as prompted on the signin page, read and agree to this agreement, and complete all the registration procedures, it means that you have fully read, understood and accepted the entire contents of this agreement, and have reached an agreement with us to become a Smartkids Tracker user. During the process of reading this agreement, if you do not agree with this agreement or any of its terms, you should stop the registration process.  

Definition
This Service is a security-focused attendance tracking system designed specifically for preschool environments. The Service utilizes Near Field Communication (NFC) technology to streamline the attendance tracking process for both parents and preschool staff.

Scope of the Agreement
2.1 Subject of the Contract
This agreement is jointly concluded by you and our platform operator, and this agreement has contractual effect between you and our platform operator. Our platform operators refer to the legal entities that operate our platform, and you can determine our entities that perform contracts with you according to the terms defined above (see 1). Under this agreement, the operator of our platform will perform this agreement and provide services to you together with you. The change of our platform operator will not will affect your rights under this agreement. Our platform operator may also be added due to the provision of new our platform services. If you use the newly added our platform services, it is deemed that you agree to the newly added our platform operator to perform this agreement with you.. In the event of a dispute, you can determine the subject of the contract with you and the counterparty to the dispute based on the specific services you use and the specific behavior object that affects your rights and interests.
2.2 Supplementary Agreement 
Due to the rapid development of the Internet industry, the terms set out in this agreement signed by you and us cannot fully list and cover all the rights and obligations between you and us, and the existing agreements cannot guarantee that they fully meet the needs of future development. Therefore, our platform's "Privacy Policy" and our platform's rules are supplementary agreements to this agreement, which are inseparable from this agreement and have the same legal effect. If you use our platform services, it is deemed that you agree to the above supplementary agreement.
2.3 Changes to the User Service Agreement 
Our platform can update the user service agreement, privacy policy and relevant platform rules (collectively referred to as "user agreement") on our platform. At that time, the update of the agreement will be notified through system prompts, information push and/or the contact information you leave on our platform. and remind you to pay attention. After the user agreement is changed, if you continue to use our platform services, it means that you agree to accept our updated user agreement. If you do not agree with the changed user agreement, please stop using our platform product and service.

Account registration and use
3.1 User qualifications
You confirm that before you start to use/register to use our platform services, you should have the civil capacity suitable for your behavior.

3.2 Registration Information Management
3.2.1 True and legal
When using our platform services, you should provide your information accurately and completely according to the prompts on our platform page, so that we can contact you when necessary. You understand and agree that you are obligated to maintain the authenticity and validity of the information you provide. The account name, nickname and avatar picture you set must not violate laws and regulations and our platform rules on account name management, otherwise we may suspend the use of your account name or Processing such as cancellation and reporting to the competent authority.
You understand and promise that your account registration information shall not contain illegal or bad information, and there shall be no fraudulent use, affiliated organizations or social celebrities, and you shall abide by laws and regulations, socialist system in the process of account registration, national interests, legitimate rights and interests of citizens, public order, social morality and information authenticity.
3.2.2 Update maintenance
You should update the information you provide in a timely manner. In the event that the law clearly requires us to verify the information of some users, we will check and verify your information from time to time in accordance with the law. You should cooperate with providing the latest, true, and complete information. If we fail to contact you according to the information you provided the last time, you fail to provide information in a timely manner in accordance with our requirements, or the information you provide is obviously false, you will be liable for any damages caused to you, others and us. All losses and adverse consequences. Our platform assumes corresponding responsibilities under the circumstances clearly stipulated by law.
3.3 Account Security Specifications
Your account is set up for you and kept by you. Our platform will not actively ask you to provide your account password at any time. It is recommended that you keep your account safe and ensure that you log out at the end of each online period and leave our platform in the correct steps.
Account losses and consequences caused by your active disclosure or attack or fraud by others, both parties shall bear the risks and responsibilities according to the law. Our platform assumes corresponding responsibilities under the circumstances clearly stipulated by law.
Your account is for your own use only and may not be lent or shared for others to use. When your account is used without authorization, you should notify our platform immediately, otherwise the unauthorized use will be regarded as your own behavior, and you will be responsible for all the resulting losses and consequences.
Except for our fault, you shall be responsible for all behavior results under your account (including but not limited to signing various agreements online, publishing information, purchasing goods and services, and disclosing information, etc.).
If you find any unauthorized use of your account to log in to our platform or other situations that may cause your account to be stolen or lost, it is recommended that you notify us immediately. You understand that it will take reasonable time for us to take action on any of your requests, and we are not responsible for the consequences that have occurred prior to taking action, except for our statutory fault.

Prohibited conduct
You understand and warrant that you will not do the following prohibited acts in relation to our platform services, nor allow anyone to use your account to do the following:
1) When registering an account or using our platform services, impersonating another person, or falsely claiming to be connected to any person or entity (including setting a false account name or accessing another user's account);
2) Use or exploit our intellectual property rights (including our trademarks, brands, logos, any other proprietary data, or the layout or design of any web pages), or otherwise infringe any of our intellectual property rights (including attempting to exploit our platform client or the software used for reverse engineering);
3) By using any automated programs, software, engines, web crawlers, web analysis tools, data mining tools or similar tools to access our platform services, collect or process content provided through our platform services;
4) Participate in any "frame", "mirror" or other technology intended to mimic the appearance and functionality of our Platform Services;
5) interfere or attempt to interfere with any user or any other party's access to our platform services;
6) Intentionally disseminate viruses, network worms, Trojan horses, corrupted files or other malicious code or items;
7) Share or publish personally identifiable information of others without their express consent;
8) Explore or test whether our platform services, systems or other users' systems are vulnerable to intrusion attacks, or otherwise circumvent (or attempt to circumvent) any security features of our platform services, systems or other users' systems;
9) Decode, decompile or reverse engineer the software used in our platform services, or attempt to do the above;
10) Willful or unintentional violation of any relevant Philippine laws, regulations, rules, ordinances and other legally binding norms.
11) Modify or tamper with our platform services and related functions.

Entire Agreement
This Agreement constitutes the entire agreement between you and us regarding your use of the App and supersedes all prior or contemporaneous communications and proposals, whether oral or written.
              ''',
              style: TextStyle(fontSize: baseFontSize),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}