import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interfaces/features/Congrats.dart';
//import 'package:flutter_interfaces/features/Forgotpassword.dart';
import 'package:flutter_interfaces/features/LandPage.dart';
import 'package:flutter_interfaces/features/Login.dart';
import 'package:flutter_interfaces/features/Managerinterface.dart';
import 'package:flutter_interfaces/features/Passwordchangedsuccessfully.dart';
import 'package:flutter_interfaces/features/Randomtext.dart';
import 'package:flutter_interfaces/features/Report.dart';
import 'package:flutter_interfaces/features/Resetpassword.dart';
import 'package:flutter_interfaces/features/Signup.dart';
import 'package:flutter_interfaces/features/Userinterface.dart';
import 'package:flutter_interfaces/features/reservation_requests.dart';
import 'package:flutter_interfaces/features/speechtotext.dart';
import 'package:flutter_interfaces/features/voice_recording/voice_recording_page.dart';
import 'package:flutter_interfaces/features/voice_recording/voice_recording_params.dart';
import 'package:flutter_interfaces/firebase_options.dart';
import 'package:flutter_interfaces/routes/routes_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/LandPage",
      onGenerateRoute: (settings) {
        if (settings.name == RoutesConstants.voiceRecording) {
          final VoiceRecordParams params = settings.arguments as VoiceRecordParams;
          return MaterialPageRoute(
            builder: (context) => VoiceRecordPage(params: params),
          );
        }
        return null;
      },
      routes: {
        "/LandPage": (context) => const LandPage(),
        "/Signup": (context) => const Signup(),
        "/Login": (context) => const Login(),
        //"/Forgotpassword": (context) => ForgotPassword(),
        "/Resetpassword": (context) => Resetpassword(),
        "/Passwordchangedsuccessfully": (context) => Passwordchangedsuccessfully(),

        "/Userinterface": (context) => const Userinterface(),
        "/Managerinterface": (context) => const Managerinterface(),
        // RoutesConstants.voiceRecording: (context) => VoiceRecordPage(params: VoiceRecordParams()),
        "/RegistrationRequestsPage": (context) => const RegistrationRequestsPage(),
        "/AuthPage": (context) => const AuthPage(),
        "/Congrats": (context) => const Congrats(),
        "/Report": (context) =>  Report(),
        " Randomtext" :(context) =>Randomtext(),
      },
    );
  }
}
