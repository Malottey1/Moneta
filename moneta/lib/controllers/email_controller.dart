import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class EmailController extends ChangeNotifier {
  String _email = 'malcolm.clottey@ashesi.edu.gh';
  String _subject = '';
  String _body = '';

  String get email => _email;
  String get subject => _subject;
  String get body => _body;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setSubject(String subject) {
    _subject = subject;
    notifyListeners();
  }

  void setBody(String body) {
    _body = body;
    notifyListeners();
  }

  Future<void> sendEmail() async {
    final Email email = Email(
      body: _body,
      subject: _subject,
      recipients: [_email],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      print('Error sending email: $error');
    }
  }
}