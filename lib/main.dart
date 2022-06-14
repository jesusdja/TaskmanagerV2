import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tra_s4c/initial_page.dart';
import 'package:tra_s4c/services/bloc_data.dart';
import 'package:tra_s4c/services/push_notifications_services.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationServices.initializeApp();
  dirMain = await getApplicationDocumentsDirectory();
  runApp(MyApp());
}

double sizeH = 0;
double sizeW = 0;
int idTemplate = 0;
BlocData blocData = BlocData();
String versionApp = 'V-13.0.2+16';
bool isOpenSosForm = false;
Directory? dirMain;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskManager',
      debugShowCheckedModeBanner: false,
      home: InitialPage(),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      locale: Locale("es"),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}

class AppLocalizations {
  final Locale? locale;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString =
    await rootBundle.loadString('i18n/${locale!.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String? translate(String key) {
    return _localizedStrings[key];
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'es'].contains(locale.languageCode);
  }
  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

