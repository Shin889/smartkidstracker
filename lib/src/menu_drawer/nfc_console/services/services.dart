import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  final String smtpUsername;
  final String smtpPassword;

  EmailService({required this.smtpUsername, required this.smtpPassword});

  Future<void> sendAttendanceEmail(String name, String action) async {
    final smtpServer = gmail(smtpUsername, smtpPassword);
    final message = Message()
      ..from = Address(smtpUsername, 'Smartkids Tracker')
      ..recipients.add('shienajoy88@gmail.com') 
      ..subject = 'Attendance Update for $name'
      ..text = '$name has $action';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: $sendReport');
    } on MailerException catch (e) {
      print('Message not sent. $e');
    }
  }
}
