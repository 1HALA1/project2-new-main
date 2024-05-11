import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';

import '../Widgets/Appbuttons.dart';
import 'Congrats.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  SpeechToText _speechToText = SpeechToText();
  String _recognizedWords = '';
  bool isListening = false;
  int successCounter = 0;
  String noun = '';
  bool showResult = false;
  bool verification1Success = false;

  late AnimationController _animationController;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTTS();
    _fetchRandomSentence().then((sentence) {
      setState(() {
        noun = sentence;
      });
    });
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speechToText.stop();
    flutterTts.stop();
    super.dispose();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _initTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      isListening = true;
      showResult = false;
      _animationController.repeat();
    });
    print('Speech recognition started');
  }

  void _stopListening() async {
    await _speechToText.stop();
    _animationController.reset();
    print('Speech recognition stopped');

    Timer(Duration(seconds: 1), () {
      bool result = _verifyText();
      setState(() {
        isListening = false;
        showResult = true;
        verification1Success = result;
      });

      Timer(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            showResult = false;
          });
        }
      });
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedWords = result.recognizedWords;
    });
    print('Recognized speech: $_recognizedWords');
  }

  Future<String> _fetchRandomSentence() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('random_text')
          .get();

      List<String> sentences = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('texts')) {
          var texts = data['texts'] as List;
          sentences.addAll(texts.map((text) => text.toString()));
        }
      }

      Random random = Random();
      return sentences[random.nextInt(sentences.length)];
    } catch (e) {
      print('Error fetching random sentences: $e');
      return '';
    }
  }

  void _regenerateSen() {
    _fetchRandomSentence().then((sentence) {
      setState(() {
        noun = sentence;
        _recognizedWords = '';
        showResult = false;
        verification1Success = false;
      });
    });
  }

  bool _verifyText() {
    var cleanedRecognizedWords = _recognizedWords.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    var cleanedNoun = noun.trim().toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    print('Verifying text: Recognized Words: $cleanedRecognizedWords, Noun: $cleanedNoun');
    if (cleanedRecognizedWords == cleanedNoun) {
      successCounter++;
      print('Success counter: $successCounter');
      return true;
    }
    print('ASR failed - no match');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
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
            child: Container(
              height: double.infinity,
              width:  double.infinity,
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
              child: SingleChildScrollView(

                physics: BouncingScrollPhysics(),
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
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'To authenticate, tap the mic icon and read the sentence below:',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded( // Wraps the Text widget to prevent overflow
                            child: Text(
                              '"$noun"',
                              style: TextStyle(
                                fontSize: 24,
                                color: isListening ? Colors.yellow.shade800 : Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.volume_up),
                            onPressed: () {
                              if (noun.isNotEmpty) {
                                flutterTts.speak(noun);
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        _recognizedWords.isNotEmpty
                            ? 'Recognized Speech: $_recognizedWords'
                            : '',
                        style: TextStyle(
                          fontSize: 24,
                          color: isListening ? Colors.indigo : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      if (showResult)
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(seconds: 1),
                          child: Center(
                            child: SizedBox(
                              width: 250,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: verification1Success ? Colors.green.withOpacity(0.6) : Colors.red.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      verification1Success ? Icons.check_circle_outline : Icons.highlight_off,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      verification1Success ? "Matched" : "Mismatched",
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          if (!_speechToText.isListening) {
                            _startListening();
                          } else {
                            _stopListening();
                          }
                        },
                        child: Container(
                          width: 150,
                          height: 150,
                          child: Lottie.asset(
                            'assets/microphone.json',
                            controller: _animationController,
                            onLoaded: (composition) {
                              _animationController
                                ..duration = composition.duration;
                            },
                            frameRate: FrameRate.max,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 60),
                      Appbuttons(
                        onPressed: _regenerateSen,
                        text: "Regenerate a New Sentence",
                      ),
                      SizedBox(height: 25),
                      Theme(
                        data: Theme.of(context).copyWith(
                          buttonTheme: ButtonThemeData(
                            disabledColor: Colors.grey,
                          ),
                        ),
                        child: Appbuttons(
                          text: "Submit",
                          onPressed: verification1Success ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Congrats(),
                              ),
                            );
                          } : null,
                          backgroundColor: verification1Success ? Color(0xFF2F66F5) : Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
