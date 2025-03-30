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
  Future<List<Event>> fetchEvents(String mosqueID, DateTime date) async {
    String apiUrl =
        'https://facemosque.com/api/api.php?client=app&cmd=gettingEvents&mosqueId=$mosqueID';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Check if response body is empty
        if (response.body.isEmpty) {
          print('Warning: Empty response from API');
          return [];
        }

        try {
          // The response might be a string that needs additional parsing
          // First, safely decode the JSON response
          dynamic jsonData = json.decode(response.body);

          // Handle different possible response formats
          List<dynamic> jsonResponse = []; // Initialize with empty list

          if (jsonData is String) {
            // If the response is a string, try to parse it again
            try {
              jsonData = json.decode(jsonData);
            } catch (e) {
              print(
                  'Error: Response is a string that cannot be parsed as JSON: $jsonData');
              // If we can't parse further, return empty list
              return [];
            }
          }

          // Now check if we have a list
          if (jsonData is List) {
            jsonResponse = jsonData;
          } else if (jsonData is Map) {
            // Some APIs wrap the list in a parent object
            // Check if any key contains a list that might be our events
            bool foundList = false;
            for (var key in jsonData.keys) {
              if (jsonData[key] is List) {
                jsonResponse = jsonData[key];
                foundList = true;
                break;
              }
            }

            // If we didn't find a list, create a single-item list with this map
            if (!foundList) {
              jsonResponse = [jsonData];
            }
          } else {
            print('Error: Unexpected response format. Response: $jsonData');
            return [];
          }

          // Map each item to an Event object with error handling
          List<Event> events = [];
          for (var data in jsonResponse) {
            try {
              // Make sure data is a map before passing to fromJson
              if (data is Map<String, dynamic>) {
                events.add(Event.fromJson(data));
              } else if (data is Map) {
                // Convert to Map<String, dynamic> if possible
                Map<String, dynamic> convertedMap = {};
                data.forEach((key, value) {
                  if (key is String) {
                    convertedMap[key] = value;
                  }
                });
                events.add(Event.fromJson(convertedMap));
              } else if (data is String) {
                // If data is a string, try to parse it as JSON
                try {
                  Map<String, dynamic> parsedData = json.decode(data);
                  events.add(Event.fromJson(parsedData));
                } catch (e) {
                  print(
                      'Error: Event data is a string that cannot be parsed as JSON: $data');
                }
              } else {
                print('Error: Event data is neither a map nor a string: $data');
              }
            } catch (e) {
              print('Error parsing event data: $e. Data: $data');
              // Continue with other events
            }
          }

          // Filter and log events
          List<Event> filteredEvents = filterEvents(events, date);
          _printEvents(filteredEvents);
          return filteredEvents;
        } catch (parseError) {
          print(
              'Error parsing JSON response: $parseError. Response: ${response.body}');
          return [];
        }
      } else {
        print(
            'API error: HTTP status ${response.statusCode}. Response: ${response.body}');
        return []; // Return an empty list if the response is not successful
      }
    } catch (e) {
      print('Network or other error: $e');
      return []; // Return an empty list if there is an error during the request
    }
  }

  List<Event> filterEvents(List<Event> events, DateTime currentDate) {
    List<Event> tmp = [];

    for (var i = 0; i < events.length; i++) {
      try {
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
      } catch (e) {
        print('Error filtering event: $e. Event: ${events[i].eventName}');
        // Skip this event and continue with others
      }
    }
    return tmp;
  }

  void _printEvents(List<Event> events) {
    print('Found ${events.length} events for today:');
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
  DateTime _selectedDate =
      DateTime.now(); // Add this to track the selected date

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

  // Add this method to fetch events for a specific date
  Future<List<Event>> _fetchEventsByDate(String mosqueID, DateTime date) async {
    // First fetch all events
    ApiService apiService = ApiService();
    List<Event> allEvents = await apiService.fetchEvents(mosqueID, date);

    // Filter events for the selected date
    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    return allEvents.where((event) {
      // For one-time events, check if the date matches
      if (event.eventFrequencyDay == 'single') {
        return event.eventDate == formattedDate;
      }

      // For recurring events, check according to frequency
      DateTime eventStartDate = DateTime.parse(event.eventDate);
      DateTime eventEndDate = DateTime.parse(event.eventFrequencyEndDate);

      if (date.isAfter(eventEndDate)) {
        return false;
      }

      if (event.eventFrequencyDay == 'daily') {
        return date.isAfter(eventStartDate) ||
            date.isAtSameMomentAs(eventStartDate);
      } else if (event.eventFrequencyDay == 'weekly') {
        return date.weekday == eventStartDate.weekday &&
            (date.isAfter(eventStartDate) ||
                date.isAtSameMomentAs(eventStartDate));
      } else if (event.eventFrequencyDay == 'monthly') {
        return date.day == eventStartDate.day &&
            (date.isAfter(eventStartDate) ||
                date.isAtSameMomentAs(eventStartDate));
      } else if (event.eventFrequencyDay == 'yearly') {
        return date.day == eventStartDate.day &&
            date.month == eventStartDate.month &&
            (date.isAfter(eventStartDate) ||
                date.isAtSameMomentAs(eventStartDate));
      }

      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get mosque data from provider
    Mosque mosque = Provider.of<FatchData>(context).mosque;
    Mosques followedMosque = Provider.of<FatchData>(context).mosqueFollow;
    String mosquefollow = followedMosque.name;
    String msoqueFollowEmail =
        Provider.of<FatchData>(context).mosqueFollow.Email;
    DateTime todayDate = DateTime.now();
    futureEvents = ApiService().fetchEvents(followedMosque.mosqueid, todayDate);

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
        Center(
          child: mosque.isha != ''
              ? CircularCountdownTimer(
                  language: language) // Pass language to the timer
              : Text(
                  language['Select the mosque to see the last prayer'],
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
        ),

        // Prayer Times Panel
        isPortrait
            ? _buildPrayerTimesPanel(context, slider, constraints)
            : _buildPrayerTimesPanelLandscape(context, slider, constraints),

        // Next Prayer and Hadith Panel
        _buildNextPrayerAndHadithPanel(context, mosque, language, constraints),

        // Events Panel
        _buildEventsPanel(context, language, constraints, followedMosque),
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
          // Removed the separate next prayer title as it's now part of the timer
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

// Preserved original styling with both date display and date picker functionality
  Widget _buildEventDateSelector(BuildContext context, Map language) {
    // Create a custom title that includes both the original styling and the date
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF94C973),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Events text
            AutoSizeText(
              language['events'] ?? 'Events',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
              minFontSize: 14,
            ),
            const SizedBox(height: 8), // Vertical spacing
            // Date display
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  DateFormat('MMM d, yyyy').format(_selectedDate),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 14,
                      ),
                  textAlign: TextAlign.center,
                  minFontSize: 12,
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// New method to show the date picker
  void _showDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF94C973), // Header background color
              onPrimary: Colors.white, // Header text color
              surface: Colors.white, // Dialog background color
              onSurface: Colors.black, // Dialog text color
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Updated events panel with date navigation
  Widget _buildEventsPanel(BuildContext context, Map language,
      BoxConstraints constraints, Mosques followedMosque) {
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
          // Events title with date selector
          _buildEventDateSelector(context, language),

          // Add side navigation arrows around the event list
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left arrow for navigation
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      height: 40,
                      width: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xFF94C973).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),

              // Events List
              Expanded(
                child: FutureBuilder<List<Event>>(
                  future: _fetchEventsByDate(
                      followedMosque.mosqueid, _selectedDate),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30.0),
                        child: CircularProgressIndicator(),
                      ));
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white)),
                      ));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      List<Event> events = snapshot.data!;
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(5),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return _buildEventCard(
                              context, events[index], constraints);
                        },
                      );
                    } else {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30.0),
                          child: Text(
                            'No events on ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),

              // Right arrow for navigation
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      height: 40,
                      width: 25,
                      decoration: BoxDecoration(
                        color: const Color(0xFF94C973).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
                        Row(
                          children: [
                            Text(
                              event.participantName,
                              style: const TextStyle(
                                  color: Color(0xffD1B000), fontSize: 10),
                            ),
                            const SizedBox(width: 8),
                            // Add frequency indicator
                            if (event.eventFrequencyDay != 'single')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xffD1B000).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _getFrequencyText(event.eventFrequencyDay),
                                  style: const TextStyle(
                                    color: Color(0xffD1B000),
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                          ],
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

  // Helper method to show frequency text
  String _getFrequencyText(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      default:
        return '';
    }
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
