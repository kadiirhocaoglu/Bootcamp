import 'package:bootcamp/screens/chat_screen/chat_screen.dart';
import 'package:bootcamp/screens/home/home_swt/details/users_profile/users_category_switcher.dart';
import 'package:bootcamp/style/colors.dart';
import 'package:bootcamp/style/icons/helphub_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UsersProfile extends StatefulWidget {
  final String userId;
  const UsersProfile({super.key, required this.userId});

  @override
  State<UsersProfile> createState() => _UsersProfileState();
}

class _UsersProfileState extends State<UsersProfile> {
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String _profiluserId = '';
  String? _profileImageURL;

  Future<void> _fetchUserData() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userData.exists) {
      setState(() {
        _username = userData['username'];
        _firstName = userData['firstName'];
        _lastName = userData['lastName'];
        _profiluserId = userData['userId'];
      });
    }
  }

  Future<void> _fetchProfileImageURL() async {
    final profileImageRef = FirebaseStorage.instance
        .ref()
        .child('Profil_resimleri/${widget.userId}');

    final profileImageURL = await profileImageRef.getDownloadURL();

    setState(() {
      _profileImageURL = profileImageURL;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchProfileImageURL();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(color: AppColors.purple, fontSize: 40),
        ),
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Helphub.back,
              color: AppColors.purple,
            )),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Divider(
            thickness: 3,
            color: AppColors.purple,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth - (screenWidth - 25)),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              color: Colors.grey.shade50,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenHeight * 0.01),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.purple,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.transparent,
                            backgroundImage: _profileImageURL != null
                                ? NetworkImage(_profileImageURL!)
                                : const AssetImage(
                                        'assets/profile/user_profile.png')
                                    as ImageProvider<Object>?,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_firstName $_lastName',
                                style: const TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 25,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '@$_username',
                                style: const TextStyle(
                                  color: AppColors.purple,
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatScreen(
                                                      recipientId:
                                                          _profiluserId)),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.yellow,width: 2),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.purple,
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Mesaj gönder",
                                            style: TextStyle(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          UsersCategorySwitcherWidget(userId: widget.userId),
        ],
      ),
    );
  }
}
