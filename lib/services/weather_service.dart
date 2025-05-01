import 'package:weather/weather.dart';

class WeatherService {
  static const String apiKey = '5808ef3d0bfce982ca652323944528d4'; // Ganti dengan API key-mu
  static final _weatherFactory = WeatherFactory(apiKey, language: Language.ENGLISH);

  static Future<String?> getWeatherSummary() async {
    try {
      Weather weather = await _weatherFactory.currentWeatherByCityName("Jember");
      final temp = weather.temperature?.celsius?.round() ?? 0;
      final desc = weather.weatherDescription ?? 'unknown';
      return "$temp°C, ${desc[0].toUpperCase()}${desc.substring(1)}";
    } catch (e) {
      print('Weather API error: $e');
      return null;
    }
  }
}
