import 'package:flutter/material.dart';

class BasicInfoPage extends StatefulWidget {
  final String gender; 
  final DateTime? dateOfBirth; 
  final String pronouns; 
  final List<String> languages;

  const BasicInfoPage({
    super.key,
    this.gender = '',
    this.dateOfBirth,
    this.pronouns = '',
    this.languages = const [],
  });

  @override
  _BasicInfoPageState createState() => _BasicInfoPageState();
}

class _BasicInfoPageState extends State<BasicInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Info'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  title: const Text('Gender'),
                  subtitle: Text(widget.gender.isNotEmpty ? widget.gender : 'Not specified'),
                ),
                ListTile(
                  title: const Text('Date of Birth'),
                  subtitle: Text(widget.dateOfBirth != null
                      ? '${widget.dateOfBirth!.toLocal()}'.split(' ')[0]
                      : 'Not specified'),
                ),
                ListTile(
                  title: const Text('Pronouns'),
                  subtitle: Text(widget.pronouns.isNotEmpty ? widget.pronouns : 'Not specified'),
                ),
                ListTile(
                  title: const Text('Languages'),
                  subtitle: Text(widget.languages.isNotEmpty
                      ? widget.languages.join(', ')
                      : 'Not specified'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
