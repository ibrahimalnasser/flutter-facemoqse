import 'dart:math';
import 'package:flutter/material.dart';

class CircularCountdownTimer extends StatefulWidget {
  const CircularCountdownTimer({Key? key}) : super(key: key);

  @override
  State<CircularCountdownTimer> createState() => _CircularCountdownTimerState();
}

class _CircularCountdownTimerState extends State<CircularCountdownTimer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  Duration remainingTime = Duration.zero;
  String timeString = "00:00:00";

  @override
  void initState() {
    super.initState();

    // Calculate time remaining until next prayer
    // This is just an example - you should replace this with actual prayer time calculation
    final now = DateTime.now();
    final nextPrayerTime =
        DateTime(now.year, now.month, now.day, 19, 30); // Example: 7:30 PM

    if (nextPrayerTime.isBefore(now)) {
      // If next prayer time is in the past, set it to tomorrow
      final tomorrow = now.add(const Duration(days: 1));
      remainingTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day,
              nextPrayerTime.hour, nextPrayerTime.minute)
          .difference(now);
    } else {
      remainingTime = nextPrayerTime.difference(now);
    }

    // Set up animation controller for the circular progress
    _controller = AnimationController(
      vsync: this,
      duration: remainingTime,
    );

    _controller.reverse(from: 1.0);

    // Update the time string every second
    _controller.addListener(() {
      final seconds = remainingTime.inSeconds -
          (remainingTime.inSeconds * _controller.value).floor();

      final remaining = Duration(seconds: seconds);
      setState(() {
        timeString = _formatDuration(remaining);
      });
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        // Timer completed, you can handle this event
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Adjust as needed
      width: 100, // Adjust as needed
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: CircularTimerPainter(
              animation: _controller,
              backgroundColor: Colors.white24,
              color: const Color(0xffD1B000),
            ),
            child: Center(
              child: Text(
                timeString,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CircularTimerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color backgroundColor;
  final Color color;

  CircularTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

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

    final progress = animation.value * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      -progress, // Go clockwise (negative progress)
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
