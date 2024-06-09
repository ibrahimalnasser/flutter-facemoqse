import 'package:facemosque/providers/respray.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:provider/provider.dart';

import '../providers/buttonclick.dart';

// ignore: must_be_immutable
class AzanScreen extends StatelessWidget {
  static const routeName = '/azan';
  final GroupButtonController _controller = GroupButtonController();

  AzanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<bool> adan = [false, false, false, false, false];
    var sizedphone = MediaQuery.of(context).size;
    Map language = Provider.of<Buttonclickp>(context).languagepro;
    return Scaffold(
      appBar: AppBar(leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon:const Icon(Icons.arrow_back_ios)),),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: sizedphone.height * 0.2,
              ),
              SizedBox(
                  height: sizedphone.height * 0.3,
                  width: sizedphone.width * 0.7,
                  child: Image.asset('assets/images/azan.png')),
              SizedBox(
                height: sizedphone.height * 0.1,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: GroupButton(
                  controller: _controller,
                  isRadio: false,
                  options: GroupButtonOptions(
                      borderRadius: BorderRadius.circular(25)),
                  onSelected: (index, isSelected, t) {
                    if (adan[isSelected] == true) {
                      adan[isSelected] = false;
                    } else {
                      adan[isSelected] = true;
                    }

                    print('$index button is selected');
                  },
                  buttons: [
                    language['fajer'],
                    language['dhuhr'],
                    language['asr'],
                    language['magrib'],
                    language['isha'],
                  ],
                ),
              ),
              ElevatedButton(
                  child: Text(language['azan active']),
                  onPressed: () {
                    Provider.of<Respray>(context, listen: false)
                        .sendudp('$adan');
                  },
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.all(13)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )))),
            ],
          ),
        ),
      ),
    );
  }
}
