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
        tmp.add(events[i]);
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
        'https://facemosque.com/api/api.php?client=app&cmd=gettingEvents&mosqueId=$mosqueID';

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

class HomeScreen extends StatefulWidget {
  static const routeName = '/Home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotificationHelper _notificationHelper = NotificationHelper();
  late Future<List<Event>> futureEvents;

  @override
  void initState() {
    super.initState();
    PersistentTabController _controller = PersistentTabController();
    bool _hideNavBar = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void alarmadan(String prayerName) {
    // Implementation for alarm functionality
    // This should be implemented according to your notification system
  }

  @override
  Widget build(BuildContext context) {
    // Get mosque data from provider
    Mosque mosque = Provider.of<FatchData>(context).mosque;
    Mosques followedMosque = Provider.of<FatchData>(context).mosqueFollow;
    String mosquefollow = followedMosque.name;
    String msoqueFollowEmail =
        Provider.of<FatchData>(context).mosqueFollow.Email;
    futureEvents = ApiService().fetchEvents(followedMosque.mosqueid);

    // Get language settings
    Map language = Provider.of<Buttonclickp>(context).languagepro;

    // Create prayer times list
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
      bottomNavigationBar: const BottomNav(),
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
            color: const Color.fromARGB(255, 255, 255, 255),
            child: _buildContent(context, mosque, followedMosque, mosquefollow,
                language, slider),
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: msoqueFollowEmail.isNotEmpty,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed(contactUs.routeName),
          backgroundColor: Colors.white,
          child:
              const Icon(Icons.contact_support_sharp, color: Color(0xFF94C973)),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      Mosque mosque,
      Mosques followedMosque,
      String mosquefollow,
      Map language,
      List<MySlider> slider) {
    // Choose content based on current tab
    final currentTab =
        Provider.of<Buttonclickp>(context).indexnavigationbottmbar;

    if (currentTab == 1) {
      return const MusqScreen();
    } else if (currentTab == 2) {
      return const EventNotifications();
    } else if (currentTab == 3) {
      return const SettingsScreen();
    } else {
      // Home Screen Content
      return OrientationBuilder(builder: (context, orientation) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isPortrait = orientation == Orientation.portrait;
            return _buildHomeContent(context, mosque, followedMosque,
                mosquefollow, language, slider, constraints, isPortrait);
          },
        );
      });
    }
  }

  Widget _buildHomeContent(
      BuildContext context,
      Mosque mosque,
      Mosques followedMosque,
      String mosquefollow,
      Map language,
      List<MySlider> slider,
      BoxConstraints constraints,
      bool isPortrait) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Mosque Header
        _buildMosqueHeader(
            context, mosquefollow, language, mosque, constraints),

        // Prayer Times Panel
        isPortrait
            ? _buildPrayerTimesPanel(context, slider, constraints)
            : _buildPrayerTimesPanelLandscape(context, slider, constraints),

        // Next Prayer and Hadith Panel
        _buildNextPrayerAndHadithPanel(context, mosque, language, constraints),

        // Events Panel
        _buildEventsPanel(context, language, constraints),
      ],
    );
  }

  Widget _buildMosqueHeader(BuildContext context, String mosquefollow,
      Map language, Mosque mosque, BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.95,
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage("assets/images/quranbackground.jpg"),
            fit: BoxFit.cover,
            opacity: 0.05),
        border: Border.all(color: const Color(0xffD1B000), width: 2),
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).primaryColor,
      ),
      child: Center(
        child: AutoSizeText(
          mosquefollow + "\n" + language['Date'] + mosque.dataid,
          style: const TextStyle(
              color: Colors.white,
              fontFamily: "Al-Jazeera",
              fontWeight: FontWeight.bold,
              fontSize: 18),
          textAlign: TextAlign.center,
          minFontSize: 14,
          maxLines: 2,
        ),
      ),
    );
  }

  Widget _buildPrayerTimesPanel(
      BuildContext context, List<MySlider> slider, BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.95,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: const DecorationImage(
            image: AssetImage("assets/images/backgroundprayers.png"),
            fit: BoxFit.cover,
            opacity: 0.1),
        border: Border.all(color: const Color(0xffD1B000), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPrayerTimesHeader(context, slider[0], constraints),

          // Prayer time cards using ListView.builder for better efficiency
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6, // Six prayer times
            itemBuilder: (context, index) {
              return _buildPrayerTimeCard(
                  context, slider[index], index, constraints);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesPanelLandscape(
      BuildContext context, List<MySlider> slider, BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.95,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: const DecorationImage(
            image: AssetImage("assets/images/backgroundprayers.png"),
            fit: BoxFit.cover,
            opacity: 0.1),
        border: Border.all(color: const Color(0xffD1B000), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPrayerTimesHeader(context, slider[0], constraints),

          // Grid layout for landscape mode
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildPrayerTimeCard(
                  context, slider[index], index, constraints);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesHeader(
      BuildContext context, MySlider sliderItem, BoxConstraints constraints) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AutoSizeText(
          sliderItem.Issharouq
              ? ""
              : (Provider.of<Buttonclickp>(context).languagepro['adan'] ?? ""),
          style: Theme.of(context).textTheme.displayLarge,
          minFontSize: 14,
        ),
        const SizedBox(),
        AutoSizeText(
          sliderItem.Issharouq
              ? ""
              : (Provider.of<Buttonclickp>(context).languagepro['prayer'] ??
                  ""),
          style: Theme.of(context).textTheme.displayLarge,
          minFontSize: 14,
        ),
      ],
    );
  }

  Widget _buildPrayerTimeCard(BuildContext context, MySlider sliderItem,
      int index, BoxConstraints constraints) {
    // Skip sunrise for alarm functionality
    final alarmIndex = index > 1 ? index - 1 : index;
    final showAlarmButton = !sliderItem.Issharouq;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: const DecorationImage(
            image: AssetImage("assets/images/quranbackground.jpg"),
            fit: BoxFit.cover,
            opacity: 0.1),
        border: Border.all(color: const Color(0xffD1B000), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 2,
            child: AutoSizeText(
              sliderItem.time.replaceAll(RegExp(r"\s+"), ""),
              style: Theme.of(context).textTheme.displayLarge,
              minFontSize: 14,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),

          // Alarm button - only shown for actual prayers, not sunrise
          if (showAlarmButton)
            Expanded(
              flex: 1,
              child: IconButton(
                  iconSize: 24,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    setState(() {
                      Provider.of<Buttonclickp>(context, listen: false)
                              .sala[alarmIndex] =
                          !Provider.of<Buttonclickp>(context, listen: false)
                              .sala[alarmIndex];
                      Provider.of<Buttonclickp>(context, listen: false)
                          .storesalaDay();

                      if (!Provider.of<Buttonclickp>(context, listen: false)
                          .sala[alarmIndex]) {
                        _notificationHelper.cancel(alarmIndex);
                      } else {
                        _notificationHelper.initializeNotification();
                        alarmadan(sliderItem.adan.toLowerCase());
                      }
                    });
                  },
                  icon: Provider.of<Buttonclickp>(context).sala[alarmIndex]
                      ? const Icon(
                          FluentIcons.speaker_2_32_filled,
                          size: 24,
                          color: Color.fromARGB(255, 230, 230, 233),
                        )
                      : const Icon(
                          FluentIcons.speaker_off_48_filled,
                          size: 24,
                          color: Color.fromARGB(255, 175, 187, 4),
                        )),
            )
          else
            const SizedBox(width: 32),

          Expanded(
            flex: 2,
            child: AutoSizeText(
              sliderItem.adan,
              style: Theme.of(context).textTheme.displayLarge,
              minFontSize: 14,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            flex: 2,
            child: AutoSizeText(
              sliderItem.timeend,
              style: Theme.of(context).textTheme.displayLarge,
              minFontSize: 14,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerAndHadithPanel(BuildContext context, Mosque mosque,
      Map language, BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.95,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage("assets/images/quranbackground.jpg"),
            fit: BoxFit.cover,
            opacity: 0.05),
        border: Border.all(color: const Color(0xffD1B000), width: 2),
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Next Prayer Title
          titlel(language['nextparer']),

          // Countdown Timer
          SizedBox(
            height: 60,
            child: mosque.isha != ''
                ? const CountdownTimer()
                : Text(
                    language['Select the mosque to see the last prayer'],
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge!
                        .copyWith(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
          ),

          // Hadith or Quran title
          titlel(mosque.horA == 0
              ? language['todayHadith']
              : language['todayaya']),

          // Hadith or Quran content
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
            alignment: Alignment.topCenter,
            child: AutoSizeText(
              mosque.horA == 0
                  ? Provider.of<Buttonclickp>(context).languageselected
                      ? mosque.haditha.toString()
                      : mosque.hadithe.toString()
                  : Provider.of<Buttonclickp>(context).languageselected
                      ? mosque.qurana.toString()
                      : mosque.qurane.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge!
                  .copyWith(fontSize: 18),
              minFontSize: 14,
              maxLines: 8,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEventsPanel(
      BuildContext context, Map language, BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth * 0.95,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage("assets/images/quranbackground.jpg"),
            fit: BoxFit.cover,
            opacity: 0.05),
        border: Border.all(color: const Color(0xffD1B000), width: 2),
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          titlel(language['events']),

          // Events List
          FutureBuilder<List<Event>>(
            future: futureEvents,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                List<Event> events = snapshot.data!;
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(5),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(context, events[index], constraints);
                  },
                );
              } else {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No events found',
                        style: TextStyle(color: Colors.white)),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
      BuildContext context, Event event, BoxConstraints constraints) {
    return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(15.0, 10.0, 15.0, 0.0),
        child: InkWell(
          onTap: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('Event Description'),
                    content: Text(event.eventDesc),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  )),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: const Color(0xffD1B000),
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          event.eventName,
                          style: Theme.of(context).textTheme.displayLarge,
                          minFontSize: 16,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.participantName,
                          style: const TextStyle(
                              color: Color(0xffD1B000), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        8.0, 0.0, 0.0, 0.0),
                    child: AutoSizeText(
                      event.eventTime,
                      style: Theme.of(context).textTheme.displayLarge,
                      minFontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Container titlel(String titlel) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF94C973),
      ),
      alignment: Alignment.center,
      child: AutoSizeText(
        titlel,
        style: Theme.of(context).textTheme.displayLarge,
        textAlign: TextAlign.center,
        minFontSize: 14,
      ),
    );
  }
}
