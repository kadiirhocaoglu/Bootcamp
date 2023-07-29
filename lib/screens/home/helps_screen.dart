import 'package:bootcamp/style/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'maps.dart';

class HelpsScreen extends StatefulWidget {
  const HelpsScreen({super.key});

  @override
  _HelpsScreenState createState() => _HelpsScreenState();
}

class _HelpsScreenState extends State<HelpsScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  String? selectedCategory;
  String? selectedSubcategory;
  String? selectedUnit;
  String? selectedCity;
  String? selectedDistrict;

  TextEditingController destekController = TextEditingController();
  TextEditingController miktarController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    destekController.dispose();
    miktarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        title: const Text(
          'Yardım Oluştur',
          style: TextStyle(fontSize: 25),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, vertical: screenHeight * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.grey.shade50,
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.01),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategori Seçin',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.purple),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      DropdownButton<String>(
                        value: selectedCategory,
                        hint: const Text('Kategori Seçin',
                            style: TextStyle(color: AppColors.darkGrey)),
                        isExpanded: true,
                        onChanged: (newValue) {
                          setState(() {
                            selectedCategory = newValue;
                            selectedSubcategory = null;
                          });
                        },
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(color: AppColors.darkGrey),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Alt Kategori Seçin',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.purple),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: selectedSubcategory,
                        hint: const Text(
                          'Alt Kategori Seçin',
                          style: TextStyle(color: AppColors.darkGrey),
                        ),
                        isExpanded: true,
                        onChanged: (newValue) {
                          setState(() {
                            selectedSubcategory = newValue;
                          });
                        },
                        items: selectedCategory != null
                            ? subcategories[selectedCategory!]!
                                .map((subcategory) {
                                return DropdownMenuItem<String>(
                                  value: subcategory,
                                  child: Text(
                                    subcategory,
                                    style: const TextStyle(
                                        color: AppColors.darkGrey),
                                  ),
                                );
                              }).toList()
                            : [],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.grey.shade50,
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.01,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Şehir Seçin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      DropdownButton<String>(
                        value: selectedCity,
                        hint: const Text(
                          'Şehir Seçin',
                          style: TextStyle(color: AppColors.darkGrey),
                        ),
                        isExpanded: true,
                        onChanged: (newValue) {
                          setState(() {
                            selectedCity = newValue;
                            selectedDistrict = null;
                          });
                        },
                        items: sehirler.map((city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Text(
                              city,
                              style: const TextStyle(color: AppColors.darkGrey),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      const Text(
                        'İlçe Seçin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      DropdownButton<String>(
                        value: selectedDistrict,
                        hint: const Text(
                          'İlçe Seçin',
                          style: TextStyle(color: AppColors.darkGrey),
                        ),
                        isExpanded: true,
                        onChanged: (newValue) {
                          setState(() {
                            selectedDistrict = newValue;
                          });
                        },
                        items: ilceler[selectedCity] != null
                            ? ilceler[selectedCity]!.map((ilceler) {
                                return DropdownMenuItem<String>(
                                  value: ilceler,
                                  child: Text(
                                    ilceler,
                                    style: const TextStyle(
                                        color: AppColors.darkGrey),
                                  ),
                                );
                              }).toList()
                            : [],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      const Text(
                        'Adres Detayı',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      TextFormField(
                        keyboardType: TextInputType.streetAddress,
                        controller: addressController,
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          fillColor: AppColors.white,
                          filled: true,
                          hintText: 'Adresinizi Giriniz',
                          hintStyle: const TextStyle(
                            color: AppColors.darkGrey,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.grey.shade50,
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.01,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Birim',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      DropdownButton<String>(
                        value: selectedUnit,
                        hint: const Text('Birim Seçin',
                            style: TextStyle(color: AppColors.darkGrey)),
                        isExpanded: true,
                        onChanged: (newValue) {
                          setState(() {
                            selectedUnit = newValue;
                          });
                        },
                        items: units.map((unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      const Text(
                        'Miktar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: miktarController,
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          fillColor: AppColors.white,
                          filled: true,
                          hintText: 'Miktar Giriniz',
                          hintStyle: const TextStyle(
                            color: AppColors.darkGrey,
                          ),
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Ne Konuda Destek Olabilirsin?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.purple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        controller: destekController,
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          fillColor: AppColors.white,
                          filled: true,
                          hintText: 'Yardımınızı Yazın',
                          hintStyle: const TextStyle(
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedCategory == null ||
                              selectedSubcategory == null ||
                              selectedUnit == null ||
                              selectedCity == null ||
                              selectedDistrict == null ||
                              destekController.text.isEmpty ||
                              miktarController.text.isEmpty ||
                              addressController.text.isEmpty) {

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Lütfen tüm alanları doldurun.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            String category = selectedCategory ?? '';
                            String subcategory = selectedSubcategory ?? '';
                            String unit = selectedUnit ?? '';
                            String destek = destekController.text;
                            String miktar = miktarController.text;
                            String city = selectedCity ?? '';
                            String district = selectedDistrict ?? '';
                            String address = addressController.text;
                            print('Kategori: $category');
                            print('Alt Kategori: $subcategory');
                            print('city: $city');
                            print('district: $district');
                            print('adres: $address');
                            print('Birim: $unit');
                            print('Destek: $destek');
                            print('Miktar: $miktar');

                            FirebaseFirestore firestore =
                                FirebaseFirestore.instance;
                            CollectionReference destekler =
                                firestore.collection('helps');

                            try {
                              await destekler.add({
                                'Destek Sahibi': user.uid,
                                'Ana Kategori': category,
                                'Alt Kategori': subcategory,
                                'city': selectedCity,
                                'district': selectedDistrict,
                                'address': address,
                                'createdAt': DateTime.now(),
                                'Birim': unit,
                                'Miktar': miktar,
                                'Destek': destek,
                              });
                              print('Veri Firestore\'a başarıyla eklendi.');
                              destekController.clear();
                              miktarController.clear();
                              addressController.clear;

                              setState(() {
                                selectedCategory = null;
                                selectedSubcategory = null;
                                selectedUnit = null;
                                selectedCity = null;
                                selectedDistrict = null;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text(
                                    'Yardımınız başarılı bir şekilde gönderildi.',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } catch (e) {
                              print('Veri eklenirken bir hata oluştu: $e');
                            }
                          }
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
                            "Yardımı Gönder",
                            style:
                                TextStyle(color: AppColors.white, fontSize: 25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
