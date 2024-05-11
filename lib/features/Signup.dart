// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interfaces/core/vaildation.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';
import 'package:flutter_interfaces/widgets/Apptextfield.dart';
import 'package:flutter_interfaces/widgets/auth_functions.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../core/models/user_model.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  //controllers for handling user input
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController natIdController = TextEditingController();
  String? role;
  bool isManager = false;
  final key = GlobalKey<FormState>();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    natIdController.dispose();
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
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back),
          //   onPressed: () => Navigator.pop(context),
          // ),

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
          child: Stack(
            children: [
              Container(
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
              ),
              SingleChildScrollView(
              child: Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Form(
                    key: key,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Text("Hello!", style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold)),
                        Text("Create Your Account",
                            style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold)),
                        SizedBox(height: 21),
                        Center(
                            child: Apptextfield(
                                validator: validateName,
                                hintText: "Enter you First and Last Name",
                                icon: Icons.person,
                                controller: usernameController)),
                        SizedBox(height: 23),
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                          width: 400,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                              ),
                              DropdownButton<String>(
                                value: role,
                                hint: Text('Role'),
                                onChanged: (String? newValue) => setState(() => role = newValue),
                                items:
                                <String>['student', 'staff', 'teacher'].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 23),
                        Apptextfield(
                            validator: validateNumberId,
                            hintText: "Id Number",
                            icon: Icons.numbers,
                            controller: natIdController),
                        SizedBox(height: 23),
                        Center(
                            child: Apptextfield(
                                validator: validateEmail,
                                hintText: "Enter your email address",
                                icon: Icons.email_outlined,
                                controller: emailController)),
                        SizedBox(height: 23),
                        Apptextfield(
                            validator: validatePassword,
                            hintText: "Enter your password",
                            icon: Icons.lock_outline_rounded,
                            controller: passwordController),
                        SizedBox(height: 23),
                        Apptextfield(
                            validator: (x) {
                              return validateConfirmPassword(passwordController.text, x);
                            },
                            hintText: "Confirm your password",
                            icon: Icons.lock_outline_rounded,
                            controller: confirmPasswordController),
                        SizedBox(height: 17),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Are you a manager?"),
                            SizedBox(width: 100),
                            Switch(
                              value: isManager,
                              onChanged: (bool newValue) {
                                setState(() {
                                  isManager = newValue;
                                });
                              },
                              activeColor: Color(0xFF2D2689),
                            ),
                          ],
                        ),
                        SizedBox(height: 17),
                        Appbuttons(
                          text: "Signup",
                          backgroundColor: Color(0xFF2D2689),
                          onPressed: () async {
                            if (role == null) {
                              Fluttertoast.showToast(
                                msg: "Select you role",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                            }
                            if (key.currentState!.validate() && role != null) {
                              key.currentState!.save(); // form valid? save it
                              try {
                                UserCredential userCredential = await signUpWithEmailPassword(
                                  emailController.text,
                                  passwordController.text,
                                );

                                if (userCredential.user != null) {
                                  UserModel user = UserModel(
                                    firstName: usernameController.text.split(" ").first,
                                    lastName: usernameController.text.split(" ").last,
                                    role: role ?? "",
                                    email: emailController.text,
                                    password: passwordController.text,
                                    uid: FirebaseAuth.instance.currentUser!.uid,
                                    natId: natIdController.text,
                                    managerOrUser: isManager,
                                    isApproved: false,
                                  );

                                  // stores the user data in firebase firestore docs
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(FirebaseAuth.instance.currentUser!.uid)
                                      .set(user.toMap());

                                  /*if (isManager) {
                                    Navigator.pushNamed(
                                        context, '/Managerinterface');
                                  } else {*/

                                  //Removed registration collection
                                  // await FirebaseFirestore.instance
                                  //     .collection("registration")
                                  //     .doc(FirebaseAuth.instance.currentUser!.uid)
                                  //     .set({
                                  //   "uid": FirebaseAuth.instance.currentUser!.uid,
                                  //   "name": usernameController.text,
                                  //   "registered": false
                                  // });
                                  print("registration request sent successfully");

                                  Fluttertoast.showToast(
                                    msg: "Your registration request has been sent ",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                  );
                                  Future.delayed(Duration(seconds: 5), () {
                                    Fluttertoast.showToast(
                                        msg: "Your account is under review. Access will be granted upon approval.",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.yellow,
                                        textColor: Colors.black,
                                        timeInSecForIosWeb: 7);
                                  });

                                  Navigator.pushReplacementNamed(context, '/Login'); //back to login page
                                  // }

                                  emailController.clear();
                                  passwordController.clear();
                                  confirmPasswordController.clear();
                                } else {
                                  // Handle the case where the user is not returned
                                  print("Sign-up failed");

                                  Fluttertoast.showToast(
                                    msg: "Sign-up failed. Please try again later.",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                }
                              } catch (e) {
                                // Handle errors here
                                print("Error during Email/Password Sign-Up: $e");
                                // add a toast to the user later

                                if (e is FirebaseAuthException) {
                                  switch (e.code) {
                                    case 'email-already-in-use':
                                      Fluttertoast.showToast(
                                        msg: "This email is already in use. Please use a different email.",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                      break;
                                    case 'weak-password':
                                      Fluttertoast.showToast(
                                        msg: "The password is too weak. Please use a stronger password.",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                      break;
                                    case 'invalid-email':
                                      Fluttertoast.showToast(
                                        msg: "Invalid email format. Please enter a valid email address.",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                      break;
                                    case 'network-request-failed':
                                      Fluttertoast.showToast(
                                        msg: "No Internet Connection.",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                      break;
                                  // Add more cases as needed for other error codes
                                    default:
                                      Fluttertoast.showToast(
                                        msg: "Error during sign-up. Please try again later.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                  }
                                } else {
                                  // Show generic error message for other exceptions
                                  Fluttertoast.showToast(
                                    msg: "Error during sign-up. Please try again later.",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                }

                                /*   Fluttertoast.showToast(
                                  msg: "Error during sign-up. Please try again later.",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                );*/
                              }
                            }
                          },
                        ),
                        SizedBox(height: 33),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? "),
                            GestureDetector(
                              onTap: ()
                              //TODO
                              {
                                Navigator.pushReplacementNamed(context, "/Login");
                              },
                              child: Text(" Log in", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        SizedBox(height: 17),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
