import 'dart:async';
import 'dart:convert';
import 'package:facemosque/providers/mosque.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountdownTimer extends StatefulWidget {
  static const routeName = '/Home';

  const CountdownTimer({Key? key}) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 0);
  Duration totalTimeBetweenPrayers = const Duration(minutes: 0);

  @override
  void initState() {
    super.initState();
    setTimerForAdhan();
    startTimer();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void setTimerForAdhan() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();

    if (preferences.containsKey('mosque')) {
      var timehm = ['0', '0'];
      Mosque mosque =
          Mosque.fromJson(json.decode(preferences.getString('mosque')!));

      List<String> prayerTimes = [
        mosque.fajer,
        mosque.sharouq,
        mosque.dhuhr,
        mosque.asr,
        mosque.magrib,
        mosque.isha
      ];

      bool foundNextPrayer = false;
      DateTime previousPrayerTime = now; // Placeholder for the last prayer time
      DateTime nextPrayerTime = now; // Placeholder for the next prayer time

      for (String prayer in prayerTimes) {
        DateTime prayerTime = _getDateTimeFromPrayerTime(prayer);
        if (prayerTime.isAfter(now)) {
          timehm = prayer.split(':');
          foundNextPrayer = true;
          nextPrayerTime = prayerTime;
          break;
        }
        previousPrayerTime = prayerTime;
      }

      // If no prayer time found, assume it's the next fajr (next day)
      if (!foundNextPrayer) {
        timehm = mosque.fajer.split(':');
        now = now.add(const Duration(days: 1));
        nextPrayerTime = _getDateTimeFromPrayerTime(mosque.fajer);
      }

      DateTime tempDate = DateTime(now.year, now.month, now.day,
          int.parse(timehm[0]), int.parse(timehm[1]));

      myDuration = Duration(
        seconds: tempDate.difference(now).inSeconds,
      );

      totalTimeBetweenPrayers = nextPrayerTime.difference(previousPrayerTime);

      if (myDuration.isNegative) {
        myDuration = Duration.zero;
      }
    }
  }

  DateTime _getDateTimeFromPrayerTime(String prayerTime) {
    List<String> parts = prayerTime.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  void setCountDown() {
    const reduceSecondsBy = 1;

    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        setTimerForAdhan();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  // Function to get color based on the time left and total time between prayers
  Color getColorForTimeLeft() {
    final totalSeconds = totalTimeBetweenPrayers.inSeconds;
    final remainingSeconds = myDuration.inSeconds;

    if (totalSeconds == 0) return Colors.green;

    double fraction = remainingSeconds / totalSeconds;
    fraction =
        fraction.clamp(0.0, 1.0); // Ensuring the fraction stays within 0 to 1

    // Interpolate between green and red based on the closeness to the next prayer
    return Color.lerp(Colors.green, Colors.red, 1 - fraction)!;
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    return Text(
      '$hours:$minutes:$seconds',
      style: Theme.of(context).textTheme.displayLarge!.copyWith(
            color: getColorForTimeLeft(), // Dynamically change the color
          ),
    );
  }
}
