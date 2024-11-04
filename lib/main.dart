import 'package:flutter/material.dart';
import 'package:chivero/components/life_cycle_event_handler.dart';
import 'package:chivero/landing/landing_page.dart';
import 'package:chivero/screens/mainscreen.dart';
import 'package:chivero/services/user_service.dart';
import 'package:chivero/utils/config.dart';
import 'package:chivero/utils/constants.dart';
import 'package:chivero/utils/providers.dart';
import 'package:chivero/view_models/theme/theme_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegúrate de que el binding esté inicializado
  try {
    await Config.initFirebase(); // Inicializa Firebase
    runApp(MyApp()); // Corre tu aplicación
  } catch (e) {
    print("Error initializing Firebase: $e"); // Captura y muestra cualquier error
  }
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detachedCallBack: () => UserService().setUserStatus(false),
        resumeCallBack: () => UserService().setUserStatus(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeProvider>(
        builder: (context, ThemeProvider notifier, Widget? child) {
          return MaterialApp(
            title: Constants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeData(
              notifier.dark ? Constants.darkTheme : Constants.lightTheme,
            ),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: ((BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  return TabScreen();
                } else
                  return Landing();
              }),
            ),
          );
        },
      ),
    );
  }

  ThemeData themeData(ThemeData theme) {
    return theme.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(
        theme.textTheme,
      ),
    );
  }
}