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
  int _currentIndex = 0; // ✅ Tambahkan ini

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

  // ✅ Fungsi ini untuk handle tap pada BottomNavBar
  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Tambahkan navigasi sesuai kebutuhan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const WeatherHeader(),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Popular Place",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: places.length,
                itemBuilder: (context, index) {
                  return PopularPlaceCard(place: places[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Recommendation",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: places.length,
              itemBuilder: (context, index) {
                return PlaceCard(place: places[index]);
              },
            ),
          ],
        ),
      ),
      // bottomNavigationBar: CustomBottomNavBar(
      //   currentIndex: _currentIndex, // ✅ gunakan variabel ini
      //   onTap: _onNavBarTap, // ✅ dan fungsi ini
      // ),
    );
  }
}
