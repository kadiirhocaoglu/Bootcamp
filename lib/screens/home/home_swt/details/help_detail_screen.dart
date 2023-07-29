import 'package:bootcamp/screens/chat_screen/chat_screen.dart';
import 'package:bootcamp/screens/home/home_swt/details/users_profile/users_profile.dart';
import 'package:bootcamp/style/colors.dart';
import 'package:bootcamp/style/icons/helphub_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../repository/user_repository/messaging_service.dart';

class HelpDetailScreen extends StatefulWidget {
  final String helpId;

  const HelpDetailScreen({Key? key, required this.helpId}) : super(key: key);

  @override
  State<HelpDetailScreen> createState() => _HelpDetailScreenState();
}

class _HelpDetailScreenState extends State<HelpDetailScreen> {
  Map<String, dynamic>? helpData;
  String destekSahibiKullaniciAdi = '';
  String destekSahibiIsim = '';
  String destekSahibiSoyad = '';
  String destekSahibiTelefon = '';
  String destekSahibiProfilResmi = '';
  LatLng? helpLocation;
  final MessagingService _messagingService = MessagingService();

  @override
  void initState() {
    super.initState();
    fetchHelpData();
  }

  Future<void> fetchHelpData() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('helps')
        .doc(widget.helpId)
        .get();

    if (docSnapshot.exists) {
      final helpData = docSnapshot.data() ?? {};
      final desteksahibiId = helpData['Destek Sahibi'];

      if (desteksahibiId != null) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(desteksahibiId)
            .get();

        if (userSnapshot.exists) {
          final userData = userSnapshot.data() ?? {};
          final il = helpData['city'];
          final ilce = helpData['district'];
          final adres = helpData['address'];

          final helpLocation = adres != null && ilce != null && il != null
              ? await convertAddressToLocation(adres, ilce, il)
              : const LatLng(41.005, 28.978);

          setState(() {
            this.helpData = helpData;
            destekSahibiKullaniciAdi = userData['username'] ?? '';
            destekSahibiIsim = userData['firstName'] ?? '';
            destekSahibiSoyad = userData['lastName'] ?? '';
            destekSahibiTelefon = userData['phone']?.toString() ?? '';
            destekSahibiProfilResmi = userData['profileImageURL'] ?? '';
            this.helpLocation = helpLocation;
          });
        }
      }
    }
  }

  Future<LatLng> convertAddressToLocation(
      String address, String district, String city) async {
    final query = "$address, $district, $city";
    List<Location> locations = await locationFromAddress(query);

    if (locations.isNotEmpty) {
      final location = locations.first;
      return LatLng(location.latitude, location.longitude);
    }

    return const LatLng(41.005, 28.978);
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> _createMarkers() {
      final markers = <Marker>{};

      if (helpLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('helpLocation'),
            position: helpLocation!,
          ),
        );
      }

      return markers;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (helpData == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.purple,
          title: const Text('Yardım Detayı'),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.yellow,
            backgroundColor: AppColors.purple,
          ),
        ),
      );
    } else {
      final anakategori = helpData!['Ana Kategori'];
      final altkategori = helpData!['Alt Kategori'];
      final destek = helpData!['Destek'];
      final birim = helpData!['Birim'];
      final miktar = helpData!['Miktar'];
      final desteksahibiId = helpData!['Destek Sahibi'];
      final il = helpData!['city'];
      final ilce = helpData!['district'];
      final adres = helpData!['address'];
      final tarih = helpData!['createdAt'] as Timestamp;
      DateTime dateTime = tarih.toDate();

      final formattedDate =
          DateFormat('dd MMMM EEEE HH:mm', 'tr_TR').format(dateTime);

      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Yardım Detayı',
              style: TextStyle(color: AppColors.purple, fontSize: 25),
            ),
            iconTheme: const IconThemeData(color: AppColors.purple),
            leading: IconButton(
              icon: const Icon(Helphub.back),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: SafeArea(
          child: Column(
            children: [
              const Divider(
                thickness: 3,
                color: AppColors.purple,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth - (screenWidth - 25)),
                child: Card(
                  elevation: 5,
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.02),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                anakategori + '/ ' + altkategori,
                                style: const TextStyle(
                                    color: AppColors.darkGrey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(
                                height: screenHeight * 0.01,
                              ),
                              Text(
                                miktar + ' ' + birim + ' ' + destek,
                                style: const TextStyle(
                                    color: AppColors.purple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth - (screenWidth - 25)),
                child: Card(
                  elevation: 5,
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '📆 ',
                              style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.01,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '📍 ',
                              style: TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start,
                            ),
                            Text(
                              "$ilce, $il",
                              style: const TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth - (screenWidth - 25)),
                child: Card(
                  elevation: 5,
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.01),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.purple, width: 3)),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(7),
                            ),
                            child: SizedBox(
                              height: screenHeight * 0.2,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: helpLocation!,
                                  zoom: 10,
                                ),
                                markers: _createMarkers(),
                                myLocationButtonEnabled: false,
                                myLocationEnabled: false,
                                mapType: MapType.normal,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.01,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$ilce, $il",
                              style: const TextStyle(
                                  color: AppColors.darkGrey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(
                              width: screenWidth * 0.03,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final url =
                                      'https://www.google.com/maps/dir/?api=1&destination=$adres,$ilce,$il';
                                  launchUrl(Uri.parse(url));
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
                                    "Yol Tarifi Al",
                                    style: TextStyle(
                                        color: AppColors.white, fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UsersProfile(userId: desteksahibiId)),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth - (screenWidth - 25)),
                        child: Card(
                          elevation: 5,
                          color: Colors.grey.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                                vertical: screenHeight * 0.02),
                            child: Row(
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
                                    backgroundImage: destekSahibiProfilResmi
                                            .isNotEmpty
                                        ? NetworkImage(destekSahibiProfilResmi)
                                        : const AssetImage(
                                                'assets/profile/user_profile.png')
                                            as ImageProvider<Object>?,
                                    radius: 25,
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.03,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$destekSahibiIsim $destekSahibiSoyad',
                                        style: const TextStyle(
                                          color: AppColors.darkGrey,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.005,
                                      ),
                                      Text(
                                        '@$destekSahibiKullaniciAdi',
                                        style: const TextStyle(
                                          color: AppColors.purple,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Helphub.next,
                                  color: AppColors.purple,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth - (screenWidth - 25)),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('İletişime Geç'),
                                        content: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                final Uri url = Uri(
                                                  scheme: 'tel',
                                                  path: destekSahibiTelefon,
                                                );
                                                await launchUrl(url);
                                                Navigator.pop(context);
                                              },
                                               style: ElevatedButton.styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      backgroundColor:
                                                          AppColors.purple),
                                                  child: const Text(
                                                    "Ara",
                                                    style: TextStyle(
                                                        color: AppColors.white),
                                                  ),
                                                ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatScreen(
                                                      recipientId:
                                                          desteksahibiId,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  backgroundColor:
                                                      AppColors.purple),
                                              child: const Text(
                                                "Mesaj gönder",
                                                style: TextStyle(
                                                    color: AppColors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
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
                                    "Talep et",
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 25,
                                    ),
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
            ],
          ),
        ),
      );
    }
  }
}
