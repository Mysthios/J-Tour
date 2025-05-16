import 'package:flutter/material.dart';
import 'package:j_tour/services/weather_service.dart';


class WeatherHeader extends StatefulWidget {
  const WeatherHeader({super.key});

  @override
  State<WeatherHeader> createState() => _WeatherHeaderState();
}

class _WeatherHeaderState extends State<WeatherHeader> {
  String? weather;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    final result = await WeatherService.getWeatherSummary();
    setState(() {
      weather = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.wb_sunny, color: Colors.orange),
        const SizedBox(width: 8),
        Text(weather ?? 'Loading...', style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
