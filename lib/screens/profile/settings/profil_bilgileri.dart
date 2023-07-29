import 'dart:io';

import 'package:bootcamp/style/colors.dart';
import 'package:bootcamp/style/icons/helphub_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../repository/user_repository/user_repository.dart';

class ProfilBilgileri extends StatefulWidget {
  const ProfilBilgileri({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfilBilgileri> createState() => _ProfilBilgileriState();
}

class _ProfilBilgileriState extends State<ProfilBilgileri> {
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  File? _image;
  String? _profileImageURL;

  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

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

  Future<void> _fetchProfileImageURL() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userRef = FirebaseFirestore.instance
          .collection('pictures')
          .doc(currentUser.uid);

      try {
        final userSnapshot = await userRef.get();
        if (userSnapshot.exists) {
          final userData = userSnapshot.data();
          final profileImageURL = userData?['profileImageURL'];

          setState(() {
            _profileImageURL = profileImageURL;
          });
          
        }
        
      } catch (e) {
        print('Hata: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchProfileImageURL();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final storage = FirebaseStorage.instance;
        final storageRef = storage.ref();

        final imageRef =
            storageRef.child('Profil_resimleri/${currentUser.uid}');
        final uploadTask = imageRef.putFile(_image!);

        final snapshot = await uploadTask.whenComplete(() {});
        final downloadURL = await snapshot.ref.getDownloadURL();

        setState(() {
          _profileImageURL = downloadURL;
        });

        await _updateUserPictureData(downloadURL);
        await _updateUsersPictureData(downloadURL);
        ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Profil resminiz başarılı bir şekilde güncellendi',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 2),
      ),
    );
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _updateUserPictureData(String downloadURL) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userRef = FirebaseFirestore.instance
            .collection('pictures')
            .doc(currentUser.uid);
        await userRef
            .set({'profileImageURL': downloadURL}, SetOptions(merge: true));
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<void> _updateUsersPictureData(String downloadURL) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
        await userRef
            .set({'profileImageURL': downloadURL}, SetOptions(merge: true));
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final firstNameController = TextEditingController();
        final lastNameController = TextEditingController();
        final usernameController = TextEditingController();
        final phoneController = TextEditingController();
        final emailController = TextEditingController();

        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Profil Bilgilerini Güncelle'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children:[ Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    keyboardType:TextInputType.name,
                    controller: usernameController,
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
                      labelText: 'Yeni Kullanıcı Adınızı Giriniz',
                      labelStyle: const TextStyle(color: AppColors.purple),
                      hintText: _username,
                      hintStyle: const TextStyle(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextFormField(
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
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        fillColor: AppColors.white,
                        filled: true,
                        labelText: 'Yeni İsminizi Giriniz',
                        labelStyle: const TextStyle(color: AppColors.purple),
                        hintText: _firstName,
                        hintStyle: const TextStyle(
                          color: AppColors.darkGrey,
                        ),
                      ),
                      autocorrect: false,
                      textCapitalization: TextCapitalization.words),
                  SizedBox(height: screenHeight * 0.01),
                  TextFormField(
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
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        fillColor: AppColors.white,
                        filled: true,
                        labelText: 'Yeni Soyadınızı Giriniz',
                        labelStyle: const TextStyle(color: AppColors.purple),
                        hintText: _lastName,
                        hintStyle: const TextStyle(
                          color: AppColors.darkGrey,
                        ),
                      ),
                      autocorrect: false,
                      textCapitalization: TextCapitalization.words),
                  SizedBox(height: screenHeight * 0.01),
                  TextFormField(
                    keyboardType:TextInputType.emailAddress,
                    controller: emailController,
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
                      labelText: 'Yeni E-postanızı Giriniz',
                      labelStyle: const TextStyle(color: AppColors.purple),
                      hintText: _email,
                      hintStyle: const TextStyle(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextFormField(
                    keyboardType:TextInputType.phone,
                    controller: phoneController,
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
                      labelText: 'Yeni Telefonunuzu Giriniz',
                      labelStyle: const TextStyle(color: AppColors.purple),
                      hintText: _phone,
                      hintStyle: const TextStyle(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
              ]
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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
                child: Text('İptal'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  final userRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid);

                  try {
                    await userRef.update({
                      'username': usernameController.text,
                      'firstName': firstNameController.text,
                      'lastName': lastNameController.text,
                      'email': emailController.text,
                      'phone': int.parse(phoneController.text),
                    });

                    print('Kullanıcı verileri güncellendi');

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Profil bilgileri güncellendi'),
                          backgroundColor: Colors.green),
                    );
                    _fetchUserData();
                    Navigator.pop(context);
                  } catch (e) {
                    print('Hata: $e');
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
                child: Text('Kaydet'),
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> showImageSourceDialog() async {
    final screenHeight = MediaQuery.of(context).size.height;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Profil Resmi'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Row(
                    children: [
                      Icon(
                        Helphub.image,
                        color: AppColors.purple,
                      ),
                      SizedBox(width: 10),
                      Text('Galeri'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  child: const Row(
                    children: [
                      Icon(
                        Helphub.camera,
                        color: AppColors.purple,
                      ),
                      SizedBox(width: 10),
                      Text('Kamera'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('İptal'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth - (screenWidth - 25),
        vertical: 15,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        color: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Profil Bilgileri',
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.purple,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade50,
                        backgroundImage: _profileImageURL != null
                            ? NetworkImage(_profileImageURL!)
                            : const AssetImage(
                                    'assets/profile/user_profile.png')
                                as ImageProvider<Object>?,
                        radius: 40,
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 50,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          showImageSourceDialog();
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade50,
                          ),
                          child: const Center(
                            child: Icon(
                              Helphub.image,
                              color: AppColors.purple,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ListTile(
              leading: const Icon(
                Helphub.user_outline,
                color: AppColors.purple,
              ),
              title: const Text(
                'Kullanıcı Adı',
                style: TextStyle(color: AppColors.darkGrey),
              ),
              subtitle: Text(
                _username,
                style: const TextStyle(color: AppColors.grey3),
              ),
            ),
            ListTile(
              leading: const Icon(
                Helphub.user,
                color: AppColors.purple,
              ),
              title: const Text(
                'İsim',
                style: TextStyle(color: AppColors.darkGrey),
              ),
              subtitle: Text(
                _firstName,
                style: const TextStyle(color: AppColors.grey3),
              ),
            ),
            ListTile(
              leading: const Icon(
                Helphub.user,
                color: AppColors.purple,
              ),
              title: const Text(
                'Soyisim',
                style: TextStyle(color: AppColors.darkGrey),
              ),
              subtitle: Text(
                _lastName,
                style: const TextStyle(color: AppColors.grey3),
              ),
            ),
            ListTile(
              leading: const Icon(
                Helphub.mail,
                color: AppColors.purple,
              ),
              title: const Text(
                'E-posta Adresi',
                style: TextStyle(color: AppColors.darkGrey),
              ),
              subtitle: Text(
                _email,
                style: const TextStyle(color: AppColors.grey3),
              ),
            ),
            ListTile(
              leading: const Icon(
                Helphub.phone,
                color: AppColors.purple,
              ),
              title: const Text(
                'Telefon Numarası',
                style: TextStyle(color: AppColors.darkGrey),
              ),
              subtitle: Text(
                _phone,
                style: const TextStyle(color: AppColors.grey3),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showEditProfileDialog(context);
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
                        "Profili Güncelle",
                        style: TextStyle(color: AppColors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
