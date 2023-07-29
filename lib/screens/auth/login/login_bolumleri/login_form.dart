import 'package:bootcamp/custom_widgets/alert.dart';
import 'package:bootcamp/custom_widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../custom_widgets/_textformfield.dart';
import '../../../../style/colors.dart';
import '../../forgot_pw_reset/forgot_pw_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
  });

  @override
  State<LoginForm> createState() => _GirisFormState();
}

class _GirisFormState extends State<LoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
       Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MyHomePage()),
  );
    } on FirebaseAuthException catch (e) {
      print('Hata: $e');
      String errorMessage = 'Bilinmeyen bir hata oluştu';

      if (e.code == 'invalid-email') {
        errorMessage = 'Geçersiz e-posta formatı.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'Kullanıcı bulunamadı.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'E-posta veya şifre yanlış.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Kullanıcı hesabı devre dışı bırakıldı.';
      } else if (e.code == 'too-many-requests') {
        errorMessage =
            'Çok fazla istek yapıldı. Lütfen daha sonra tekrar deneyin.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Bu işlem izin verilmiyor.';
      } else {
        errorMessage = 'Bir hata oluştu: ${e.message}';
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          print('Hata: $e');
          return ErrorDialog(
            title: 'Hata',
            message: errorMessage,
          );
        },
      );
    } catch (e) {
      print('Hata: $e');
      const ErrorDialog(title: 'Hata', message: 'Bilinmeyen bir hata oluştu');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
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
          children: [
            SizedBox(height: screenHeight * 0.02),
            AppTextFormField(
              inputType: TextInputType.emailAddress,
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),
            SizedBox(height: screenHeight * 0.01),
            //şifre
            AppTextFormField(
              inputType: TextInputType.visiblePassword,
              controller: passwordController,
              hintText: 'Şifre',
              obscureText: true,
            ),
            SizedBox(height: screenHeight * 0.01),
            //şifrenizi mi unuttunuz?
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) {
                            return const forgotPassword();
                          }),
                        ),
                      );
                    },
                    child: const Text(
                      'Şifrenizi mi unuttunuz?',
                      style: TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            //giriş yap butonu
            GestureDetector(
              onTap: isLoading ? null : signIn,
              child: Container(
                padding: 
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: isLoading ? AppColors.purple : AppColors.purple,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                          ),
                        )
                      : const Text(
                          'Giriş Yap',
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
    );
  }
}
