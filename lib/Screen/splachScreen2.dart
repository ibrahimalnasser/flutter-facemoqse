import 'package:facemosque/Screen/homescreen.dart';
import 'package:facemosque/Screen/onbordingScreen2.dart';
import 'package:facemosque/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/auth.dart';
import '../providers/buttonclick.dart';
import '../providers/fatchdata.dart';
import '../providers/messagesetting.dart';

class SplachScreen2 extends StatefulWidget {
  const SplachScreen2({super.key});

  @override
  _SplachScreen2State createState() => _SplachScreen2State();
}

class _SplachScreen2State extends State<SplachScreen2> {
  //method change color state bar
  changeStatusColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setStatusBarColor(color, animate: true);
      if (useWhiteForeground(color)) {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(true);
      } else {
        FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
        FlutterStatusbarcolor.setNavigationBarWhiteForeground(false);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _a = true;
      });
    });
    Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _b = true;
      });
    });
    Timer(const Duration(milliseconds: 1300), () {
      setState(() {
        _c = true;
      });
    });
    Timer(const Duration(milliseconds: 1700), () {
      setState(() {
        _e = true;
      });
    });
    Timer(const Duration(milliseconds: 3400), () {
      setState(() {
        _d = true;
      });
    });
    Provider.of<MessageSetting>(context, listen: false).getNotification();
    changeStatusColor(const Color(0xFF1ea345));
    //reload all mosque from api
    Provider.of<FatchData>(context, listen: false).fatchandsetallmosque();
    //read All data form SharedPreferences
    Provider.of<FatchData>(context, listen: false).readdata();
    Provider.of<Auth>(context, listen: false).readuser();
    //read adan notifications button state from SharedPreferences
    Provider.of<Buttonclickp>(context, listen: false).readsalaDay();
    // show all mosuqe or( mosuqefollow and map ) in tab My Mosuqe from SharedPreferences
    Provider.of<Buttonclickp>(context, listen: false).getreplacetoloc();
    // show all mosuqe or mosuqefollowevent in tab My Mosuqe from SharedPreferences
    Provider.of<Buttonclickp>(context, listen: false).getreplacetoevent();
    //read language from SharedPreferences
    Provider.of<Buttonclickp>(context, listen: false).readlanguage();

    //   int? initScreen ;
    Timer(const Duration(milliseconds: 3850), () {
      setState(() {
        Navigator.of(context).pushReplacement(
          ThisIsFadeRoute(
            route: initScreen == 0 || initScreen == null
                ? const OnbordingScreen2()
                : const HomeScreen(),
            page: Container(),
          ),
        );
      });
    });
  }

  bool _a = false;
  bool _b = false;
  bool _c = false;
  bool _d = false;
  bool _e = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _h = MediaQuery.of(context).size.height;
    double _w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFF1ea345),
      body: Center(
        child: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: _d ? 900 : 2500),
              curve: _d ? Curves.fastLinearToSlowEaseIn : Curves.elasticOut,
              height: _d
                  ? 0
                  : _a
                      ? _h / 2
                      : 20,
              width: 20,
              // color: Colors.deepPurpleAccent,
            ),
            AnimatedContainer(
              duration: Duration(
                  seconds: _d
                      ? 1
                      : _c
                          ? 2
                          : 0),
              curve: Curves.fastLinearToSlowEaseIn,
              height: _d
                  ? _h
                  : _c
                      ? 130
                      : 20,
              width: _d
                  ? _w
                  : _c
                      ? 130
                      : 20,
              decoration: BoxDecoration(
                  color: _b ? Colors.white : const Color(0xFF1ea345),
                  // shape: _c? BoxShape.rectangle : BoxShape.circle,
                  borderRadius:
                      _d ? const BorderRadius.only() : BorderRadius.circular(20)),
              child: Center(
                child: _e ? Image.asset('assets/images/logo.png') : const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThisIsFadeRoute extends PageRouteBuilder {
  final Widget page;
  final Widget route;

  ThisIsFadeRoute({required this.page, required this.route})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: route,
          ),
        );
}
