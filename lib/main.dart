import 'dart:convert';
//import 'firebase_options.dart';
import 'package:facemosque/Screen/LanguageScreen.dart';
import 'package:facemosque/Screen/adminControlScreen.dart';
import 'package:facemosque/Screen/authscreen.dart';
import 'package:facemosque/Screen/azanScreen.dart';
import 'package:facemosque/Screen/connectScreen.dart';
import 'package:facemosque/Screen/contactUs.dart';
import 'package:facemosque/Screen/createnotificationsScreen.dart';
import 'package:facemosque/Screen/hijriScreen.dart';
import 'package:facemosque/Screen/homescreen.dart';
import 'package:facemosque/Screen/information.dart';
import 'package:facemosque/Screen/messageScreen.dart';
import 'package:facemosque/Screen/onbordingScreen2.dart';
import 'package:facemosque/Screen/prayerTimeScreen.dart';
import 'package:facemosque/Screen/resetScreen.dart';
import 'package:facemosque/Screen/screenScreen.dart';
import 'package:facemosque/Screen/signinScreenforevent.dart';
import 'package:facemosque/Screen/splachScreen2.dart';
import 'package:facemosque/Screen/themeScreen.dart';
import 'package:facemosque/Screen/volumeScreen.dart';
import 'package:facemosque/providers/auth.dart';
import 'package:facemosque/providers/buttonclick.dart';
import 'package:facemosque/providers/fatchdata.dart';
import 'package:facemosque/providers/messagefromtaipc.dart';
import 'package:facemosque/providers/messagesetting.dart';
import 'package:facemosque/providers/mosque.dart';
import 'package:facemosque/providers/respray.dart';
import 'package:facemosque/widget/notificationHelper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:background_fetch/background_fetch.dart';

//method set adan for all sala
Future<void> calladan() async {
  _notificationHelper.initializeNotification();
  // _notificationHelper.cancelAll();
  alarmadan('fajer');
  alarmadan('dhuhr');
  alarmadan('asr');
  alarmadan('magrib');
  alarmadan('isha');
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

//firebase setting for notification
Future<void> _firebasePushHandler(RemoteMessage message) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  List<MessageFromTaipc> list = [];
  if (preferences.containsKey('listmessage')) {
    final List<dynamic> jsonData =
        jsonDecode(preferences.getString('listmessage')!);
    list = jsonData.map<MessageFromTaipc>((jsonList) {
      return MessageFromTaipc.fromJson(jsonList);
    }).toList();
  }

  MessageFromTaipc messagetaipc = MessageFromTaipc.fromJson(message.data);

  list.add(messagetaipc);
  preferences.setString('listmessage', MessageFromTaipc.encode(list));
  await Firebase.initializeApp();
  // _notificationHelper.showNot(messagetaipc);
}

NotificationHelper _notificationHelper = NotificationHelper();
Future<void> updateMosuqe() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  if (preferences.containsKey('mosqid')) {
    try {
      http.Response response = await http.get(
        Uri.parse(
          "https://facemosque.eu/api/api.php?client=app&cmd=get_database_method_time&mosque_id=${preferences.getString('mosqid')}",
        ),
        headers: {
          "Connection": "Keep-Alive",
          'Content-type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 300));

      var data = utf8.decode(response.bodyBytes);

      if (data == "Mosque not exist") {
        // Show a snackbar message for the user
        final snackBar = SnackBar(
          content: Text('Prayer times are not updated'),
        );

        scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
      } else {
        // Decode the JSON response
        Map<String, dynamic> mosqueJson = jsonDecode(data);

        // Ensure that the mosque JSON is properly structured
        Mosque mosque = Mosque.fromJson(mosqueJson);

        // Store the mosque object in SharedPreferences
        preferences.setString('mosque', json.encode(mosque.toMap()));

        // Optionally show a success message
        final snackBar = SnackBar(
          content: Text('Prayer times have been updated'),
        );

        scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
      }
    } catch (e) {
      print('Error updating mosque: $e');
      // Optionally show an error message
      final snackBar = SnackBar(
        content: Text('An error occurred while updating prayer times'),
      );

      scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
    }
  }
}

void read() async {
  FirebaseMessaging.instance.getToken();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<MessageFromTaipc> list = [];
    if (preferences.containsKey('listmessage')) {
      final List<dynamic> jsonData =
          jsonDecode(preferences.getString('listmessage')!);
      list = jsonData.map<MessageFromTaipc>((jsonList) {
        return MessageFromTaipc.fromJson(jsonList);
      }).toList();
    }
    MessageFromTaipc messagetaipc = MessageFromTaipc.fromJson(message.data);
    list.add(messagetaipc);
    preferences.setString('listmessage', MessageFromTaipc.encode(list));
    await Firebase.initializeApp();
    _notificationHelper.showNot(messagetaipc);
  });
}

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     await updateMosuqe();
//     return Future.value(true);
//   });
// }

