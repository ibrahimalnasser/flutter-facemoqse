import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/buttonclick.dart';
import '../providers/respray.dart';

class HigiriScreen extends StatefulWidget {
  static const routeName = '/higrir';

  const HigiriScreen({Key? key}) : super(key: key);

  @override
  _HigiriScreenState createState() => _HigiriScreenState();
}

class _HigiriScreenState extends State<HigiriScreen> {
  int count = 0;

  void decrement() {
    setState(() {
      count--;
    });
  }

  void increment() {
    setState(() {
      count++;
    });
  }

  bool get isEmpty => count == -30;
  bool get isFull => count == 30;

  @override
  Widget build(BuildContext context) {
    Map language = Provider.of<Buttonclickp>(context).languagepro;
    return Scaffold(
      appBar: AppBar(leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon:const Icon(Icons.arrow_back_ios)),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              language['Hijri'],
              style: TextStyle(
                fontSize: 50,
                color: isFull ? Colors.red : Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(64),
            child: Text(
              '$count Days',
              style: TextStyle(
                fontSize: 60,
                color: isFull ? Colors.red : Colors.black,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: isEmpty ? null : decrement,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor:
                      isEmpty ? Colors.white.withOpacity(0.2) : Colors.white,
                  fixedSize: const Size(100, 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '-',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                  ),
                ),
              ),
              const SizedBox(
                width: 32,
              ),
              TextButton(
                onPressed: isFull ? null : increment,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor:
                      isFull ? Colors.white.withOpacity(0.2) : Colors.white,
                  fixedSize: const Size(100, 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '+',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
                child: Text(language['Adding Days']),
                onPressed: () {
                  Provider.of<Respray>(context, listen: false)
                      .sendudp('Hijri $count')
                      .then((value) => print('sdf'));
                },
                style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                        const EdgeInsets.all(13)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    )))),
          ),
        ],
      ),
    );
  }
}
