import 'package:http/http.dart' as http;

void testWeatherKey() async {
  const apiKey = '538f670b20422b50a18460eeebe4afb3';
  final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=Jember&appid=$apiKey&units=metric');
  final response = await http.get(url);

  print('Status code: ${response.statusCode}');
  print('Body: ${response.body}');
}
