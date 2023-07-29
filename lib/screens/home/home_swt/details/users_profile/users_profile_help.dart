import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../repository/user_repository/user_repository.dart';
import '../../../../../style/colors.dart';
import '../help_detail_screen.dart';

class UsersProfilYardimlar extends StatefulWidget {
  final String currentUser;

  const UsersProfilYardimlar({Key? key, required this.currentUser})
      : super(key: key);

  @override
  State<UsersProfilYardimlar> createState() => _UsersProfilYardimlarState();
}

class _UsersProfilYardimlarState extends State<UsersProfilYardimlar> {
  late CollectionReference<Map<String, dynamic>> collection;
  List<DocumentSnapshot<Map<String, dynamic>>> documents = [];
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String? _profileImageURL;
  File? _image;
  bool isLoading = true;

  Future<void> fetchData() async {
    final querySnapshot = await collection
        .where('Destek Sahibi', isEqualTo: widget.currentUser)
        .get();

    setState(() {
      documents = querySnapshot.docs;
      isLoading = false;
    });
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRepository = UserRepository();
      final userData = await userRepository.getUserData(widget.currentUser);

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
    final userRef = FirebaseFirestore.instance
        .collection('pictures')
        .doc(widget.currentUser);
    final userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data();
      final profileImageRef = FirebaseStorage.instance
          .ref()
          .child('Profil_resimleri/${widget.currentUser}');
      final profileImageURL = await profileImageRef.getDownloadURL();

      setState(() {
        _profileImageURL = profileImageURL;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    collection = FirebaseFirestore.instance.collection('helps');
    _fetchUserData();
    _fetchProfileImageURL();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.yellow,
                  backgroundColor: AppColors.purple,
                ),
              )
            : documents.isEmpty
                ? const Center(
                    child: Text(
                      'Kullanıcıya ait yardım bulunmuyor...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : ListView.separated(
                    key: UniqueKey(),
                    separatorBuilder: (context, index) => Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                      child: const Divider(
                        color: AppColors.grey1,
                        thickness: 1.5,
                      ),
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final data =
                          documents[index].data() as Map<String, dynamic>;
                      final anakategori = data['Ana Kategori'];
                      final altkategori = data['Alt Kategori'];
                      final birim = data['Birim'];
                      final destek = data['Destek'];
                      final miktar = data['Miktar'];
                      final il = data['city'];
                      final ilce = data['district'];
                      final tarih = data['createdAt'] as Timestamp;

                      DateTime dateTime = tarih.toDate();

                      final formattedDate =
                          DateFormat('dd MMMM y - HH:mm', 'tr_TR')
                              .format(dateTime);
                      String dayName =
                          DateFormat.EEEE('tr_TR').format(dateTime);

                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth - (screenWidth - 25),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        formattedDate,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.more_vert,
                                      color: AppColors.purple,
                                    ),
                                  ],
                                ),
                                Card(
                                  elevation: 5,
                                  color: Colors.grey.shade50,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "$ilce, $il",
                                                style: const TextStyle(
                                                  color: AppColors.purple,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              dayName,
                                              style: const TextStyle(
                                                  color: AppColors.grey3),
                                            )
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: screenHeight * 0.01),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      anakategori +
                                                          '/ ' +
                                                          altkategori,
                                                      style: const TextStyle(
                                                          color: AppColors
                                                              .darkGrey,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          screenHeight * 0.01,
                                                    ),
                                                    Text(
                                                      miktar +
                                                          ' ' +
                                                          birim +
                                                          ' ' +
                                                          destek,
                                                      style: const TextStyle(
                                                          color:
                                                              AppColors.purple,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: screenHeight * 0.001),
                                          child: const Divider(
                                            color: AppColors.grey1,
                                            thickness: 1.5,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: AppColors.purple,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey.shade50,
                                                    backgroundImage:
                                                        _profileImageURL != null
                                                            ? NetworkImage(
                                                                _profileImageURL!)
                                                            : const AssetImage(
                                                                    'assets/profile/user_profile.png')
                                                                as ImageProvider<
                                                                    Object>?,
                                                    radius: 15,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                const Text(
                                                  '@',
                                                  style: TextStyle(
                                                      color: AppColors.purple,
                                                      fontSize: 17),
                                                ),
                                                Text(
                                                  _username,
                                                  style: const TextStyle(
                                                      color: AppColors.darkGrey,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            HelpDetailScreen(
                                                                helpId: documents[
                                                                        index]
                                                                    .id),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      backgroundColor:
                                                          AppColors.purple),
                                                  child: const Text(
                                                    "Detay",
                                                    style: TextStyle(
                                                        color: AppColors.white),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
      ],
    );
  }
}
