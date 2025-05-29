import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:j_tour/models/place_model.dart';
import 'package:j_tour/pages/homepage/widgets/bottom_navbar.dart';
import 'package:j_tour/pages/homepage/widgets/place_card.dart';
import 'package:j_tour/pages/homepage/widgets/popular_place_card.dart';
import 'package:j_tour/pages/homepage/widgets/weather_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Place> places = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    final data = await rootBundle.loadString('assets/places.json');
    final List list = json.decode(data);
    setState(() {
      places = list.map((e) => Place.fromJson(e)).toList();
    });
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final horizontalPadding = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.045;
    final logoHeight = screenHeight * 0.06;
    final weatherHeight = screenHeight * 0.055;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: screenHeight * 0.11,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(left: horizontalPadding * 0.5, right: horizontalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Transform.translate(
                offset: const Offset(-5, 0),  // geser ke kiri 5 pixel
                child: Image.asset(
                  'assets/images/Label.jpg',
                  height: logoHeight,
                ),
              ),
              SizedBox(
                height: weatherHeight,
                child: const WeatherHeader(),
              ),
            ],
          ),
        ),

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Wisata Populer",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Lihat Semua"),
                ),
              ],
            ),
            SizedBox(
              height: screenHeight * 0.26,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: places.length > 2 ? 2 : places.length,
                itemBuilder: (context, index) {
                  return PopularPlaceCard(place: places[index]);
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rekomendasi Untuk Anda",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Lihat Semua"),
                ),
              ],
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: places.length,
              itemBuilder: (context, index) {
                return PlaceCard(place: places[index]);
              },
            ),
            SizedBox(height: screenHeight * 0.04),
          ],
        ),
      ),
    );
  }
}
