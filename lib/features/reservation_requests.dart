import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interfaces/core/models/user_model.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';

class RegistrationRequestsPage extends StatefulWidget {
  const RegistrationRequestsPage({Key? key}) : super(key: key);

  @override
  State<RegistrationRequestsPage> createState() => _RegistrationRequestsPageState();
}

class _RegistrationRequestsPageState extends State<RegistrationRequestsPage> {
  List<UserModel> _users = [];

  Future<void> acceptRegistration(String? id) async {
    if (id == null) {
      print("Id doesn't exist"); // no invalid or missing ID
      return;
    }

    final approvedUser = _users.firstWhere((user) => user.uid == id);
    final updatedUser = approvedUser.copyWith(isApproved: true);

    await FirebaseFirestore.instance.collection("users").doc(id).set(updatedUser.toMap()).then((value) {
      setState(() {
        _users.removeWhere((user) => user.uid == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Accepted successfully"),
        backgroundColor: Colors.green,
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $error"),
        backgroundColor: Colors.red,
      ));
    });

    await sendEmail(id);
  }

  Future<void> sendEmail(String id) async {
    const email = "labguard.app@outlook.com";
    const password = "12345-Ab";

    final smtpServer = hotmail(email, password);
    final receiver = await getUserEmailById(id);

    final message = Message()
      ..from = const Address(email, 'Lab Guard Application')
      ..recipients.add(receiver)
      ..subject = 'Welcome to Lab Guard!'
      ..text = 'Dear User,\n\nThank you for registering with Lab Guard! We are excited to welcome you to our app.\n\nYour registration request has been approved, and you can now access your account on the Lab Guard application. Simply log in using your credentials to get started.\n\nIf you have any questions or need assistance, feel free to reach out to our support team at labguard.app@outlook.com. We are here to help!\n\nBest regards,\nThe Lab Guard Team';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e.message);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Future<String> getUserEmailById(String uid) async {
    final response = await FirebaseFirestore.instance.collection("users").where("uid", isEqualTo: uid).get();

    final userData = response.docs.first.data();
    return userData["email"];
  }

  Future<void> deleteRequest(String id) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(id).delete();
      setState(() {
        _users.removeWhere((user) => user.uid == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Request deleted successfully"),
        backgroundColor: Colors.red,
      ));
      // Fetch updated list of users after deleting the request
      await getNotApprovedUsers();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $error"),
        backgroundColor: Colors.red,
      ));
    }
  }


  Future<void> deleteRegistration(String? id) async {
    if (id == null) {
      print("Id doesn't exist"); // no invalid or missing ID
      return;
    }

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this request?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteRequest(id); // Call deleteRequest function
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> getNotApprovedUsers() async {
    await FirebaseFirestore.instance.collection("users").where("is_approved", isEqualTo: false).get().then((value) {
      setState(() {
        _users = value.docs.map((user) => UserModel.fromMap(user.data())).toList();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getNotApprovedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Registrations'),
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

          child: ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${_users[index].firstName} ${_users[index].lastName}"), // Show both first and last names
                    Text("Role: ${_users[index].role}"),
                    Text("ID: ${_users[index].natId}"),
                    Text("Manager? ${_users[index].managerOrUser ? 'Yes' : 'No'}"), // Display 'Yes' if true, 'No' if false
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Appbuttons(
                          text: 'accept',
                          width: 110,
                          height: 30,
                          onPressed: () {
                            acceptRegistration(_users[index].uid);
                          },
                          backgroundColor: Colors.green,
                        ),
                        const SizedBox(width: 10),
                        Appbuttons(
                          text: 'delete',
                          width: 110,
                          height: 30,
                          onPressed: () {
                            deleteRegistration(_users[index].uid);
                          },
                          backgroundColor: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
