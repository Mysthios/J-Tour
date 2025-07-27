import 'package:flutter/material.dart';
import 'package:j_tour/services/weather_service.dart';

class WeatherHeader extends StatefulWidget {
  const WeatherHeader({super.key});

  @override
  State<WeatherHeader> createState() => _WeatherHeaderState();
}

class _WeatherHeaderState extends State<WeatherHeader> {
  double? temperature;
  String? condition;
  String? iconCode;
  int? cloudiness;

  final Map<String, String> weatherTranslation = {
    'Clear': 'Cerah',
    'Clouds': 'Berawan',
    'Rain': 'Hujan',
    'Drizzle': 'Gerimis',
    'Thunderstorm': 'Badai Petir',
    'Snow': 'Salju',
    'Mist': 'Berkabut',
    'Smoke': 'Asap',
    'Haze': 'Kabut Asap',
    'Dust': 'Berdebu',
    'Fog': 'Kabut',
    'Sand': 'Bersandstorm',
    'Ash': 'Abu Vulkanik',
    'Squall': 'Angin Kencang',
    'Tornado': 'Tornado',
  };

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    try {
      final weatherData = await WeatherService.getWeatherDetails();
      setState(() {
        temperature = weatherData['temp'];
        condition = weatherData['condition'];
        iconCode = weatherData['iconCode'];
        cloudiness = weatherData['clouds'];
      });
    } catch (e) {
      debugPrint('Error loading weather: $e');
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String getSmartCondition(String? condition, int? cloudiness) {
    if (condition == null) return '-';

    // Smart logic: override if cloudiness is low
    if (condition == 'Clouds' && (cloudiness ?? 100) < 30) {
      return 'Berawan';
    } else if (condition == 'Clear' && (cloudiness ?? 0) > 50) {
      return 'Cerah';
    }

    return weatherTranslation[condition] ?? condition;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        iconCode != null
            ? Image.network(
                'https://openweathermap.org/img/wn/$iconCode@2x.png',
                width: 55,
                height: 55,
              )
            : const SizedBox(width: 55, height: 55),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              temperature != null
                  ? '${temperature!.round()}°C  ${getSmartCondition(condition, cloudiness)}'
                  : 'Memuat...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              getGreeting(),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
