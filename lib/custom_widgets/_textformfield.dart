import 'package:bootcamp/style/colors.dart';
import 'package:flutter/material.dart';

class AppTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
   final TextInputType inputType;

  const AppTextFormField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText, required this.inputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: TextFormField(
        keyboardType: inputType,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          fillColor: AppColors.white,
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.darkGrey,
          ),
        ),
      ),
    );
  }
}
