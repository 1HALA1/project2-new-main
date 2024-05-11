import 'package:flutter/material.dart';
import '../Widgets/Appbuttons.dart';

class LandPage extends StatefulWidget {
  const LandPage({Key? key}) : super(key: key);

  @override
  _LandPageState createState() => _LandPageState();
}

class _LandPageState extends State<LandPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: -20,
      end: 20,
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _animation.value),
                        child: Image.asset(
                          'lib/assets/Photos/LOGO0.png',
                          width: 500,
                          height: 500,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 100),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Appbuttons(
                        width: 150,
                        height: 50,
                        text: "Signup",
                        routeName: '/Login',
                      ),

                      SizedBox(width: 20),
                      Appbuttons(
                        width: 150,
                        height: 50,
                        text: "Login",
                        routeName: '/Login',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, right: 16),
                child: IconButton(
                  icon: Icon(

                    Icons.help,
                    color: Color(0xFF2D2689),
                  ),
                  onPressed: () {
                    // Show help text or common questions dialog
                    _showHelpDialog(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(

      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ExpansionTile(
                  title: Text('Is there a limit to the recording duration?'),
                  children: [
                    Text(
                      '3 to 5 seconds.',
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text('How do I start recording?'),
                  children: [
                    Text(
                      'To start recording, simply press the record button.',
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text('How can I contact support?'),
                  children: [
                    Text(
                      'You can contact support by emailing support@example.com.',
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(color: Color(0xFF2D2689)),
              ),
            ),
          ],
        );

      },
    );
  }
}
