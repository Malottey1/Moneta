import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/register_controller.dart';

class SignUpPage extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String> fields;
  final String buttonText;
  final RegisterController controller;
  final VoidCallback? onSubtitleTap; // Added parameter

  SignUpPage({
    required this.title,
    this.subtitle,
    required this.fields,
    required this.buttonText,
    required this.controller,
    this.onSubtitleTap, // Added parameter
  });

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    _dobController = TextEditingController();
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Image.asset(
                  'assets/images/moneta-logo-2.png',
                  width: 50,
                  height: 50,
                ),
              ],
            ),
            SizedBox(height: 50),
            Text(
              widget.title,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceGrotesk',
                color: Colors.black,
              ),
            ),
            if (widget.subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: GestureDetector(
                  onTap: widget.onSubtitleTap, // Use the new parameter
                  child: Text(
                    widget.subtitle!,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'SpaceGrotesk',
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.fields.map((field) {
                if (field == 'Gender') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Gender',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      value: widget.controller.gender.isNotEmpty ? widget.controller.gender : null,
                      items: ['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          widget.controller.gender = value!;
                        });
                      },
                    ),
                  );
                } else if (field == 'Date Of Birth') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextField(
                      controller: _dobController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                          setState(() {
                            _dobController.text = formattedDate;
                            widget.controller.dateOfBirth = formattedDate;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Date Of Birth',
                        errorText: widget.controller.dateOfBirthError,
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          if (field == 'First Name') {
                            widget.controller.firstName = value;
                          } else if (field == 'Last Name') {
                            widget.controller.lastName = value;
                          } else if (field == 'Email Address') {
                            widget.controller.email = value;
                          } else if (field == 'Password') {
                            widget.controller.password = value;
                          } else if (field == 'Confirm Password') {
                            widget.controller.confirmPassword = value;
                          }
                        });
                      },
                      obscureText: field.contains('Password'),
                      decoration: InputDecoration(
                        hintText: field,
                        errorText: field == 'First Name'
                            ? widget.controller.firstNameError
                            : field == 'Last Name'
                                ? widget.controller.lastNameError
                                : field == 'Email Address'
                                    ? widget.controller.emailError
                                    : field == 'Password'
                                        ? widget.controller.passwordError
                                        : field == 'Confirm Password'
                                            ? widget.controller.confirmPasswordError
                                            : null,
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  );
                }
              }).toList(),
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  if (widget.controller.validateCurrentPage()) {
                    widget.controller.nextPage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please correct the errors in the form')),
                    );
                  }
                },
                child: Text(
                  widget.buttonText,
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}