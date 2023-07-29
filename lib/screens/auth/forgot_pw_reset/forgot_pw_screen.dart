import 'package:bootcamp/custom_widgets/alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../custom_widgets/_textformfield.dart';
import '../../../style/colors.dart';

class forgotPassword extends StatefulWidget {
  const forgotPassword({
    super.key,
  });

  @override
  State<forgotPassword> createState() => _forgotPasswordState();
}

class _forgotPasswordState extends State<forgotPassword> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(
        context: context,
        builder: (context) {
          return const ErrorDialog(
              title: 'Başarılı',
              message:
                  'Şifre yenileme bağlantısı gönderildi! Lütfen e-posta adresinizi kontrol edin.');
        },
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage =
            'Bu e-posta adresi ile kayıtlı bir kullanıcı bulunamadı.';
      } else if (e.code == 'missing-email') {
        errorMessage = 'Lütfen geçerli bir e-posta adresi girin.';
      } else {
        errorMessage = 'Bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
      }
      showDialog(
        context: context,
        builder: (context) {
          return ErrorDialog(title: 'Hata', message: errorMessage);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: AppColors.purple,
        elevation: 0,
        backgroundColor: AppColors.white,
      ),
      backgroundColor: AppColors.white,
      body: SizedBox(
        height: screenHeight,
        child: SingleChildScrollView(
          child: Column(
            children: [
              //Logo
              Image.asset(
                'assets/logos/HelpHub.png',
                height: screenHeight * 0.25,
                width: screenWidth * 0.8,
              ),
              const SizedBox(
                height: 31,
              ),

              Stack(
                children: [
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.midGrey.withOpacity(0.3),
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
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    width: screenWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),
                        //Şifre sıfırlama
                        const Text(
                          "Şifre Sıfırlama",
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: AppColors.purple,
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.02,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            color: Colors.grey.shade50,
                            //email
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: screenHeight * 0.02),

                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.05),
                                  child: const Text(
                                    'Lütfen şifre yenileme bağlantısı için kayıtlı e-posta adresinizi giriniz',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppColors.darkGrey,
                                        fontSize: 16),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                AppTextFormField(
                                  inputType: TextInputType.emailAddress,
                                  controller: emailController,
                                  hintText: 'Email',
                                  obscureText: false,
                                ),

                                SizedBox(height: screenHeight * 0.01),
                                //sıfırlama butonu
                                InkWell(
                                  onTap: passwordReset,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 25),
                                    decoration: BoxDecoration(
                                      color: AppColors.purple,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      child: Text(
                                        'Şifreni Sıfırla',
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                              ],
                            ),
                          ),
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
    );
  }
}
