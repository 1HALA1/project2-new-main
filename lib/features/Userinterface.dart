import 'package:flutter/material.dart';
import 'package:flutter_interfaces/features/voice_recording/voice_recording_params.dart';
import 'package:flutter_interfaces/routes/routes_constants.dart';
import 'package:flutter_interfaces/widgets/Appbuttons.dart';

class Userinterface extends StatefulWidget {
  const Userinterface({super.key});

  @override
  _UserinterfaceState createState() => _UserinterfaceState();
}

class _UserinterfaceState extends State<Userinterface> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(seconds: 1), vsync: this);
    _animation = Tween<double>(begin: 0, end: 400).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: _animation.value,
                    height: _animation.value,
                    child: Image.asset('lib/assets/Photos/LOGO0.png'),
                  );
                },
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  child: Appbuttons(
                    text: "Request Authentication",
                    routeName: '/AuthPage',
                    height: 55,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  child: Appbuttons(
                    text: "voice recorder",
                    height: 55,
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      RoutesConstants.voiceRecording,
                      arguments: VoiceRecordParams(isFirstTime: false),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  child: Appbuttons(
                    height: 55,
                    text: "Log Out",
                    routeName: '/LandPage',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
