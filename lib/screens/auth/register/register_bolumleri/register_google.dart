import 'package:bootcamp/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../../../../style/colors.dart';

class RGoogleApple extends StatelessWidget {
  const RGoogleApple({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth - (screenWidth - 30),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        color: Colors.grey.shade50,
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.02,
            ),
            //google ile kayıt
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
              ),
              child: GestureDetector(
                onTap: () => AuthService().signInWithGoogle(),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.purple,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: AppColors.purple,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Image.asset(
                                'assets/logos/google.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Google ile devam et',
                                  style: TextStyle(
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(
              height: screenHeight * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}
