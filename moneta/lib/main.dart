import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'providers/user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure the binding is initialized
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(0, '', '', ''),
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Remove the debug banner
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/moneta-logo-2.png',
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
            ),
            SizedBox(height: 50.0),
            Container(
              width: 100, // Adjust the width as needed
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey,
                color: Colors.black,
                minHeight: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}