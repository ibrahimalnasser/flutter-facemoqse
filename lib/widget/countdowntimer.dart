import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:facemosque/providers/mosque.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CircularCountdownTimer extends StatefulWidget {
  final Map language;

  const CircularCountdownTimer({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  State<CircularCountdownTimer> createState() => _CircularCountdownTimerState();
}

class _CircularCountdownTimerState extends State<CircularCountdownTimer>
    with TickerProviderStateMixin {
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 0);
  Duration totalTimeBetweenPrayers = const Duration(minutes: 0);
  late AnimationController _controller;
  double progress = 1.0;
  String nextPrayerName = "";
  String moonPhase = "";
  double moonIllumination = 0.0;
  bool hasSunnahPrayer = false;
  String sunnahPrayerInfo = "";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // Long duration initially
    );

    calculateMoonPhase();
    setTimerForAdhan();
    startTimer();
  }

  void calculateMoonPhase() {
    // Calculate current moon phase
    // This is a simplified calculation
    final DateTime now = DateTime.now();

    // Lunar cycle is approximately 29.53 days
    // Jan 6, 2000 was a new moon
    final DateTime referenceMoon = DateTime(2000, 1, 6);
    final int daysSinceReference = now.difference(referenceMoon).inDays;

    // Calculate position in lunar cycle (0-1 where 0 and 1 are new moon)
    final double cyclePosition = (daysSinceReference % 29.53) / 29.53;
    moonIllumination = calculateMoonIllumination(cyclePosition);

    // Determine moon phase name based on position in cycle
    // Use translations from language map if available
    if (cyclePosition < 0.03 || cyclePosition > 0.97) {
      moonPhase = widget.language['newMoon'] ?? 'New Moon';
    } else if (cyclePosition < 0.25) {
      moonPhase = widget.language['waxingCrescent'] ?? 'Waxing Crescent';
    } else if (cyclePosition < 0.28) {
      moonPhase = widget.language['firstQuarter'] ?? 'First Quarter';
    } else if (cyclePosition < 0.47) {
      moonPhase = widget.language['waxingGibbous'] ?? 'Waxing Gibbous';
    } else if (cyclePosition < 0.53) {
      moonPhase = widget.language['fullMoon'] ?? 'Full Moon';
    } else if (cyclePosition < 0.72) {
      moonPhase = widget.language['waningGibbous'] ?? 'Waning Gibbous';
    } else if (cyclePosition < 0.78) {
      moonPhase = widget.language['lastQuarter'] ?? 'Last Quarter';
    } else {
      moonPhase = widget.language['waningCrescent'] ?? 'Waning Crescent';
    }
  }

  double calculateMoonIllumination(double cyclePosition) {
    // Simplified model of moon illumination
    // Returns value between 0 (new moon) and 1 (full moon)
    if (cyclePosition <= 0.5) {
      // Waxing phase - illumination increases from 0 to 1
      return sin(cyclePosition * pi);
    } else {
      // Waning phase - illumination decreases from 1 to 0
      return sin((1 - cyclePosition) * pi);
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _controller.dispose();
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

      List<DateTime> prayerTimes = [
        _getDateTimeFromPrayerTime(mosque.fajer, false),
        _getDateTimeFromPrayerTime(mosque.sharouq, false),
        _getDateTimeFromPrayerTime(mosque.dhuhr, false),
        _getDateTimeFromPrayerTime(mosque.asr, false),
        _getDateTimeFromPrayerTime(mosque.magrib, false),
        _getDateTimeFromPrayerTime(mosque.isha, false),
        _getDateTimeFromPrayerTime(mosque.fajer, true)
      ];

      // Use translated prayer names from language provider
      List<String> prayerNames = [
        widget.language['fajer'] ?? 'Fajr',
        widget.language['sunrise'] ?? 'Sunrise',
        widget.language['dhuhr'] ?? 'Dhuhr',
        widget.language['asr'] ?? 'Asr',
        widget.language['magrib'] ?? 'Maghrib',
        widget.language['isha'] ?? 'Isha',
        "${widget.language['fajer'] ?? 'Fajr'} (${widget.language['tomorrow'] ?? 'Tomorrow'})"
      ];

      DateTime previousPrayerTime = now; // Placeholder for the last prayer time
      DateTime nextPrayerTime = now; // Placeholder for the next prayer time

      bool foundNextPrayer = false;
      for (var i = 0; i < prayerTimes.length; i++) {
        if (prayerTimes[i].isAfter(now)) {
          nextPrayerTime = prayerTimes[i];
          nextPrayerName = prayerNames[i]; // Set the name of the next prayer

          // Determine if the upcoming prayer has sunnah prayers
          checkForSunnahPrayers(prayerNames[i]);

          foundNextPrayer = true;
          if (i == 0) {
            previousPrayerTime = prayerTimes[prayerTimes.length - 2];
          } else {
            previousPrayerTime = prayerTimes[i - 1];
          }
          break;
        }
      }

      // If no prayer time found, assume it's the next fajer (next day)
      if (!foundNextPrayer) {
        nextPrayerTime = prayerTimes[prayerTimes.length - 1];
        nextPrayerName = prayerNames[prayerTimes.length - 1]; // Fajr (Tomorrow)
        previousPrayerTime = prayerTimes[prayerTimes.length - 2];

        // Check for Fajr sunnah prayers
        checkForSunnahPrayers(widget.language['fajer'] ?? 'Fajr');
      }

      myDuration = Duration(
        seconds: nextPrayerTime.difference(now).inSeconds,
      );

      totalTimeBetweenPrayers = nextPrayerTime.difference(previousPrayerTime);

      if (myDuration.isNegative) {
        myDuration = Duration.zero;
      }

      // Reset animation controller with new duration
      _controller.duration = myDuration;
      _controller.reset();
      _controller.reverse(from: 1.0);
    }
  }

  // Define Sunnah raka'at counts
  int sunnahBeforeCount = 0;
  int sunnahAfterCount = 0;

  void checkForSunnahPrayers(String prayerName) {
    // Reset sunnah prayer info
    hasSunnahPrayer = false;
    sunnahPrayerInfo = "";
    sunnahBeforeCount = 0;
    sunnahAfterCount = 0;

    // Check prayer name and set appropriate Sunnah prayer info with raka'at counts
    if (prayerName == (widget.language['fajer'] ?? 'Fajr')) {
      hasSunnahPrayer = true;
      sunnahBeforeCount = 2;
      sunnahPrayerInfo =
          "${widget.language['sunnahBefore'] ?? 'Sunnah before'}: 2 ${widget.language['rakaats'] ?? 'raka\'at'}";
    } else if (prayerName == (widget.language['dhuhr'] ?? 'Dhuhr')) {
      hasSunnahPrayer = true;
      sunnahBeforeCount = 4;
      sunnahAfterCount = 2;
      sunnahPrayerInfo =
          "${widget.language['sunnahBefore'] ?? 'Sunnah before'}: 4 ${widget.language['rakaats'] ?? 'raka\'at'}, ${widget.language['sunnahAfter'] ?? 'after'}: 2 ${widget.language['rakaats'] ?? 'raka\'at'}";
    } else if (prayerName == (widget.language['asr'] ?? 'Asr')) {
      hasSunnahPrayer = true;
      sunnahBeforeCount = 4;
      sunnahPrayerInfo =
          "${widget.language['sunnahBefore'] ?? 'Sunnah before'}: 4 ${widget.language['rakaats'] ?? 'raka\'at'}";
    } else if (prayerName == (widget.language['magrib'] ?? 'Maghrib')) {
      hasSunnahPrayer = true;
      sunnahAfterCount = 2;
      sunnahPrayerInfo =
          "${widget.language['sunnahAfter'] ?? 'Sunnah after'}: 2 ${widget.language['rakaats'] ?? 'raka\'at'}";
    } else if (prayerName == (widget.language['isha'] ?? 'Isha')) {
      hasSunnahPrayer = true;
      sunnahAfterCount = 2;
      sunnahPrayerInfo =
          "${widget.language['sunnahAfter'] ?? 'Sunnah after'}: 2 ${widget.language['rakaats'] ?? 'raka\'at'}";
    }
    // No sunnah for Sunrise
  }

  DateTime _getDateTimeFromPrayerTime(String prayerTime, bool nextDay) {
    List<String> parts = prayerTime.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    DateTime now;
    if (nextDay)
      now = DateTime.now().add(const Duration(days: 1));
    else
      now = DateTime.now();
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

        // Update progress for the circular timer
        if (totalTimeBetweenPrayers.inSeconds > 0) {
          progress = myDuration.inSeconds / totalTimeBetweenPrayers.inSeconds;
          progress = progress.clamp(0.0, 1.0);
        }
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
    return Color.lerp(Colors.red, Colors.green, fraction)!;
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    final timeString = '$hours:$minutes:$seconds';
    final color = getColorForTimeLeft();

    return Container(
      margin: const EdgeInsets.all(32),
      height: 275,
      width: 275,
      child: CustomPaint(
        painter: CircularTimerPainter(
          progress: progress,
          backgroundColor: Colors.white24,
          color: color,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Next prayer label
              Text(
                '${widget.language['nextparer'] ?? 'Next'}: $nextPrayerName',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              // Time display
              Text(
                timeString,
                style: Theme.of(context).textTheme.displayLarge!.copyWith(
                      color: color,
                      fontSize: 24,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Moon phase info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Moon phase indicator
                  CustomPaint(
                    size: const Size(20, 20),
                    painter: MoonPhasePainter(
                      illumination: moonIllumination,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Moon phase text
                  Flexible(
                    child: Text(
                      moonPhase,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: color.withOpacity(0.8),
                            fontSize: 10,
                          ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Sunnah prayer info (below moon phase)
              if (hasSunnahPrayer) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Before prayer sunnah
                    if (sunnahBeforeCount > 0) ...[
                      Tooltip(
                        message:
                            "${widget.language['sunnahBefore'] ?? 'Sunnah before'} ${widget.language['prayer'] ?? 'prayer'}",
                        child: Icon(
                          Icons.arrow_back,
                          size: 12,
                          color: color.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "$sunnahBeforeCount",
                        style: TextStyle(
                          fontSize: 9,
                          color: color.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    // Spacing between before and after indicators
                    if (sunnahBeforeCount > 0 && sunnahAfterCount > 0)
                      const SizedBox(width: 4),

                    // After prayer sunnah
                    if (sunnahAfterCount > 0) ...[
                      Tooltip(
                        message:
                            "${widget.language['sunnahAfter'] ?? 'Sunnah after'} ${widget.language['prayer'] ?? 'prayer'}",
                        child: Icon(
                          Icons.arrow_forward,
                          size: 12,
                          color: color.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        "$sunnahAfterCount",
                        style: TextStyle(
                          fontSize: 9,
                          color: color.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    const SizedBox(width: 4),
                    // "Sunnah prayer" text
                    Flexible(
                      child: Tooltip(
                        message: sunnahPrayerInfo,
                        child: Text(
                          widget.language['sunnahPrayer'] ?? 'Sunnah prayer',
                          style: TextStyle(
                            fontSize: 8,
                            color: color.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color color;

  CircularTimerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    final angle = progress * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      -angle, // Go clockwise (negative progress)
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularTimerPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class MoonPhasePainter extends CustomPainter {
  final double illumination; // 0.0 to 1.0 (new moon to full moon and back)

  MoonPhasePainter({
    required this.illumination,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Draw moon outline
    final outlinePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius - 1, outlinePaint);

    // Draw moon background (dark side)
    final moonBackground = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 1, moonBackground);

    // Draw illuminated part
    final illuminatedPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;

    // Different drawing methods based on moon phase
    // 0.0 = New Moon, 0.5 = Full Moon, 1.0 = New Moon again
    if (illumination == 0.0 || illumination == 1.0) {
      // New moon - all dark, do nothing
    } else if (illumination < 0.5) {
      // Waxing moon (crescent to full)
      // Draw increasing right-side illumination
      final phaseAngle = (illumination / 0.5) * pi;
      final controlPoint =
          Offset(center.dx + radius * 2 * (illumination / 0.5), center.dy);

      Path path = Path()
        ..moveTo(center.dx, center.dy - radius) // Top of circle
        ..arcToPoint(Offset(center.dx, center.dy + radius), // Bottom of circle
            radius: Radius.circular(radius),
            clockwise: false // Right half of circle
            )
        ..arcToPoint(Offset(center.dx, center.dy - radius), // Back to top
            radius: Radius.circular(radius),
            clockwise: false // Left half of circle
            )
        ..close();

      // Create a path for the illuminated part (right side)
      Path illuminatedPath = Path()
        ..moveTo(center.dx, center.dy - radius) // Top of circle
        ..arcToPoint(Offset(center.dx, center.dy + radius), // Bottom of circle
            radius: Radius.circular(radius),
            clockwise: false // Right half of circle
            );

      // Add the curved terminator line
      if (illumination < 0.25) {
        // Crescent shape - concave terminator
        illuminatedPath.quadraticBezierTo(
            controlPoint.dx - 2 * radius * (0.25 - illumination),
            center.dy,
            center.dx,
            center.dy - radius);
      } else {
        // Gibbous shape - convex terminator
        illuminatedPath.quadraticBezierTo(
            controlPoint.dx - 2 * radius * (illumination - 0.25),
            center.dy,
            center.dx,
            center.dy - radius);
      }

      illuminatedPath.close();
      canvas.drawPath(illuminatedPath, illuminatedPaint);
    } else {
      // Waning moon (full to crescent)
      // Draw decreasing left-side illumination
      final phaseAngle = ((1.0 - illumination) / 0.5) * pi;
      final controlPoint = Offset(
          center.dx - radius * 2 * ((1.0 - illumination) / 0.5), center.dy);

      Path path = Path()
        ..moveTo(center.dx, center.dy - radius) // Top of circle
        ..arcToPoint(Offset(center.dx, center.dy + radius), // Bottom of circle
            radius: Radius.circular(radius),
            clockwise: true // Left half of circle
            )
        ..arcToPoint(Offset(center.dx, center.dy - radius), // Back to top
            radius: Radius.circular(radius),
            clockwise: true // Right half of circle
            )
        ..close();

      // Create a path for the illuminated part (left side)
      Path illuminatedPath = Path()
        ..moveTo(center.dx, center.dy - radius) // Top of circle
        ..arcToPoint(Offset(center.dx, center.dy + radius), // Bottom of circle
            radius: Radius.circular(radius),
            clockwise: true // Left half of circle
            );

      // Add the curved terminator line
      if (illumination > 0.75) {
        // Crescent shape - concave terminator
        illuminatedPath.quadraticBezierTo(
            controlPoint.dx + 2 * radius * (illumination - 0.75),
            center.dy,
            center.dx,
            center.dy - radius);
      } else {
        // Gibbous shape - convex terminator
        illuminatedPath.quadraticBezierTo(
            controlPoint.dx + 2 * radius * (0.75 - illumination),
            center.dy,
            center.dx,
            center.dy - radius);
      }

      illuminatedPath.close();
      canvas.drawPath(illuminatedPath, illuminatedPaint);
    }
  }

  @override
  bool shouldRepaint(MoonPhasePainter oldDelegate) {
    return illumination != oldDelegate.illumination;
  }
}
