import 'dart:convert';
import 'dart:io' show Platform;

import 'package:facemosque/Screen/homescreen.dart';
import 'package:facemosque/Screen/splachScreen.dart';
import 'package:facemosque/providers/buttonclick.dart';
import 'package:facemosque/providers/fatchdata.dart';
import 'package:facemosque/providers/mosque.dart';
import 'package:facemosque/widget/notificationHelper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';

import 'package:flutter/services.dart';
import 'package:auto_start_flutter/auto_start_flutter.dart';


Future<void> initAutoStart() async {
  isAutoStartAvailable;

  try {
    bool? test = await isAutoStartAvailable;
    print(test);
    if (test!) await getAutoStartPermission();
  } on PlatformException catch (e) {
    print(e);
  }
}

void calladan() async {
 //   _notificationHelper.initializeNotification();
  // _notificationHelper.cancelAll();
  alarmadan('fajer');
  alarmadan('dhuhr');
  alarmadan('asr');
  alarmadan('magrib');
  alarmadan('isha');

}

NotificationHelper _notificationHelper = NotificationHelper();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
   _notificationHelper.initializeNotification();
    

  if (Platform.isIOS==false) {
    initAutoStart();
   
  }
  alarmadan('fajer');
  alarmadan('dhuhr');
  alarmadan('asr');
  alarmadan('magrib');
  alarmadan('isha');



  runApp(const MyApp());
}

void alarmadan(String adan) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool lang = false;
  if (prefs.containsKey('language')) {
    lang = prefs.getBool('language')!;
  }
  if (prefs.containsKey(adan)) {
    bool adanstate = prefs.getBool(adan)!;
    print(adanstate);
    if (adanstate) {
      if (prefs.containsKey('mosque')) {
        Mosque mosque =
            Mosque.fromJson(json.decode(prefs.getString('mosque')!));
        if (adan == 'fajer') {
          //await _notificationHelper.cancel(0);
          if (mosque.fajer != '') {
            var timehm = mosque.fajer.split(':');
            _notificationHelper.scheduledNotification(
              body: lang,
              title: lang ? 'الفجر' : adan,
              hour: int.parse(timehm[0]),
              minutes: int.parse(timehm[1]),
              id: 0,
              sound: 'adan',
            );
            print('fajer');
          }
        } else if (adan == 'dhuhr') {
          if (mosque.dhuhr != '') {
            //  _notificationHelper.cancel(1);

            var timehm = mosque.dhuhr.split(':');
            print('dhuhr');
            await _notificationHelper.scheduledNotification(
              body: lang,
              title: lang ? 'الظهر' : adan,
              hour: int.parse(timehm[0]),
              minutes: int.parse(timehm[1]),
              id: 1,
              sound: 'adan',
            );
            // notifsetting( 0, lang,lang ? 'الفجر' : adan,_nextInstanceOfTenAM(  int.parse(timehm[0]), int.parse(timehm[1])));
          }
        } else if (adan == 'asr') {
          if (mosque.asr != '') {
            //_notificationHelper.cancel(2);

            var timehm = mosque.asr.split(':');
            print('asr');
            await _notificationHelper.scheduledNotification(
              body: lang,
              title: lang ? 'العصر' : adan,
              hour: int.parse(timehm[0]),
              minutes: int.parse(timehm[1]),
              id: 2,
              sound: 'adan',
            );
            // notifsetting( 0, lang,lang ? 'الفجر' : adan,_nextInstanceOfTenAM(  int.parse(timehm[0]), int.parse(timehm[1])));
          }
        } else if (adan == 'magrib') {
          if (mosque.magrib != '') {
            // await _notificationHelper.cancel(3);

            var timehm = mosque.magrib.split(':');
            print('magrib');
            _notificationHelper.scheduledNotification(
              body: lang,
              title: lang ? 'المغرب' : adan,
              hour: int.parse(timehm[0]),
              minutes: int.parse(timehm[1]),
              id: 3,
              sound: 'adan',
            );
            // notifsetting( 0, lang,lang ? 'الفجر' : adan,_nextInstanceOfTenAM(  int.parse(timehm[0]), int.parse(timehm[1])));
          }
        } else if (adan == 'isha') {
          if (mosque.isha != '') {
            //await _notificationHelper.cancel(4);

            var timehm = mosque.isha.split(':');
            print('isha');
            _notificationHelper.scheduledNotification(
              body: lang,
              title: lang ? 'العشاء' : adan,
              hour: int.parse(timehm[0]),
              minutes: int.parse(timehm[1]),
              id: 4,
              sound: 'adan',
            );
            // notifsetting( 0, lang,lang ? 'الفجر' : adan,_nextInstanceOfTenAM(  int.parse(timehm[0]), int.parse(timehm[1])));
          }
        }
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
   static const MaterialColor green = MaterialColor(
    _bluePrimaryValue,
    <int, Color>{
       50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(_bluePrimaryValue),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );
  static const int _bluePrimaryValue = 0xFF1ea345;
  

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Buttonclickp()),
        ChangeNotifierProvider.value(value: FatchData()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Al-Jazeera',
          primarySwatch: green,
          primaryColor:green,
          textTheme: const TextTheme(
            
       
              headline1: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,
                                  fontSize: 20),
             headline2: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,
                                  fontSize: 20),
            //bodyText2: TextStyle(color: Colors.black),
            //  subtitle1: TextStyle(color: Colors.pinkAccent),
          ),
        ),
        routes: {
          HomeScreen.routeName: (_) => const HomeScreen(),
        },
        home: const SplachScreen(),
      ),
    );
  }
}
