// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';
import 'package:flutter_interfaces/widgets/Apptextfield.dart';

class Resetpassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ResetPasswordPage(),
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController resetCodeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  @override
  void dispose() {
    resetCodeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Color(0xFFE3AC96)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.lightBlue[200]!, // Light blue ombre
                Colors.orange[200]! // Light orange
              ],
            ),
          ),
      
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 35),
                ),
                Text(
                  "Reset code was sent to your Email. Please enter the code and create a new password",
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Reset code",
                  style: TextStyle(fontSize: 23),
                ),
                Apptextfield(
                    hintText: 'Reset Code', controller: resetCodeController),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Password",
                  style: TextStyle(fontSize: 23),
                ),
                Apptextfield(
                    hintText: "Enter your password here",
                    controller: passwordController),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Confirm Password",
                  style: TextStyle(fontSize: 23),
                ),
                Apptextfield(
                    hintText: "Re-Enter your password here",
                    controller: confirmPasswordController),
                Expanded(
                  child: Center(
                    child: Appbuttons(
                        text: "Change Password",
                        routeName: '/passwordchangedsuccessfully'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
