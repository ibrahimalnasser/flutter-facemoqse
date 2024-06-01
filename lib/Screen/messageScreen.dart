import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/buttonclick.dart';
import '../providers/respray.dart';

// ignore: must_be_immutable
class MessageScscreen extends StatelessWidget {
  static const routeName = '/message';

  var _textcontroler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var sizedphone = MediaQuery.of(context).size;
    Map language = Provider.of<Buttonclickp>(context).languagepro;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: sizedphone.height * 0.2,
            ),
            SizedBox(
                height: sizedphone.height * 0.3,
                width: sizedphone.width * 0.7,
                child: Image.asset('assets/images/message.png')),
            SizedBox(
              height: sizedphone.height * 0.1,
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: TextField(
                controller: _textcontroler,
                onChanged: (value) {},
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 12, fontWeight: FontWeight.normal),
                decoration: InputDecoration(
                  filled: false,
                  fillColor: Colors.white,
                  focusColor: Colors.white,
                  hoverColor: Colors.white,
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  labelText: language['Write Message'],
                ),
              ),
            ),
            SizedBox(
              height: sizedphone.height * 0.1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    child: Text(language['Send Message']),
                    onPressed: () async {
                      if (_textcontroler.text.isNotEmpty)
                        await Provider.of<Respray>(context, listen: false)
                            .sendudp('create_msg ${_textcontroler.text}');
                    },
                    style: ButtonStyle(
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.all(13)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )))),
                ElevatedButton(
                    child: Text(language['Delete Message']),
                    onPressed: () async {
                      await Provider.of<Respray>(context, listen: false)
                          .sendudp('del_msg');
                    },
                    style: ButtonStyle(
                        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                            EdgeInsets.all(13)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        )))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
