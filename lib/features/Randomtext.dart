import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';

class Randomtext extends StatefulWidget {
  const Randomtext({super.key});

  @override
  RandomTextState createState() => RandomTextState();
}

class RandomTextState extends State<Randomtext> {
  final RandomTextManager _manager = RandomTextManager();
  final TextEditingController _textController = TextEditingController();
  bool _isAddingText = false;

  @override
  void initState() {
    super.initState();
    _manager.loadTexts().then((_) {
      //load existing texts
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0.0, // Remove shadow
        iconTheme: IconThemeData(color: Color (0xFFE3AC96)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      //a ListView of random texts frm FB using manger
      //each text is displayed as a ListTile
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
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _manager.randomTexts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_manager.randomTexts[index]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Appbuttons(
                                text: 'Edit',
                                width: 110,
                                height: 30,
                                onPressed: () {
                                  // Wrap the call inside an anonymous function
                                  _showEditDialog(index, _manager.randomTexts[index]);
                                },
                                backgroundColor: Colors.green,
                              ),
                              const SizedBox(width: 8.0),
                              Appbuttons(
                                text: 'Delete',
                                width: 110,
                                height: 30,
                                onPressed: () {
                                  // Wrap the call inside an anonymous function
                                  _manager.deleteRandomText(index);
                                  setState(() {}); //to update the UI
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isAddingText)
                      Appbuttons(
                        text: 'Add Random Text',
                        width: 200,
                        height: 40,
                        onPressed: () {
                          setState(() {
                            _isAddingText = true;
                          });
                        },
                      ),
                    if (_isAddingText) // adding a new random text
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Enter Random Text',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                _manager.addRandomText(_textController.text);
                                _textController.clear();

                                setState(() {
                                  _isAddingText = false; // back to false
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(int index, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Text'),
          content: TextField(
            controller: TextEditingController(text: text),
            onChanged: (value) {
              text = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _manager.updateRandomText(index, text);
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class RandomTextManager {
  List<String> _randomTexts = [];

  List<String> get randomTexts => _randomTexts;

  void updateRandomText(int index, String newText) {
    if (index >= 0 && index < _randomTexts.length) {
      _randomTexts[index] = newText; // Update the local list

      // Update Firestore
      var uid = FirebaseAuth.instance.currentUser!.uid;
      FirebaseFirestore.instance.collection("random_text").doc(uid).set({"texts": _randomTexts});
    }
  }

  //retrieves the list of random texts from FB
  Future<void> loadTexts() async {
    var doc =
        await FirebaseFirestore.instance.collection("random_text").doc(FirebaseAuth.instance.currentUser!.uid).get();

    if (!doc.exists) {
      _randomTexts = [];
    }

    _randomTexts = List<String>.from(doc.data()?['texts'] ?? []);
  }

  Future<void> addRandomText(String text) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    var docRef = FirebaseFirestore.instance.collection("random_text").doc(uid);

    _randomTexts.add(text);

    await docRef.set({"texts": _randomTexts});
  }

  Future<void> deleteRandomText(int index) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    var docRef = FirebaseFirestore.instance.collection("random_text").doc(uid);

    if (index >= 0 && index < _randomTexts.length) {
      _randomTexts.removeAt(index);

      await docRef.set({"texts": _randomTexts});
    }
  }
}
