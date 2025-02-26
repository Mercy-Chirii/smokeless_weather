import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:smokeless_weather/models/location_result_model.dart';

Future<List<LocationResult>> searchLocation(String query) async {
  log(query);
  final url = 'https://geocode.maps.co/search?api_key=67b70bc32baee715117833fbp556c28&q=$query';
  log(url);
  final response = await http.get(Uri.parse(url), headers: {});

  if (response.statusCode == 200) {
    log(response.body);
    final List data = jsonDecode(response.body);
    return data.map((item) => LocationResult.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load location results');
  }
}
