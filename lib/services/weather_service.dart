import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = '6dc48f39faa1ab0a90e1285972236556';

  static Future<Map<String, dynamic>> getWeatherDetails() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double lon = position.longitude;

    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final temp = data['main']['temp'];
      final condition = data['weather'][0]['main'];
      final iconCode = data['weather'][0]['icon'];
      final clouds = data['clouds']['all']; // Tambahan

      return {
        'temp': temp,
        'condition': condition,
        'iconCode': iconCode,
        'clouds': clouds,
      };
    } else {
      throw Exception('Gagal mengambil data cuaca.');
    }
  }
}
