import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/email_controller.dart';

class ComposeEmailWidget extends StatelessWidget {
  final String email;

  ComposeEmailWidget({required this.email});

  @override
  Widget build(BuildContext context) {
    final emailController = Provider.of<EmailController>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,  // Reduce the vertical size
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Email',
            labelStyle: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14),
            hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14),
          ),
          controller: TextEditingController(text: email),
          readOnly: true,
        ),
        SizedBox(height: 8.0),  // Add some spacing
        TextField(
          decoration: InputDecoration(
            labelText: 'Subject',
            hintText: 'Subject',
            labelStyle: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14),
            hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14),
          ),
          onChanged: (value) => emailController.setSubject(value),
        ),
        SizedBox(height: 8.0),  // Add some spacing
        TextField(
          decoration: InputDecoration(
            labelText: 'Body',
            hintText: 'Body',
            labelStyle: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14),
            hintStyle: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14),
          ),
          maxLines: 3,  // Limit the max lines
          onChanged: (value) => emailController.setBody(value),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            emailController.setEmail(email);
            await emailController.sendEmail();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,  // Use the app's primary color
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: TextStyle(fontFamily: 'SpaceGrotesk', fontSize: 14),
          ),
          child: const Text('Open Email App',style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}