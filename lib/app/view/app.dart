import 'package:flutter/material.dart';
import 'package:smartiotconnect/ap/view/ap_page.dart';
import 'package:smartiotconnect/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.deepOrange.shade800,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepOrange.shade800,
          titleTextStyle: const TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const APPage(),
    );
  }
}
