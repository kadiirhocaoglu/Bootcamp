import 'package:bootcamp/screens/auth/register/register_bolumleri/register_form.dart';
import 'package:bootcamp/screens/auth/register/register_bolumleri/register_google.dart';
import 'package:bootcamp/style/colors.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback ShowLoginScreen;
  const RegisterScreen({super.key, required this.ShowLoginScreen});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        height: screenHeight,
        child: SingleChildScrollView(
          child: Column(
            children: [
               SizedBox(height: screenHeight*0.086,),
              Stack(children: [
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.grey1.withOpacity(0.6),
                          spreadRadius: 4,
                          blurRadius: 15,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  width: screenWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      //Giriş Yap
                      const Text(
                        "Kayıt Ol",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),

                      const RegisterForm(),
                      // ya da
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.01,
                          horizontal: screenWidth * 0.04,
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                thickness: 2,
                                color: AppColors.purple,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                              ),
                              child: const Text(
                                "ya da",
                                style: TextStyle(
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                thickness: 2,
                                color: AppColors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),

                      //google ve apple ile giriş
                      const RGoogleApple(),

                      SizedBox(
                        height: screenHeight * 0.025,
                      ),
                      //hesabın yok mu
                      Container(
                        width: screenWidth,
                        color: AppColors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Hesabınız var mı?",
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.darkGrey,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            GestureDetector(
                              onTap: widget.ShowLoginScreen,
                              child: const Text(
                                "Giriş yap",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
