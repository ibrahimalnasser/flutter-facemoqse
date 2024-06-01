import 'package:facemosque/providers/respray.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:provider/provider.dart';

import '../providers/buttonclick.dart';

class ConnectScreen extends StatelessWidget {
  static const routeName = '/connect';

  @override
  Widget build(BuildContext context) {
    List<String> ips = Provider.of<Respray>(context).Ips;
    Map language = Provider.of<Buttonclickp>(context).languagepro;
    var sizedphone = MediaQuery.of(context).size;
    // Fill it with false initially
    GroupButtonController settingController = GroupButtonController();

    String ipselected = '';
    print(ips);
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          SizedBox(
            height: sizedphone.height * 0.06,
          ),
          Align(
            child: Text(
              language['Serach for Respray IP'],
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          SizedBox(
            height: sizedphone.height * 0.05,
          ),
          Container(
            height: sizedphone.height * 0.67,
            width: sizedphone.width,
            decoration: BoxDecoration(),
            child: ListView(children: [
              GroupButton(
                controller: settingController,
                isRadio: true,
                options: GroupButtonOptions(
                    borderRadius: BorderRadius.circular(25),
                    groupingType: GroupingType.column,
                    buttonHeight: sizedphone.height * 0.1,
                    buttonWidth: sizedphone.width * 0.9,
                    unselectedTextStyle:
                        TextStyle(fontSize: 18, color: Colors.black),
                    selectedTextStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                onSelected: (index, isSelected, t) {
                  ipselected = index.toString();
                  print('$ipselected button is selected');
                },
                buttons: ips,
              ),
            ]),
          ),
          SizedBox(
            height: sizedphone.height * 0.04,
          ),
          ElevatedButton(
              child: Text(language['Choose ip']),
              onPressed: () async {
                Provider.of<Respray>(context, listen: false)
                    .setipaddress(ipselected);
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.all(13)),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  )))),
        ],
      )),
    );
  }
}
