import 'package:flutter/material.dart';


import '../Widgets/Appbuttons.dart';

class Passwordchangedsuccessfully extends StatefulWidget {
  @override
  _passwordChangedSuccessfullyState createState() =>
      _passwordChangedSuccessfullyState();
}

class _passwordChangedSuccessfullyState
    extends State<Passwordchangedsuccessfully>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.grey[200],
      ),
      backgroundColor: Colors.grey[200],
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
            _animationController != null
                ? AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _animation.value,
                  child: Transform.translate(
                    offset: Offset(0.0, 50 * (1 - _animation.value)),
                    child: Text(
                      "Successful!",
                      style: TextStyle(fontSize: 35),
                    ),
                  ),
                );
              },
            )
                : Container(),
            Text(
              "You have successfully changed your password. Please use your new password to login",
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 70,
            ),
            Center(
              child: Appbuttons(
                text: "continue",
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