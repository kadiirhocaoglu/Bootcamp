import 'package:bootcamp/screens/home/home_swt/home_help.dart';
import 'package:bootcamp/screens/home/home_swt/home_need.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../repository/user_repository/messaging_service.dart';
import '../../style/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  final user = FirebaseAuth.instance.currentUser!;
  final userid = FirebaseAuth.instance.currentUser!.uid;
  late CollectionReference<Map<String, dynamic>> collection;
  List<DocumentSnapshot<Map<String, dynamic>>> documents = [];
  TabController? _tabController;
  int selectedCategory = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    collection = FirebaseFirestore.instance.collection('needs');
    _tabController = TabController(length: 2, vsync: this);
    fetchData();
  }

  Future<void> fetchData() async {
    Query<Map<String, dynamic>> query = collection;

    if (selectedCategory != 'Tüm Kategoriler') {
      query = query.where('Ana Kategori', isEqualTo: selectedCategory);
    }

    query = query.orderBy('createdAt', descending: true);

    final querySnapshot = await query.get();
    setState(() {
      documents =
          querySnapshot.docs.where((doc) => doc.data() != null).toList();
      _isLoading = false;
    });
  }

  Future<String> getUsername(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      final firstName = userData['firstName'] ?? '';
      final lastName = userData['lastName'] ?? '';
      return '$firstName $lastName';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final MessagingService messagingService = MessagingService();
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'En Son Yardımlar' : 'En Son İhtiyaçlar',
          style: const TextStyle(fontSize: 25),
        ),
        backgroundColor:
            _selectedIndex == 0 ? AppColors.purple : AppColors.yellow,
        elevation: 0,
        
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [HomeHelpScreen(), HomeNeedScreen()],
            ),
          ),
          Container(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.grey.shade50,
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth - (screenWidth - 10),
                          vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = 0;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedIndex == 0
                                      ? AppColors.purple
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _selectedIndex == 0
                                        ? Colors.transparent
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: screenWidth * 0.02),
                                  child: Text(
                                    'En Son Yardımlar',
                                    style: TextStyle(
                                      color: _selectedIndex == 0
                                          ? AppColors.white
                                          : AppColors.purple,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = 1;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedIndex == 1
                                      ? Colors.yellow
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _selectedIndex == 0
                                        ? Colors.grey.shade300
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: screenWidth * 0.02),
                                  child: Text(
                                    'En Son İhtiyaçlar',
                                    style: TextStyle(
                                      color: _selectedIndex == 1
                                          ? AppColors.white
                                          : Colors.yellow,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
