import 'package:flutter/material.dart';
import '../Widgets/Appbuttons.dart';

class Managerinterface extends StatefulWidget {
  const Managerinterface({Key? key}) : super(key: key);

  @override
  _ManagerinterfaceState createState() => _ManagerinterfaceState();
}

class _ManagerinterfaceState extends State<Managerinterface>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    _animation = Tween<double>(begin: 0, end: 450)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend body behind the AppBar
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
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
                SizedBox(height: 10),
                Appbuttons(
                  text: "Registration Requests",
                  routeName: '/RegistrationRequestsPage',
                ),

                SizedBox(height: 20),
                Appbuttons(text: "Random Texts", routeName: '/Randomtext'),
                SizedBox(height: 20),
                Appbuttons(text: "Reports", routeName: '/Report'),
                SizedBox(height: 20),
                Appbuttons(text: "Log Out", routeName: '/LandPage'),
              ],
            ),
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