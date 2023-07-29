import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../style/colors.dart';
import 'details/need_detail_screen.dart';
import 'details/users_profile/users_profile.dart';

class HomeNeedScreen extends StatefulWidget {
  const HomeNeedScreen({Key? key}) : super(key: key);

  @override
  State<HomeNeedScreen> createState() => _HomeNeedScreenState();
}

class _HomeNeedScreenState extends State<HomeNeedScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  late CollectionReference<Map<String, dynamic>> collection;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = [];
  String? selectedCategory;
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String? _profileImageURL;
  bool isLoading = true;

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final userData = await getUsername(userId);

      setState(() {
        _username = userData['username']!;
        _firstName = userData['firstName']!;
        _lastName = userData['lastName']!;
      });
    }
  }

  Future<void> _fetchProfileImageURL(int index) async {
    final desteksahibiId = documents[index].data()['Destek Sahibi'];
    final profileImageURL = await getProfileImageURL(desteksahibiId);

    setState(() {
      _profileImageURL = profileImageURL;
    });
  }

  @override
  void initState() {
    super.initState();
    collection = FirebaseFirestore.instance.collection('needs');
    fetchData();
  }

  Future<void> fetchData() async {
    Query<Map<String, dynamic>> query = collection;

    if (selectedCategory != null && selectedCategory != 'Tüm Kategoriler') {
      query = query.where('anaKategori', isEqualTo: selectedCategory);
    }

    query = query.orderBy('createdAt', descending: true);

    final querySnapshot = await query.get();

    setState(() {
      documents = querySnapshot.docs.where((doc) => doc.exists).toList();
      isLoading = false;
    });
  }

  Future<Map<String, String>> getUsername(String userId) async {
    final userQuerySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: userId)
        .get();

    if (userQuerySnapshot.docs.isNotEmpty) {
      final userData = userQuerySnapshot.docs[0].data();

      final userName = userData['username'] ?? '';
      final profileImageURL = userData['profileImageURL'] ?? '';

      return {
        'username': userName,
        'profileImageURL': profileImageURL,
      };
    } else {
      return {
        'username': '',
        'profileImageURL': '',
      };
    }
  }

  Future<String> getProfileImageURL(String userId) async {
    final userQuerySnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userQuerySnapshot.exists) {
      final userData = userQuerySnapshot.data();
      final profileImageURL = userData?['profileImageURL'] as String?;
      return profileImageURL ?? '';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return documents.isEmpty
        ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.yellow,
              backgroundColor: AppColors.purple,
            ),
          )
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  key: UniqueKey(),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final data = documents[index].data();
                    final doc = documents[index];
                    final need = doc.data();
                    final needId = doc.id;
                    final anakategori = data['anaKategori'];
                    final altkategori = data['Alt Kategori'];
                    final ihtiyac = data['İhtiyaç'];
                    final ihtiyacsahibiId = data['İhtiyaç Sahibi'];
                    final il = data['city'];
                    final ilce = data['district'];
                    final tarih = data['createdAt'] as Timestamp;

                    DateTime dateTime = tarih.toDate();

                    final formattedDate =
                        DateFormat('dd MMMM y - HH:mm', 'tr_TR')
                            .format(dateTime);
                    String dayName = DateFormat.EEEE('tr_TR').format(dateTime);

                    return FutureBuilder<Map<String, String>>(
                      future: getUsername(ihtiyacsahibiId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }
                        if (snapshot.hasError) {
                          return const Text('Hata oluştu');
                        }
                        final ihtiyacsahibimail = snapshot.data ?? '';
                        final userData = snapshot.data!;
                        final destekSahibiKullaniciAdi = userData['username']!;
                        final profileImageURL = userData['profileImageURL']!;
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
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.more_vert),
                                      )
                                    ],
                                  ),
                                  Card(
                                    elevation: 5,
                                    color: Colors.grey.shade50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
                                                        CrossAxisAlignment
                                                            .start,
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
                                                      Text(ihtiyac,
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
                                                      backgroundImage: profileImageURL
                                                              .isNotEmpty
                                                          ? NetworkImage(
                                                              profileImageURL)
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
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                UsersProfile(
                                                                    userId:
                                                                        ihtiyacsahibiId)),
                                                      );
                                                    },
                                                    child: Row(
                                                      children: [
                                                        const Text(
                                                          '@',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .purple,
                                                              fontSize: 17),
                                                        ),
                                                        Text(
                                                          destekSahibiKullaniciAdi,
                                                          style: const TextStyle(
                                                              color: AppColors
                                                                  .darkGrey,
                                                              fontSize: 17,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500),
                                                        ),
                                                      ],
                                                    ),
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
                                                              NeedDetailScreen(
                                                                  needId:
                                                                      needId),
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        backgroundColor:
                                                            AppColors.purple),
                                                    child: const Text(
                                                      "Detay",
                                                      style: TextStyle(
                                                          color:
                                                              AppColors.white),
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
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.005),
                              child: const Divider(
                                color: AppColors.grey1,
                                thickness: 1.5,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
  }
}
