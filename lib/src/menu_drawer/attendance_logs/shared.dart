import 'package:flutter/material.dart';

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
