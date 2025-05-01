import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/weather_service.dart';

final weatherProvider = FutureProvider<String?>((ref) async {
  return await WeatherService.getWeatherSummary();
});
