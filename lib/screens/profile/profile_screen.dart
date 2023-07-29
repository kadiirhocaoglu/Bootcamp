import 'package:bootcamp/screens/profile/prf_yrd_ihtc.dart';
import 'package:bootcamp/screens/profile/settings/settings_screen.dart';
import 'package:bootcamp/style/colors.dart';
import 'package:bootcamp/style/icons/helphub_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../repository/user_repository/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String? _profileImageURL;

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final userRepository = UserRepository();
      final userData = await userRepository.getUserData(userId);

      if (userData != null) {
        setState(() {
          _username = userData.username;
          _firstName = userData.firstName;
          _lastName = userData.lastName;
        });
      }
    }
  }

  Future<void> _fetchProfileImageURL() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userRef = FirebaseFirestore.instance
          .collection('pictures')
          .doc(currentUser.uid);
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        final profileImageRef = FirebaseStorage.instance
            .ref()
            .child('Profil_resimleri/${currentUser.uid}');
        final profileImageURL = await profileImageRef.getDownloadURL();

        setState(() {
          _profileImageURL = profileImageURL;
        });
      }
    }
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
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SettingsScreen()));
          },
          child:
              const Icon(Helphub.settings, color: AppColors.purple, size: 35),
        ),
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
                child: Row(
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
                          const SizedBox(
                            height: 15,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const CategorySwitcherWidget(),
        ],
      ),
    );
  }
}
