import 'package:bootcamp/custom_widgets/alert.dart';
import 'package:bootcamp/custom_widgets/bottom_nav_bar.dart';
import 'package:bootcamp/style/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../custom_widgets/_textformfield.dart';
import '../../../../repository/user_repository/user_repository.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final userRepository = UserRepository();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> signUp() async {
    if (passwordConfirmed()) {
      setState(() {
        isLoading = true;
      });

      try {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final user = await userRepository.addStatus(
          userCredential.user!.uid,
          usernameController.text.trim(),
          firstNameController.text.trim(),
          lastNameController.text.trim(),
          emailController.text.trim(),
          int.parse(phoneController.text.trim()),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
        print('Veriler Firestore\'a gönderildi.');
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Bilinmeyen bir hata oluştu';

        if (e.code == 'invalid-email') {
          errorMessage = 'Geçersiz e-posta formatı.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Bu e-posta adresi zaten kullanımda.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'Şifre çok zayıf. Daha güçlü bir şifre deneyin.';
        }

        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog(title: 'Hata', message: errorMessage);
          },
        );
      } catch (e) {
        print('Hata: $e');
        showDialog(
          context: context,
          builder: (context) {
            return const ErrorDialog(
              title: 'Hata',
              message: 'Bilinmeyen bir hata oluştu',
            );
          },
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool passwordConfirmed() {
    if (passwordController.text.trim() ==
        confirmPasswordController.text.trim()) {
      return true;
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const ErrorDialog(
            title: 'Hata',
            message: 'Şifreler uyuşmuyor.',
          );
        },
      );
      return false;
    }
  }

  @override
  void dispose() {
    if (mounted) {
      firstNameController.dispose();
      lastNameController.dispose();
      usernameController.dispose();
      phoneController.dispose();
      emailController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        color: Colors.grey.shade50,
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),
            AppTextFormField(
              inputType: TextInputType.name,
              controller: usernameController,
              hintText: 'Kullanıcı Adı',
              obscureText: false,
            ),
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: TextFormField(
                keyboardType:TextInputType.name,
                controller: firstNameController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: AppColors.yellow,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: AppColors.purple,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  fillColor: AppColors.white,
                  filled: true,
                  hintText: 'İsim',
                  hintStyle: const TextStyle(
                    color: AppColors.darkGrey,
                  ),
                ),
                autocorrect: false,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: TextFormField(
                keyboardType:TextInputType.name,
                controller: lastNameController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: AppColors.yellow,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: AppColors.purple,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  fillColor: AppColors.white,
                  filled: true,
                  hintText: 'Soyisim',
                  hintStyle: const TextStyle(
                    color: AppColors.darkGrey,
                  ),
                ),
                autocorrect: false,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            AppTextFormField(
              inputType: TextInputType.phone,
              controller: phoneController,
              hintText: 'Telefon',
              obscureText: false,
            ),
            SizedBox(height: screenHeight * 0.01),
            AppTextFormField(
              inputType: TextInputType.emailAddress,
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),
            SizedBox(height: screenHeight * 0.01),
            AppTextFormField(
              inputType: TextInputType.visiblePassword,
              controller: passwordController,
              hintText: 'Şifre',
              obscureText: true,
            ),
            SizedBox(height: screenHeight * 0.01),
            AppTextFormField(
              inputType: TextInputType.visiblePassword,
              controller: confirmPasswordController,
              hintText: 'Şifreyi Doğrula',
              obscureText: true,
            ),
            SizedBox(height: screenHeight * 0.01),
            GestureDetector(
              onTap: isLoading ? null : signUp,
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
                          'Kayıt Ol',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
