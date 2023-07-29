import 'dart:io';

import 'package:bootcamp/screens/home/home_swt/details/help_detail_screen.dart';
import 'package:bootcamp/screens/profile/settings/delete_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../repository/user_repository/user_repository.dart';
import '../../style/colors.dart';

class ProfilYardimlar extends StatefulWidget {
  final String currentUserEmail;

  const ProfilYardimlar({Key? key, required this.currentUserEmail})
      : super(key: key);

  @override
  State<ProfilYardimlar> createState() => _ProfilYardimlarState();
}

class _ProfilYardimlarState extends State<ProfilYardimlar> {
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
        .where('Destek Sahibi', isEqualTo: widget.currentUserEmail)
        .get();

    setState(() {
      documents = querySnapshot.docs;
      isLoading = false;
    });
  }

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
    collection = FirebaseFirestore.instance.collection('helps');
    _fetchUserData();
    _fetchProfileImageURL();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.yellow,
              backgroundColor: AppColors.purple,
            ),
          )
        : documents.isEmpty
            ? const Center(
                child: Text(
                  'Yardımınız bulunmuyor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.separated(
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
                                    PopupMenuButton(
                                      color: Colors.transparent,
                                      elevation: 0,
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry>[
                                        PopupMenuItem(
                                          height: 1,
                                          child: Card(
                                            elevation: 3,
                                            color: AppColors.purple,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: ListTile(
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Yardımı Sil'),
                                                        content: const Text(
                                                            'Bu yardımı silmek istediğinize emin misiniz?'),
                                                        actions: [
                                                          ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              backgroundColor:
                                                                  AppColors
                                                                      .purple,
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                              'İptal',
                                                              style: TextStyle(
                                                                  color: AppColors
                                                                      .white),
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              backgroundColor:
                                                                  AppColors
                                                                      .purple,
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              String
                                                                  collectionName =
                                                                  'helps';
                                                              String
                                                                  documentId =
                                                                  documents[
                                                                          index]
                                                                      .id;
                                                              await deleteDataFromFirestore(
                                                                  collectionName,
                                                                  documentId);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              setState(() {
                                                                fetchData();
                                                                _fetchUserData();
                                                                _fetchProfileImageURL();
                                                              });
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  content: Text(
                                                                    'Yardımınız başarılı bir şekilde silindi',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              2),
                                                                ),
                                                              );
                                                            },
                                                            child: const Text(
                                                              'Sil',
                                                              style: TextStyle(
                                                                color: AppColors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                leading: const Icon(
                                                  Icons.delete,
                                                  color: AppColors.white,
                                                ),
                                                title: const Text(
                                                  'Sil',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      child: const Icon(
                                        Icons.more_vert,
                                        color: AppColors.purple,
                                      ),
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
                                                                FontWeight
                                                                    .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis),
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
                                                            color: AppColors
                                                                .purple,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis),
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
                                                          helpId:
                                                              documents[index]
                                                                  .id,
                                                        ),
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
