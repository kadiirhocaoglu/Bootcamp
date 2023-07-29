import 'package:bootcamp/screens/profile/profil_ihtiyaclar.dart';
import 'package:bootcamp/screens/profile/profil_yardimlar.dart';
import 'package:bootcamp/style/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CategorySwitcherWidget extends StatefulWidget {
  const CategorySwitcherWidget({super.key});

  @override
  _CategorySwitcherWidgetState createState() => _CategorySwitcherWidgetState();
}

class _CategorySwitcherWidgetState extends State<CategorySwitcherWidget> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth - (screenWidth - 35), vertical: 15),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.grey.shade50,
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth - (screenWidth - 10), vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
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
                              vertical: 5, horizontal: screenWidth * 0.02),
                          child: Text(
                            'Yardımlar',
                            style: TextStyle(
                              color: _selectedIndex == 0
                                  ? AppColors.white
                                  : AppColors.purple,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
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
                              vertical: 5, horizontal: screenWidth * 0.02),
                          child: Text(
                            'İhtiyaçlar',
                            style: TextStyle(
                              color: _selectedIndex == 1
                                  ? AppColors.white
                                  : Colors.yellow,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            color: AppColors.grey1,
            thickness: 1.5,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    ProfilYardimlar(currentUserEmail: user.uid),
                    ProfilIhtiyaclar(
                      currentUserEmail: user.uid,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
