import 'package:bootcamp/screens/profile/settings/profil_bilgileri.dart';
import 'package:bootcamp/style/colors.dart';
import 'package:bootcamp/style/icons/helphub_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../auth/login_or_register/login_or_register_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Helphub.back,
            color: AppColors.purple,
          ),
        ),
        backgroundColor: AppColors.white,
        title: const Text(
          'Ayarlar',
          style: TextStyle(
            color: AppColors.purple,
            fontSize: 40,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ProfilBilgileri(),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.purple,
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  'Çıkış Yapılıyor',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    await Future.delayed(const Duration(
                      seconds: 1,
                    ));

                    FirebaseAuth.instance.signOut().then((_) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const LoginOrRegisterScreen(showLoginPage: true)),
                        (route) =>
                            false,
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "Çıkış Yap",
                      style: TextStyle(color: AppColors.white, fontSize: 25),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: const Text('Version 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }
}
