import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_interfaces/features/voice_recording/resources/sentences.dart';
import 'package:flutter_interfaces/features/voice_recording/voice_recording_params.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class VoiceRecordPage extends StatefulWidget {
  final VoiceRecordParams params;
  const VoiceRecordPage({Key? key, required this.params}) : super(key: key);

  @override
  VoiceRecordPageState createState() => VoiceRecordPageState();
}

class VoiceRecordPageState extends State<VoiceRecordPage> with TickerProviderStateMixin {
  bool _isRecording = false;
  List<String> _recordings = [];
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _player = AudioPlayer();
  late final AnimationController _animationController;
  final List<String> _sentences = Sentences.sentences;
  var sentenceCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
    _loadUserData(); // Call the function to load user data
    _initRecorder();
    _animationController = AnimationController(vsync: this);
    // Display a message informing the user that 4 recordings are needed
    showRecordingLimitMessage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar:
           AppBar(
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Record Your Voice", style: TextStyle(fontSize: 32)),
                const SizedBox(height: 16),
                const Text("Tap the microphone icon and read the",
                    style: TextStyle(fontSize: 16)),
                const Text("following sentence", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text(
                  "\"${_sentences[sentenceCount].toString()}\"",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () =>
                  _isRecording
                      ? _stopAndSaveRecording()
                      : _startRecording(),
                  child: Lottie.asset(
                    "assets/microphone.json",
                    controller: _animationController,
                    onLoaded: (composition) =>
                    _animationController.duration = composition.duration,

                  ),
                ),
                Appbuttons(
                  text: "New Sentence",
                  onPressed: () => changeSentence(),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _recordings.length,
                    itemBuilder: (context, index) {
                      if (_recordings.isEmpty) {
                        return const SizedBox();
                      }
                      return ListTile(
                        title: Text("Recording ${index + 1}"),
                        onTap: () async => await _playRecording(_recordings[index]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.play_arrow, color: Colors.grey[600]),
                              onPressed: () async =>
                              await _playRecording(_recordings[index]),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmationDialog(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text('Voice Recorder'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          _recordings.length < 4
              ? Navigator.pushReplacementNamed(context, "/Login")
              : Navigator.pushReplacementNamed(context, "/Userinterface");
        },
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'help') {
              // Call the help dialog
              showHelpDialog();
            } else if (value == 'contact_support') {
              // Send email to labguard.app@outlook.com
              final Uri _emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'labguard.app@outlook.com',
                queryParameters: {'subject': 'Support Needed'},
              );
              launch(_emailLaunchUri.toString());
            }
          },
          itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'help',
              child: ListTile(
                leading: Icon(Icons.help),
                title: Text('More Information'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'contact_support',
              child: ListTile(
                leading: Icon(Icons.email),
                title: Text('Contact Support'),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (snapshot.exists) {
          // Check if the snapshot contains the fields
          if (snapshot.data()!.containsKey('first_name') && snapshot.data()!.containsKey('last_name') && snapshot.data()!.containsKey('uid')) {
            String firstName = snapshot.data()!['first_name']; // Retrieve first name from FB
            String lastName = snapshot.data()!['last_name']; // Retrieve last name
            String uid = snapshot.data()!['uid']; // Retrieve UID

           /*
           // print data for testing
            print('First Name: $firstName'); // Print first name to terminal
            print('Last Name: $lastName'); // Print last name
            print('UID: $uid'); // Print UID
            */

            // full name
            String fullName = '$firstName $lastName';
           // print('Full Name: $fullName');    //for testing

            // Save the first name, last name, and UID in variables for later use
            String savedFirstName = firstName;
            String savedLastName = lastName;
            String savedUid = uid;

            // Save the full name as a var too if needed
            String savedFullName = fullName;

          } else {
            print('User document does not contain first name, last name, and UID fields');
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }






  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thank You!'),
          content: const Text("You have already completed the setup."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/Userinterface");
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void showRecordingLimitMessage() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Voice Recording Setup'),
            content: const Text(
                "Please record your voice saying 4 different sentences to complete your account setup. "),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Call the help dialog
                  showHelpDialog();
                },
                child: const Text('More Info'),
              ),
            ],
          );
        },
      );
    });
  }


  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
  }

  Future<void> _saveRecordingsToFirestore() async {
    await FirebaseFirestore.instance.collection("recordings").doc(
        FirebaseAuth.instance.currentUser!.uid).set({
      'recordings': _recordings,
    }, SetOptions(merge: true));
  }

  Future<String> _saveToStorage(String recording) async {
    final file = File(recording);
    final fileName = '${DateTime
        .now()
        .millisecondsSinceEpoch}.aac';
    final storage = FirebaseStorage.instance;

    final storageRef = storage.ref().child(fileName);
    await storageRef.putFile(file);

    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }



  void changeSentence() => setState(() => sentenceCount++);



  Future<void> _loadRecordings() async {
    var doc = await FirebaseFirestore.instance.collection("recordings").doc(
        FirebaseAuth.instance.currentUser!.uid).get();

    if (doc.exists && doc.data()!['recordings'] != null) {
      setState(() {
        _recordings = List<String>.from(doc.data()!['recordings']);
      });
      if (widget.params.isFirstTime == true && _recordings.length >= 4) {
        showSuccessDialog();
      }
    }
  }

  void _startRecording() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/${DateTime
        .now()
        .millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );
    setState(() {
      _isRecording = true;
      _animationController.repeat();
    });
  }

  void _stopAndSaveRecording() async {
    setState(() {
      _isRecording = false;
      _animationController.reset();
      _animationController.stop();
    });
    String? path = await _recorder.stopRecorder();
    if (path != null) {
      final duration = await _getAudioDuration(
          path); // Get the duration of the audio
      if (duration < Duration(seconds: 2) || duration > Duration(seconds: 6)) {
        // Determine if the duration is too long or too short
        String errorMessage;
        if (duration < Duration(seconds: 3)) {
          errorMessage =
          "Recording is too short. It must be at least 3 seconds long.";
        } else {
          errorMessage =
          "Recording is too long. It must be at most 6 seconds long.";
        }
        // Display error message to the user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Recording Error"),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Try Again"),
                ),
              ],
            );
          },
        );
        return; // Exit early, do not save the recording
      }
      // Duration is within the acceptable range
      final downloadUrl = await _saveToStorage(path);
      setState(() {
        _recordings.add(downloadUrl);
        showSuccessDialog();
      });
      await _saveRecordingsToFirestore();
    }
  }

  Future<Duration> _getAudioDuration(String path) async {
    final FlutterFFprobe _flutterFFprobe = FlutterFFprobe();
    final result = await _flutterFFprobe.getMediaInformation(path);
    final durationString = result?.getMediaProperties()?["duration"];
    final duration = Duration(seconds: double.parse(durationString).toInt());
    return duration;
  }

  Future<void> _playRecording(String path) async {
    try {
      await _player.setAudioSource(
          AudioSource.uri(Uri.parse(path)), initialPosition: Duration.zero,
          preload: true);

      await _player.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  void _removeRecording(int index) {
    setState(() {
      _recordings.removeAt(index);
    });
    _saveRecordingsToFirestore();
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Recording"),
          content: const Text(
              "Are you sure you want to delete this recording?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeRecording(index);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('More Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why do we need your recordings?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We need your voice recordings for account setup. Each recording should be 3-5 seconds long which will helps us ensure secure authentication using our voice identification model.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Need further assistance?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you have any questions, concerns, or encounter any issues during the process, please feel free to contact us through the "Contact Support" option.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'You have one chance to record yout voice. Make it count!',
                 // style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
