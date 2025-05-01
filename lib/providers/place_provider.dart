import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place_model.dart';

final placesProvider = FutureProvider<List<Place>>((ref) async {
  final data = await rootBundle.loadString('assets/places.json');
  final List list = json.decode(data);
  return list.map((e) => Place.fromJson(e)).toList();
});
