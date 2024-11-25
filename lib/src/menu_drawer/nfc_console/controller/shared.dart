import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class NotSupportedDialog extends StatelessWidget {
  const NotSupportedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(CONTROLLERCONSTANTS.warningText),
      content: Text(
        CONTROLLERCONSTANTS.notSupportedText,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            CONTROLLERCONSTANTS.confirmText,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          onPressed: () {
            CONTROLLERCONSTANTS.navigatorPop(context);
          },
        ),
      ],
    );
  }
}

class EnableNFC extends StatelessWidget {
  const EnableNFC({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(CONTROLLERCONSTANTS.nfcDisabled),
      content: Text(
        CONTROLLERCONSTANTS.enableText,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            CONTROLLERCONSTANTS.notNow,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          onPressed: () {
            CONTROLLERCONSTANTS.navigatorPop(context);
          },
        ),
        TextButton(
          child: Text(
            CONTROLLERCONSTANTS.enable,
            style: TextStyle(
              color: Color.fromARGB(255, 4, 197, 107),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () async {
            CONTROLLERCONSTANTS.navigatorPop(context);
            final intent = AndroidIntent(
              action: CONTROLLERCONSTANTS.androidIntent,
              flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
            );
            await intent.launch();
          },
        ),
      ],
    );
  }
}

class ReturnText extends StatelessWidget {
  final String message;
  const ReturnText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message),
    );
  }
}

class ReturnLoading extends StatelessWidget {
  const ReturnLoading({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}