int? initScreen;
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    await updateMosuqe();
    BackgroundFetch.finish(taskId);
    return;
  }
  // Do your work here...
  BackgroundFetch.finish(taskId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BackgroundFetch.scheduleTask(TaskConfig(
      taskId: "com.transistorsoft.customtask",
      delay: 7200000 // <-- milliseconds
      ));
  await updateMosuqe();
  // Workmanager().initialize(callbackDispatcher);
  // await Workmanager().registerPeriodicTask(
  //     'recallmousqedata', 'recallmousqedata',
  //     frequency: const Duration(hours: 2),
  //     initialDelay: const Duration(seconds: 10),
  //     constraints: Constraints(networkType: NetworkType.connected));
  //set all alarm when app ope
  calladan();

  await Firebase.initializeApp();
  FirebaseMessaging.instance.getToken();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );

  read();
  //FirebaseMessaging.onBackgroundMessage(_firebasePushHandler);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = prefs.getInt("initScreen");
  await prefs.setInt("initScreen", 1);
  runApp(const MyApp());
}

void alarmadan(String adan) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool lang = false;

  // Read the language key (true for English, false for Arabic) from SharedPreferences
  if (prefs.containsKey('language')) {
    lang = prefs.getBool('language')!;
  }

  // If the user has selected the mosque and adan setting is enabled
  if (prefs.containsKey(adan)) {
    bool adanState = prefs.getBool(adan)!;
    if (adanState) {
      if (prefs.containsKey('mosque')) {
        // Get the mosque data from SharedPreferences
        String test = prefs.getString('mosque')!;
        Mosque mosque = Mosque.fromJson(json.decode(test));

        try {
          // Print the formatted string
          // Decode the mosque data from JSON string to Map<String, dynamic>

          // Parse the mosque object from the decoded JSON map
          /* Mosque mosque =
                Mosque.fromJson(mosqueJson);*/

          if (adan == 'fajer') {
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
            }
          } else if (adan == 'dhuhr') {
            if (mosque.dhuhr != '') {
              var timehm = mosque.dhuhr.split(':');
              _notificationHelper.scheduledNotification(
                body: lang,
                title: lang ? 'الظهر' : adan,
                hour: int.parse(timehm[0]),
                minutes: int.parse(timehm[1]),
                id: 1,
                sound: 'adan',
              );
            }
          } else if (adan == 'asr') {
            if (mosque.asr != '') {
              var timehm = mosque.asr.split(':');
              _notificationHelper.scheduledNotification(
                body: lang,
                title: lang ? 'العصر' : adan,
                hour: int.parse(timehm[0]),
                minutes: int.parse(timehm[1]),
                id: 2,
                sound: 'adan',
              );
            }
          } else if (adan == 'magrib') {
            if (mosque.magrib != '') {
              var timehm = mosque.magrib.split(':');
              _notificationHelper.scheduledNotification(
                body: lang,
                title: lang ? 'المغرب' : adan,
                hour: int.parse(timehm[0]),
                minutes: int.parse(timehm[1]),
                id: 3,
                sound: 'adan',
              );
            }
          } else if (adan == 'isha') {
            if (mosque.isha != '') {
              var timehm = mosque.isha.split(':');
              _notificationHelper.scheduledNotification(
                body: lang,
                title: lang ? 'العشاء' : adan,
                hour: int.parse(timehm[0]),
                minutes: int.parse(timehm[1]),
                id: 4,
                sound: 'adan',
              );
            }
          }
        } catch (e) {
          print('Error parsing mosque data: $e');
        }
      }
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  static const int _bluePrimaryValue = 0xFF0e8028;

  static const MaterialColor green = MaterialColor(
    _bluePrimaryValue,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF0e8028),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Buttonclickp()),
        ChangeNotifierProvider.value(value: FatchData()),
        ChangeNotifierProvider.value(value: MessageSetting()),
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Respray())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Al-Jazeera',
          primarySwatch: MyApp.green,
          //set color app
          primaryColor: MyApp.green,
          textTheme: const TextTheme(
            //set white color text with backgroud grean
            displayLarge: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            //set black color text with backgroud grean
            displayMedium: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        routes: {
          HomeScreen.routeName: (_) => const HomeScreen(),
          SigninScreenforEvent.routeName: (_) => const SigninScreenforEvent(),
          AdminControlScreen.routeName: (_) => const AdminControlScreen(),
          CreatenotificationsScreen.routeName: (_) =>
              const CreatenotificationsScreen(),
          AuthScreen.routeName: (_) => const AuthScreen(),
          Information.routeName: (_) => const Information(),
          LanguageScreen.routeName: (_) => const LanguageScreen(),
          ThemeScreen.routeName: (_) => const ThemeScreen(),
          AzanScreen.routeName: (_) => AzanScreen(),
          HigiriScreen.routeName: (_) => const HigiriScreen(),
          ResetScreen.routeName: (_) => const ResetScreen(),
          ScreenScreen.routeName: (_) => const ScreenScreen(),
          VolumeScreen.routeName: (_) => const VolumeScreen(),
          MessageScscreen.routeName: (_) => MessageScscreen(),
          PrayerTimeSreen.routeName: (_) => const PrayerTimeSreen(),
          ConnectScreen.routeName: (_) => const ConnectScreen(),
          OnbordingScreen2.routeName: (_) => const OnbordingScreen2(),
          contactUs.routeName: (_) => const contactUs()
        },
        //when app launch run SplachScreen
        home: const SplachScreen2(),
      ),
    );
  }
}
