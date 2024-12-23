import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartkidstracker/src/minor_deets/privacy_policy.dart';
import 'package:smartkidstracker/src/widgets/appbar/profile/details/work_experience.dart';
import 'package:smartkidstracker/src/widgets/appbar/profile/details/education.dart';
import 'package:smartkidstracker/src/widgets/appbar/profile/details/places_lived.dart';
import 'package:smartkidstracker/src/widgets/appbar/profile/details/basic_info.dart';

class UserProfilePage extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String? role;
  final String? section;
  final String? basicInfo;
  final String? education;
  final String? workExperience;
  final String? placesLived;

  const UserProfilePage({
    super.key,
    required this.firstName,
    required this.lastName,
    this.section,
    this.role,
    this.basicInfo,
    this.education,
    this.workExperience,
    this.placesLived,
  });

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> links = [];
  final double _appBarHeight = 200.0;
  final double _collapsedHeight = 80.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {});
    });
    _loadProfileImage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadProfileImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_pic.png';
    final profileImage = File(imagePath);

    if (await profileImage.exists()) {
      setState(() {
        _image = profileImage;
      });
    }
  }

  Future<void> _saveProfileImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_pic.png';
    await image.copy(imagePath);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _saveProfileImage(File(pickedFile.path));
    }
  }

  double _calculateFontSize() {
    double maxScrollExtent = _appBarHeight - _collapsedHeight;
    double scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0;
    double t = (scrollOffset / maxScrollExtent).clamp(0, 1);
    return 16 + (1 - t) * 8; 
  }

  IconData getPlatformIcon(String platform) {
    switch (platform) {
      case 'Telegram':
        return Icons.telegram;
      case 'Twitter':
        return Icons.link;
      case 'Snapchat':
        return Icons.camera;
      case 'TikTok':
        return Icons.music_note;
      case 'Pinterest':
        return Icons.pin_drop;
      case 'Instagram':
        return Icons.photo;
      default:
        return Icons.link;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: _appBarHeight,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : const AssetImage('assets/placeholder.png'),
                      radius: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.firstName} ${widget.lastName}',
                        style: TextStyle(
                          fontSize: _calculateFontSize(),
                          color: Colors.white,
                        ),
                      ),
                      const Text('Online', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.green],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildSectionHeader('Account'),
                ListTile(
                  title: const Text('Name'),
                  subtitle: Text('${widget.firstName} ${widget.lastName}'),
                  ),
                if (widget.role != null)
                  ListTile(
                    title: const Text('Role'),
                    subtitle: Text(widget.role!),
                  ),
                if (widget.section != null)
                  ListTile(
                    title: const Text('Section'),
                    subtitle: Text(widget.section!),
                  ),
                if (widget.basicInfo != null) 
                _buildEditableTile('Basic Information', const BasicInfoPage(), widget.basicInfo!),
                _buildEditableTile('Work Experience', const AddWorkExperienceScreen(), widget.workExperience),
                _buildEditableTile('Education', const AddEducationPage(), widget.education),
                _buildEditableTile('Places Lived', const AddPlaceLivedPage(), widget.placesLived),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Privacy and Security'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacyPolicy()),
                  ),
                ),
                const Divider(),
                _buildLinkSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEditableTile(String title, Widget page, String? subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle ?? 'Not Provided'),
      trailing: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        child: const Text('Edit'),
      ),
    );
  }

  Widget _buildLinkSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final platform = links[index]['platform']!;
        final link = links[index]['link']!;

        return ListTile(
          leading: Icon(getPlatformIcon(platform)),
          title: Text(link),
          subtitle: Text(platform),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Handle edit link functionality here
            },
          ),
        );
      },
    );
  }
}
