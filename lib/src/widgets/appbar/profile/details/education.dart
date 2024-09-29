import 'package:flutter/material.dart';

class AddEducationPage extends StatefulWidget {
  const AddEducationPage({super.key});

  @override
  _AddEducationPageState createState() => _AddEducationPageState();
}

class _AddEducationPageState extends State<AddEducationPage> {
  bool isGraduated = false;
  String visibility = "Public";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add your school or university"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(
                labelText: 'School/University name (required)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Concentration (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Checkbox(
                  value: isGraduated,
                  onChanged: (value) {
                    setState(() {
                      isGraduated = value!;
                    });
                  },
                ),
                const Text('Graduated'),
              ],
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Since',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: visibility,
              items: <String>['Public', 'Private', 'Friends'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.public), 
                      const SizedBox(width: 8),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  visibility = newValue!;
                });
              },
              isExpanded: true,
              underline: Container(
                height: 2,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save button logic
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddSecondarySchoolPage extends StatefulWidget {
  const AddSecondarySchoolPage({super.key});

  @override
  _AddSecondarySchoolPageState createState() => _AddSecondarySchoolPageState();
}

class _AddSecondarySchoolPageState extends State<AddSecondarySchoolPage> {
  String selectedYear = "Year";
  String visibility = "Public";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add secondary school"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(
                labelText: 'School name (required)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                const Text(
                  'Class year',
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: selectedYear,
                  items: <String>['Year', '2024', '2023', '2022', '2021']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedYear = newValue!;
                    });
                  },
                  underline: Container(
                    height: 2,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: visibility,
              items: <String>['Public', 'Private', 'Friends'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.public), 
                      const SizedBox(width: 8),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  visibility = newValue!;
                });
              },
              isExpanded: true,
              underline: Container(
                height: 2,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save button logic
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




