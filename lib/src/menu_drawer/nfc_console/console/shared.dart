import 'package:flutter/material.dart';
import 'constants.dart';

class NFCIcon extends StatelessWidget {
  const NFCIcon({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(NFCCONTANTS.nfc,
          size: NFCCONTANTS.iconSize, color: NFCCONTANTS.iconColor),
    );
  }
}

class TypeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const TypeButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NFCCONTANTS.buttonPadding),
      child: SizedBox(
        width: NFCCONTANTS.buttonWidth,
        height: NFCCONTANTS.buttonHeight,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NFCCONTANTS.borderRadius),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: NFCCONTANTS.buttonTextStyle,
          ),
        ),
      ),
    );
  }
}
