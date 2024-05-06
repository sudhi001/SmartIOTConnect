import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as fui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartiotconnect/app/view/ap_page.dart';
import 'package:smartiotconnect/l10n/l10n.dart';
import 'package:smartiotconnect/soundpool.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor:
            Colors.black, // Change navigation bar color here
      ),
    );
    return SoundProvider(
      child: MaterialApp(
        initialRoute: FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.dark(
            primary: Colors.greenAccent.shade200,
          ),
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          textTheme: GoogleFonts.courierPrimeTextTheme().apply(bodyColor:  Colors.greenAccent,
              displayColor: Colors.greenAccent.shade100,
              decorationColor: Colors.greenAccent,),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: TextStyle(color: Colors.white),
          ),
          useMaterial3: true,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {
          '/sign-in': (context) {
            return fui.SignInScreen(
              providers: [fui.EmailAuthProvider()],
              actions: [
                fui.AuthStateChangeAction<fui.SignedIn>((context, state) {
                  Navigator.pushReplacementNamed(context, '/home');
                }),
              ],
            );
          },
          '/home': (context) {
            return const APPage();
          },
        },
      ),
    );
  }
}
