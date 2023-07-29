import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../repository/user_repository/user_repository.dart';
import '../../../style/colors.dart';

class BilgiGuncelleme extends StatefulWidget {
  const BilgiGuncelleme({
    super.key,
  });

  @override
  State<BilgiGuncelleme> createState() => _BilgiGuncellemeState();
}

class _BilgiGuncellemeState extends State<BilgiGuncelleme> {
  late final TextEditingController controller;
  late final String hintText;
  late final bool obscureText;

  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';

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
          _email = userData.email;
          _phone = userData.phone.toString();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
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
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Güncelle'),
            ),
          ],
        ),
      ),
    );
  }
}
