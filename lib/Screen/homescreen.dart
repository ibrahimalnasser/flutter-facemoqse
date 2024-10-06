//TODO: #3 cleaning the code from unused libs and imports @ibrahimalnasser
//TODO: #4 adding a message for the user to take out the app from the battery optimization @ibrahimalnasser
//todo: #6 rebuild this code with IOS with the necessary modifcations for android and IOS in such a way that the code works for both @ibrahimalnasser

import 'package:facemosque/Screen/adminControlScreen.dart';
import 'package:facemosque/Screen/authscreen.dart';
import 'package:facemosque/Screen/contactUs.dart';
import 'package:facemosque/Screen/musqScreen.dart';
import 'package:facemosque/providers/auth.dart';
import 'package:facemosque/providers/fatchdata.dart';
import 'package:facemosque/providers/mosque.dart';
import 'package:facemosque/providers/mosques.dart';
import 'package:facemosque/widget/countdowntimer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:facemosque/Screen/eventnotifications.dart';
import 'package:facemosque/Screen/settingsscreen.dart';
import 'package:facemosque/providers/buttonclick.dart';
import 'package:facemosque/widget/bottomnav.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipe/swipe.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

//import "package:persistent_bottom_nav_bar_example_project/custom-widget-tabs.widget.dart";
//import "package:persistent_bottom_nav_bar_example_project/screens.dart";
import '../main.dart';
import '../widget/notificationHelper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/events.dart';

class ApiService {
  List<Event> filterEvents(List<Event> events) {
    DateTime currentDate = DateTime.now();
    List<Event> tmp = [];

    for (var i = 0; i < events.length; i++) {
      DateTime eventDate = DateTime.parse(events[i].eventDate);
      String frequency = events[i].eventFrequencyDay;
      if (frequency == 'single' && eventDate.isAtSameMomentAs(currentDate)) {
        // ignore: dead_code
        tmp.add(events[i]);
        //return eventDate.isAtSameMomentAs(currentDate);
      } else if (frequency == 'weekly' &&
          currentDate
              .isBefore(DateTime.parse(events[i].eventFrequencyEndDate))) {
        if (eventDate.weekday == currentDate.weekday) {
          tmp.add(events[i]);
        }
      } else if (frequency == 'monthly' &&
          currentDate
              .isBefore(DateTime.parse(events[i].eventFrequencyEndDate))) {
        if (eventDate.day == currentDate.day) {
          tmp.add(events[i]);
        }
      } else if (frequency == 'yearly' &&
          currentDate
              .isBefore(DateTime.parse(events[i].eventFrequencyEndDate))) {
        if (eventDate.month == currentDate.month &&
            eventDate.day == currentDate.day) {
          tmp.add(events[i]);
        }
      } else if (frequency == 'daily' &&
          currentDate
              .isBefore(DateTime.parse(events[i].eventFrequencyEndDate))) {
        tmp.add(events[i]);
      }
    }
    return tmp;
  }

  Future<List<Event>> fetchEvents(String mosqueID) async {
    String apiUrl =
        'https://facemosque.com/api/api.php?client=app&cmd=gettingEvents&mosqueId=' +
            mosqueID;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<Event> events =
            jsonResponse.map((data) => Event.fromJson(data)).toList();
        List<Event> filteredEvents = filterEvents(events);
        _printEvents(filteredEvents);
        return filteredEvents;
      } else {
        return []; // Return an empty list if the response is not successful
      }
    } catch (e) {
      return []; // Return an empty list if there is an error during the request
    }
  }

  void _printEvents(List<Event> events) {
    for (Event event in events) {
      print(
          'Event Name: ${event.eventName}, Date: ${event.eventDate}, Time: ${event.eventTime}');
    }
  }
}

class MySlider {
  String time;
  String timeend;
  String adan;
  bool Issharouq;
  MySlider(
      {required this.time,
      required this.timeend,
      required this.adan,
      required this.Issharouq});
}

//todo: #9 adding the information about the mosque as in the website such services and followers and add it in the main interface @ibrahimalnasser
class HomeScreen extends StatefulWidget {
  static const routeName = '/Home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationHelper _notificationHelper = NotificationHelper();
  late Future<List<Event>> futureEvents;

