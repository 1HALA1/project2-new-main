import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interfaces/features/voice_recording/voice_recording_params.dart';
import 'package:flutter_interfaces/routes/routes_constants.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';
import 'package:flutter_interfaces/widgets/Apptextfield.dart';
import 'package:flutter_interfaces/widgets/auth_functions.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_interfaces/core/vaildation.dart';

import '../core/models/user_model.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isAccepted = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Define GlobalKey

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
              onPressed: () => Navigator.pushReplacementNamed(context, "/LandPage"),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          Text("Log in to your account", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                          SizedBox(height: 40),
                          Apptextfield(
                            validator: validateEmail, // Add validator for email
                            hintText: "Email Address",
                            icon: Icons.email_outlined,
                            borderColor: Color(0xFF2D2689),
                            controller: emailController,
                          ),
                          SizedBox(height: 15),
                          Apptextfield(
                            validator: validatePassword, // Add validator for password
                            hintText: "Password",
                            icon: Icons.lock_outline_rounded,
                            borderColor: Color(0xFF2D2689),
                            controller: passwordController,
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Forgot your password? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, "/Resetpassword");
                                },
                                child: Text("Click here", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          SizedBox(height: 25),
                          Appbuttons(
                              onPressed: () async {
                                // if (_formKey.currentState!.validate()) {
                                // Continue with sign-in process if validation passes
                                try {
                                  // Sign in with email and password
                                  UserCredential userCredential = await signInWithEmailPassword(
                                    emailController.text,
                                    passwordController.text,
                                  );

                                  // Check if the sign-in was successful
                                  if (userCredential.user != null) {
                                    // Fetch user data
                                    final userData = await FirebaseFirestore.instance
                                        .collection("users")
                                        .where("email", isEqualTo: emailController.text)
                                        .get();

                                    // User model from Firestore query
                                    final user = UserModel.fromMap(userData.docs.first.data());

                                    // Check if registration request is accepted
                                    await FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(FirebaseAuth.instance.currentUser!.uid)
                                        .get()
                                        .then((value) {
                                      final data = value.data();
                                      isAccepted = data!["is_approved"];
                                      print(isAccepted);
                                    });

                                    //bypass manger ~ no need to check recordings
                                    if (user.managerOrUser == true) {
                                      if (isAccepted == true) {
                                        Navigator.pushReplacementNamed(context, '/Managerinterface');
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Login not available. Your registration request is under review."),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                      return;
                                    }


                                    // Proceed based on registration status
                                    if (isAccepted == true) {
                                      print("_____________________");
                                      print("pass 1");
                                      var docRecordings = await FirebaseFirestore.instance
                                          .collection("recordings")
                                          .doc(FirebaseAuth.instance.currentUser!.uid)
                                          .get();

                                      if (!docRecordings.exists) {
                                        Navigator.pushReplacementNamed(context, RoutesConstants.voiceRecording,
                                            arguments: VoiceRecordParams(isFirstTime: true));
                                      } else if (docRecordings.exists && docRecordings.data()?['recordings'] != null) {
                                        final recordings = List<String>.from(docRecordings.data()!['recordings']);
                                        if (recordings.length < 4) {
                                          print("_____________________");
                                          print("pass 1");
                                          Navigator.pushReplacementNamed(context, RoutesConstants.voiceRecording,
                                              arguments: VoiceRecordParams(isFirstTime: true));
                                        } /*else if (user.managerOrUser == true) {
                                      print("_____________________");
                                      print("pass 2");
                                      Navigator.pushReplacementNamed(context, '/Managerinterface');
                                    }*/ else {
                                          print("_____________________");
                                          print("pass 3");
                                          Navigator.pushReplacementNamed(context, "/Userinterface");
                                        }
                                      }
                                      // Proceed to dashboard based on user type
                                      // emailController.clear();
                                      // passwordController.clear();
                                    } else {
                                      // Show message for registration under review
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Login not available. Your registration request is under review."),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } else {
                                    // Case where the user is not returned
                                    print("Sign-in failed");
                                  }
                                } catch (e) {
                                  // Handle any errors here .. a dialog or a toast to the user
                                  print("Error during Email/Password Sign-In: $e");

                                  Fluttertoast.showToast(
                                    msg: 'Error: $e',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                }
                              },
                              text: "Login",
                              routeName: '/Userinterface',
                              backgroundColor: Color(0xFF2D2689)),
                          SizedBox(height: 15),
                          Text("Don't have an account? "),
                          SizedBox(height: 10),
                          Appbuttons(
                              borderColor: Color(0xFF2D2689),
                              text: "Sign Up",
                              textColor: Color(0xFF2D2689),
                              routeName: '/Signup',
                              backgroundColor: Colors.white),
                         // SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

          ),
        ));
  }
}
