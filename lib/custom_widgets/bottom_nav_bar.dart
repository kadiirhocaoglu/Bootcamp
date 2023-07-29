import 'package:bootcamp/screens/home/helps_screen.dart';
import 'package:bootcamp/screens/home/home_screen.dart';
import 'package:bootcamp/screens/home/needs_screen.dart';
import 'package:bootcamp/screens/profile/profile_screen.dart';
import 'package:bootcamp/style/colors.dart';
import 'package:bootcamp/style/icons/helphub_icons.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const HelpsScreen(),
    const NeedsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            height: 0,
            thickness: 3,
            color: AppColors.purple,
          ),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: _selectedIndex == 0
                    ? const Icon(
                        Helphub.home,
                      )
                    : const Icon(Helphub.home_outline),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: _selectedIndex == 1
                    ? const Icon(
                        Helphub.help,
                      )
                    : const Icon(
                        Helphub.help_outline,
                      ),
                label: 'Yardım',
              ),
              BottomNavigationBarItem(
                icon: _selectedIndex == 2
                    ? const Icon(
                        Helphub.need,
                      )
                    : const Icon(
                        Helphub.need_outline,
                      ),
                label: 'İhtiyaç',
              ),
              BottomNavigationBarItem(
                icon: _selectedIndex == 3
                    ? const Icon(
                        Helphub.user,
                      )
                    : const Icon(
                        Helphub.user_outline,
                      ),
                label: 'Profil',
              ),
            ],
            selectedItemColor: AppColors.purple,
            unselectedItemColor: AppColors.darkGrey,
            selectedFontSize: 17,
            unselectedFontSize: 14,
            selectedIconTheme: const IconThemeData(size: 32),
            unselectedIconTheme: const IconThemeData(size: 25),
            backgroundColor: Colors.grey.shade50,
            type: BottomNavigationBarType.fixed,
          ),
        ],
      ),
    );
  }
}