  //late PersistentTabController _controller;
  //late bool _hideNavBar;
  @override
  void initState() {
    //read();
    super.initState();
    // ignore: unused_local_variable
    PersistentTabController _controller = PersistentTabController();
    // ignore: unused_local_variable
    bool _hideNavBar = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //ask for locationPermission in homeScreen
    //Provider.of<FatchData>(context, listen: false).locationPermission();
    //call mosque form provider (FatchData) if not select mosque it well show Noting in All Text

    Mosque mosque = Provider.of<FatchData>(context).mosque;
    Mosques followedMosque = Provider.of<FatchData>(context).mosqueFollow;
    String mosquefollow = followedMosque.name;
    String msoqueFollowEmail =
        Provider.of<FatchData>(context).mosqueFollow.Email;
    futureEvents = ApiService().fetchEvents(followedMosque.mosqueid);

    //call Map(languagepro) from provider (Buttonclickp) return en language as default
    //have all key of word we need
    Map language = Provider.of<Buttonclickp>(context).languagepro;
    //MediaQuery well get size of phone like height and  height
    var sizedphone = MediaQuery.of(context).size;
    // List of Slider to show 5 cart of time adan
    //Every key language[''] well get word in en or ar
    List<MySlider> slider = [
      MySlider(
          time: mosque.fajer,
          timeend: mosque.fajeri,
          adan: language['fajer'],
          Issharouq: false),
      MySlider(
          time: mosque.sharouq,
          timeend: ' ',
          adan: language['sharouq'],
          Issharouq: true),
      MySlider(
          time: mosque.dhuhr,
          timeend: mosque.dhuhri,
          adan: language['dhuhr'],
          Issharouq: false),
      MySlider(
          time: mosque.asr,
          timeend: mosque.asri,
          adan: language['asr'],
          Issharouq: false),
      MySlider(
          time: mosque.magrib,
          timeend: mosque.magribi,
          adan: language['magrib'],
          Issharouq: false),
      MySlider(
          time: mosque.isha,
          timeend: mosque.ishai,
          adan: language['isha'],
          Issharouq: false),
      MySlider(
          time: mosque.friday_1, timeend: "00:00", adan: "1", Issharouq: false),
      MySlider(
          time: mosque.friday_2, timeend: "00:00", adan: "2", Issharouq: false),
    ];

    return Scaffold(
        resizeToAvoidBottomInset: false,
        // cearte bottomNavigationBar
        bottomNavigationBar: const BottomNav(),
        // safeArea insets its child by sufficient padding to avoid intrusions by the operating system.
        body: Swipe(
          onSwipeLeft: () async {
            if (Provider.of<Buttonclickp>(context, listen: false)
                    .indexnavigationbottmbar !=
                1) {
              if (Provider.of<Auth>(context, listen: false).user == null) {
                Navigator.of(context).pushNamed(AuthScreen.routeName);
              } else {
                Navigator.of(context).pushNamed(AdminControlScreen.routeName);
              }
            }
          },
          child: SafeArea(
            child: Container(
              // background color(white) of app
              color: const Color.fromARGB(255, 255, 255, 255),

              child: ListView(
                physics: Provider.of<Buttonclickp>(context)
                            .indexnavigationbottmbar ==
                        1
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  //if user select Home icon in app index(0) it's well show HomeScrean
                  Provider.of<Buttonclickp>(context).indexnavigationbottmbar ==
                          0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                width: sizedphone.width * 0.95,
                                height: 100,
                                margin: const EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                      image: AssetImage(
                                          "assets/images/quranbackground.jpg"),
                                      fit: BoxFit.cover,
                                      opacity: 0.05),
                                  border: Border.all(
                                      color: const Color(0xffD1B000), width: 2),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Theme.of(context).primaryColor,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Center(
                                  child: AutoSizeText(
                                    //show word in en or ar as lebal
                                    mosquefollow +
                                        "\n" +
                                        language['Date'] +
                                        mosque.dataid,

                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Al-Jazeera",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                    // Theme.of(context).textTheme.headline2,
                                    textAlign: TextAlign.center,
                                  ),
                                )),

                            //show name of mosque user select if not select it well show nothing
                            Container(
                              height: sizedphone.height * 0.65,
                              width: sizedphone.width * 0.95,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                image: const DecorationImage(
                                    image: AssetImage(
                                        "assets/images/backgroundprayers.png"),
                                    fit: BoxFit.cover,
                                    opacity: 0.1),
                                border: Border.all(
                                    color: const Color(0xffD1B000), width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      //show word adan or اذان as lebal
                                      AutoSizeText(
                                          slider[0].Issharouq
                                              ? ""
                                              : language['adan'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge),
                                      const SizedBox(),
                                      AutoSizeText(
                                          slider[0].Issharouq
                                              ? ""
                                              : language['prayer'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge),
                                    ],
                                  ),
                                  Container(
                                    height: sizedphone.height * 0.07,
                                    width: sizedphone.width * 0.90,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      image: const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/quranbackground.jpg"),
                                          fit: BoxFit.cover,
                                          opacity: 0.1),
                                      border: Border.all(
                                          color: const Color(0xffD1B000),
                                          width: 2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        AutoSizeText(slider[0].time,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        SizedBox(
                                            height: 32,
                                            width: 32,
                                            child: IconButton(
                                                iconSize: 32,
                                                alignment: Alignment.topCenter,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                onPressed: () {
                                                  setState(() {
                                                    Provider.of<Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[0] = !Provider.of<
                                                                Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[0];
                                                    Provider.of<Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .storesalaDay();
                                                    if (!Provider.of<
                                                                Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[0]) {
                                                      _notificationHelper
                                                          .cancel(0);
                                                    } else {
                                                      _notificationHelper
                                                          .initializeNotification();
                                                      alarmadan('fajer');
                                                    }
                                                  });
                                                },
                                                icon: Provider.of<Buttonclickp>(
                                                            context)
                                                        .sala[0]
                                                    ? const Icon(
                                                        FluentIcons
                                                            .speaker_2_32_filled,
                                                        size: 32,
                                                        color: Color.fromARGB(
                                                            255, 230, 230, 233),
                                                      )
                                                    : const Icon(
                                                        FluentIcons
                                                            .speaker_off_48_filled,
                                                        size: 32,
                                                        color: Color.fromARGB(
                                                            255, 175, 187, 4),
                                                      ))),
                                        AutoSizeText(slider[0].adan,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        AutoSizeText(slider[0].timeend,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: sizedphone.height * 0.07,
                                    width: sizedphone.width * 0.90,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      image: const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/quranbackground.jpg"),
                                          fit: BoxFit.cover,
                                          opacity: 0.1),
                                      border: Border.all(
                                          color: const Color(0xffD1B000),
                                          width: 2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        AutoSizeText(
                                            slider[1]
                                                .time
                                                .replaceAll(RegExp(r"\s+"), ""),
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        const SizedBox(
                                          width: 0,
                                          height: 0,
                                        ),
                                        AutoSizeText(slider[1].adan,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        AutoSizeText(slider[1].timeend,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: sizedphone.height * 0.07,
                                    width: sizedphone.width * 0.90,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      image: const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/quranbackground.jpg"),
                                          fit: BoxFit.cover,
                                          opacity: 0.1),
                                      border: Border.all(
                                          color: const Color(0xffD1B000),
                                          width: 2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        AutoSizeText(slider[2].time,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        SizedBox(
                                            height: 32,
                                            width: 32,
                                            child: IconButton(
                                                iconSize: 32,
                                                alignment: Alignment.topCenter,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                onPressed: () {
                                                  setState(() {
                                                    Provider.of<Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[1] = !Provider.of<
                                                                Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[1];
                                                    Provider.of<Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .storesalaDay();
                                                    if (!Provider.of<
                                                                Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[1]) {
                                                      _notificationHelper
                                                          .cancel(1);
                                                    } else {
                                                      _notificationHelper
                                                          .initializeNotification();
                                                      alarmadan('dhuhr');
                                                    }
                                                  });
                                                },
                                                icon: Provider.of<Buttonclickp>(
                                                            context)
                                                        .sala[1]
                                                    ? const Icon(
                                                        FluentIcons
                                                            .speaker_2_32_filled,
                                                        size: 32,
                                                        color: Color.fromARGB(
                                                            255, 230, 230, 233),
                                                      )
                                                    : const Icon(
                                                        FluentIcons
                                                            .speaker_off_48_filled,
                                                        size: 32,
                                                        color: Color.fromARGB(
                                                            255, 175, 187, 4),
                                                      ))),
                                        AutoSizeText(slider[2].adan,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        AutoSizeText(slider[2].timeend,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: sizedphone.height * 0.07,
                                    width: sizedphone.width * 0.90,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      image: const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/quranbackground.jpg"),
                                          fit: BoxFit.cover,
                                          opacity: 0.1),
                                      border: Border.all(
                                          color: const Color(0xffD1B000),
                                          width: 2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        AutoSizeText(slider[3].time,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        SizedBox(
                                            height: 32,
                                            width: 32,
                                            child: IconButton(
                                                iconSize: 32,
                                                alignment: Alignment.topCenter,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                onPressed: () {
                                                  setState(() {
                                                    Provider.of<Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[2] = !Provider.of<
                                                                Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[2];
                                                    Provider.of<Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .storesalaDay();
                                                    if (!Provider.of<
                                                                Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[2]) {
                                                      _notificationHelper
                                                          .cancel(2);
                                                    } else {
                                                      _notificationHelper
                                                          .initializeNotification();
                                                      alarmadan('asr');
                                                    }
                                                  });
                                                },
                                                icon: Provider.of<Buttonclickp>(
                                                            context)
                                                        .sala[2]
                                                    ? const Icon(
                                                        FluentIcons
                                                            .speaker_2_32_filled,
                                                        size: 32,
                                                        color: Color.fromARGB(
                                                            255, 230, 230, 233),
                                                      )
                                                    : const Icon(
                                                        FluentIcons
                                                            .speaker_off_48_filled,
                                                        size: 32,
                                                        color: Color.fromARGB(
                                                            255, 175, 187, 4),
                                                      ))),
                                        AutoSizeText(slider[3].adan,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        AutoSizeText(slider[3].timeend,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: sizedphone.height * 0.07,
                                    width: sizedphone.width * 0.90,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      image: const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/quranbackground.jpg"),
                                          fit: BoxFit.cover,
                                          opacity: 0.1),
                                      border: Border.all(
                                          color: const Color(0xffD1B000),
                                          width: 2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        AutoSizeText(slider[4].time,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        SizedBox(
                                            height: 32,
                                            width: 32,
                                            child: IconButton(
                                                iconSize: 32,
                                                alignment: Alignment.topCenter,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                onPressed: () {
                                                  setState(() {
                                                    Provider.of<Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[3] = !Provider.of<
                                                                Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[3];
                                                    Provider.of<Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .storesalaDay();
                                                    if (!Provider.of<
                                                                Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[3]) {
                                                      _notificationHelper
                                                          .cancel(3);
                                                    } else {
                                                      _notificationHelper
                                                          .initializeNotification();
                                                      alarmadan('magrib');
                                                    }
                                                  });
                                                },
                                                icon: Provider.of<Buttonclickp>(
                                                            context)
                                                        .sala[3]
                                                    ? const Icon(
                                                        FluentIcons
                                                            .speaker_2_32_filled,
                                                        size: 32,
                                                        color: Color.fromARGB(
                                                            255, 230, 230, 233),
                                                      )
                                                    : const Icon(
                                                        FluentIcons
                                                            .speaker_off_48_filled,
                                                        size: 32,
                                                        color: Color.fromARGB(
                                                            255, 175, 187, 4),
                                                      ))),
                                        AutoSizeText(slider[4].adan,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        AutoSizeText(slider[4].timeend,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: sizedphone.height * 0.07,
                                    width: sizedphone.width * 0.90,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      image: const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/quranbackground.jpg"),
                                          fit: BoxFit.cover,
                                          opacity: 0.1),
                                      border: Border.all(
                                          color: const Color(0xffD1B000),
                                          width: 2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        AutoSizeText(slider[5].time,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        SizedBox(
                                            height: 32,
                                            width: 32,
                                            child: IconButton(
                                                iconSize: 32,
                                                alignment: Alignment.topCenter,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                onPressed: () {
                                                  setState(() {
                                                    Provider.of<Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[4] = !Provider.of<
                                                                Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[4];
                                                    Provider.of<Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .storesalaDay();
                                                    if (!Provider.of<
                                                                Buttonclickp>(
                                                            context,
                                                            listen: false)
                                                        .sala[4]) {
                                                      _notificationHelper
                                                          .cancel(4);
                                                    } else {
                                                      _notificationHelper
                                                          .initializeNotification();
                                                      alarmadan('isha');
                                                    }
                                                  });
                                                },
                                                icon: Provider.of<Buttonclickp>(
                                                            context)
                                                        .sala[4]
                                                    ? const Icon(
                                                        FluentIcons
                                                            .speaker_2_32_filled,
                                                        size: 32,
                                                        color: Color.fromARGB(
                                                            255, 230, 230, 233),
                                                      )
                                                    : const Icon(
                                                        FluentIcons
                                                            .speaker_off_48_filled,
                                                        size: 32,
                                                        color: Color.fromARGB(
                                                            255, 175, 187, 4),
                                                      ))),
                                        AutoSizeText(slider[5].adan,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                        AutoSizeText(slider[5].timeend,
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            /*Container(
                                height: sizedphone.height * 0.30,
                                width: sizedphone.width * 0.95,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                      image: AssetImage(
                                          "assets/images/quranbackground.jpg"),
                                      fit: BoxFit.cover,
                                      opacity: 0.05),
                                  border: Border.all(
                                      color: const Color(0xffD1B000), width: 2),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      // I cearte method for next parer and today aya with seam shape and color and pass text
                                      titlel(language['Friday']),
                                      Container(
                                        height: sizedphone.height * 0.05,
                                        width: sizedphone.width * 0.90,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          border: Border.all(
                                              color: const Color(0xffD1B000),
                                              width: 2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            AutoSizeText(slider[6].adan,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge),
                                            AutoSizeText(slider[6].time,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: sizedphone.height * 0.05,
                                        width: sizedphone.width * 0.90,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          border: Border.all(
                                              color: const Color(0xffD1B000),
                                              width: 2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            AutoSizeText(slider[7].adan,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge),
                                            AutoSizeText(slider[7].time,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayLarge),
                                          ],
                                        ),
                                      ),
                                    ])),*/
                            Container(
                              height: sizedphone.height * 0.40,
                              width: sizedphone.width * 0.95,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                    image: AssetImage(
                                        "assets/images/quranbackground.jpg"),
                                    fit: BoxFit.cover,
                                    opacity: 0.05),
                                border: Border.all(
                                    color: const Color(0xffD1B000), width: 2),
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // I cearte method for next parer and today aya with seam shape and color and pass text
                                  titlel(language['nextparer']),
                                  mosque.isha != ''
                                      ? const CountdownTimer()
                                      : Text(
                                          language[
                                              'Select the mosque to see the last prayer'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge!
                                              .copyWith(fontSize: 15)),
                                  titlel(mosque.horA == 0
                                      ? language['todayHadith']
                                      : language['todayaya']),
                                  Expanded(
                                      child: Container(
                                    /*decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/quranbackground.jpg"),
                                          fit: BoxFit.cover,
                                          opacity: 0.05),
                                    ),*/
                                    alignment: Alignment.topCenter,

                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9),
                                    //AutoSizeText it well Change the font size to fit inside widget
                                    // That you gave it a certain size(height,wdith) of the phone screan size

                                    child: AutoSizeText(
                                      textAlign: TextAlign.center,
                                      // if language ar it well show haditha else it well show hadithe
                                      mosque.horA == 0
                                          ? Provider.of<Buttonclickp>(context)
                                                  .languageselected
                                              ? mosque.haditha.toString()
                                              : mosque.hadithe.toString()
                                          : Provider.of<Buttonclickp>(context)
                                                  .languageselected
                                              ? mosque.qurana.toString()
                                              : mosque.qurane.toString(),
                                      //give text style of headline 1 (I set in main.dart)
                                      //but it well change the font size to 20

                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(
                                            fontSize: 20,
                                          ),
                                    ),
                                  ))
                                ],
                              ),
                            ),
                            Container(
                                width: sizedphone.width * 0.95,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  image: const DecorationImage(
                                      image: AssetImage(
                                          "assets/images/quranbackground.jpg"),
                                      fit: BoxFit.cover,
                                      opacity: 0.05),
                                  border: Border.all(
                                      color: const Color(0xffD1B000), width: 2),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      titlel(language['events']),
                                      FutureBuilder<List<Event>>(
                                        future: futureEvents,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Center(
                                                child: Text(
                                                    'Error: ${snapshot.error}'));
                                          } else if (snapshot.hasData) {
                                            List<Event> events = snapshot.data!;
                                            return ListView.builder(
                                              // scrollDirection: Axis.vertical,
                                              physics:
                                                  NeverScrollableScrollPhysics(),

                                              shrinkWrap: true,
                                              padding: EdgeInsets.all(5),
                                              itemCount: events.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                15.0,
                                                                10.0,
                                                                15.0,
                                                                0.0),
                                                    child: InkWell(
                                                      onTap: () => showDialog<
                                                              String>(
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              AlertDialog(
                                                                title: const Text(
                                                                    'Event Description'),
                                                                content: Text(
                                                                    events[index]
                                                                        .eventDesc),
                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context,
                                                                            'OK'),
                                                                    child:
                                                                        const Text(
                                                                            'OK'),
                                                                  ),
                                                                ],
                                                              )),
                                                      child: Container(
                                                        width: 361.0,
                                                        height: 75.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          border: Border.all(
                                                            color: const Color(
                                                                0xffD1B000),
                                                            width: 2.0,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Align(
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      -1.0,
                                                                      0.0),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            -1.0,
                                                                            0.0),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          8.0,
                                                                          4.0,
                                                                          0.0,
                                                                          0.0),
                                                                      child:
                                                                          AutoSizeText(
                                                                        events[index]
                                                                            .eventName,
                                                                        minFontSize:
                                                                            24.0,
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .displayLarge!,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            -1.0,
                                                                            0.0),
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsetsDirectional.fromSTEB(
                                                                          8.0,
                                                                          3.0,
                                                                          0.0,
                                                                          0.0),
                                                                      child:
                                                                          Text(
                                                                        events[index]
                                                                            .participantName,
                                                                        style: TextStyle(
                                                                            color:
                                                                                const Color(0xffD1B000),
                                                                            fontSize: 10),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  EdgeInsetsDirectional
                                                                      .fromSTEB(
                                                                          0.0,
                                                                          0.0,
                                                                          8.0,
                                                                          0.0),
                                                              child:
                                                                  AutoSizeText(
                                                                '${events[index].eventTime}',
                                                                minFontSize: 24,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .displayLarge!,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ));

                                                /*Container(
                                                  height:
                                                      sizedphone.height * 0.09,
                                                  width:
                                                      sizedphone.width * 0.60,
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 6),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    image: const DecorationImage(
                                                        image: AssetImage(
                                                            "assets/images/quranbackground.jpg"),
                                                        fit: BoxFit.cover,
                                                        opacity: 0.1),
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xffD1B000),
                                                        width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      AutoSizeText(
                                                          events[index]
                                                              .eventName,
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .displayLarge),
                                                      Text(
                                                          '${events[index].eventDate} at ${events[index].eventTime}'),
                                                    ],
                                                  ),
                                                );*/
                                              },
                                            );
                                          } else {
                                            return Center(
                                                child: Text('No events found'));
                                          }
                                        },
                                      ),
                                    ]))
                          ],
                        )
                      // if user click favorite icon index(1) it well show MusqScreen
                      : Provider.of<Buttonclickp>(context)
                                  .indexnavigationbottmbar ==
                              1
                          ? const MusqScreen()
                          // if user click Notification icon index(2) it well show EventNotifications
                          : Provider.of<Buttonclickp>(context)
                                      .indexnavigationbottmbar ==
                                  2
                              ? const EventNotifications()
                              //else  click Setting icon index(3) it well show Settings
                              : const SettingsScreen(),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Visibility(
          visible: msoqueFollowEmail.isNotEmpty,
          child: FloatingActionButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(contactUs.routeName),

            // Add your onPressed code here!

            backgroundColor: Colors.white,
            child: const Icon(Icons.contact_support_sharp,
                color: Color(0xFF94C973)),
          ),
        ));
  }

  Container titlel(String titlel) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF94C973),
      ),
      alignment: Alignment.center,
      child:
          AutoSizeText(titlel, style: Theme.of(context).textTheme.displayLarge),
    );
  }
}
