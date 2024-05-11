import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../Widgets/Appbuttons.dart';

class Congrats extends StatefulWidget {
  const Congrats({Key? key}) : super(key: key);

  @override
  _CongratsState createState() => _CongratsState();
}

class _CongratsState extends State<Congrats> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 10));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConfettiWidget(
              confettiController: _controller,
              blastDirection: -1.0,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 100,
              minBlastForce: 80,
              gravity: 0.2,
              shouldLoop: true,
              colors: const [
                Color(0xFFE3AC96),
                Color(0xFF2D2689),
                Color(0xFFF89150),
                Color(0xFF7D71C0),

              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Congratulations!",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Authentication has been completed successfully",
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 70),
            Center(
              child: Appbuttons(
                text: "Continue",
                routeName: '/Login',
                width: 200,
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}