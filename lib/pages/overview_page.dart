import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:smokeless_weather/models/tommorrow_io_weather_model.dart';
import 'package:smokeless_weather/services/location_search_delegate.dart';
import 'package:smokeless_weather/utils/get_weather_image_name.dart';
import 'package:smokeless_weather/widgets/daily_view.dart';
import 'package:smokeless_weather/widgets/hourly_view.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  OverviewPageState createState() => OverviewPageState();
}

class OverviewPageState extends State<OverviewPage> {
  late Future<TomorrowIoWeather> futureWeather;
  MinutelyHourly? selectedHour;
  Daily? selectedDay;

  String shortName(Location location) {
    List<String> nameParts = location.name.split(",");
    if (nameParts.length < 3) {
      return location.name;
    }
    List<String> newListName = [nameParts.first, nameParts.last];
    return newListName.join(', ');
  }

  Future<TomorrowIoWeather> fetchWeatherData(String query) async {
    String url = "https://api.tomorrow.io/v4/weather/forecast?location=$query&apikey=2SslbqUIwtb7NPqscYTT9wtHPkVy6JTc";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception("Failed to load weather data. Status code: ${response.statusCode}");
      }

      Map<String, dynamic> rawWeatherData;
      try {
        rawWeatherData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e, stackTrace) {
        log("Error decoding JSON: $e\n$stackTrace");
        throw Exception("JSON decoding failed: $e");
      }

      try {
        final TomorrowIoWeather weatherData = TomorrowIoWeather.fromJson(rawWeatherData);
        log("Successfully parsed weather data: $weatherData");
        return weatherData;
      } on FormatException catch (e, stackTrace) {
        log("Data format exception during conversion: $e\n$stackTrace");
        throw Exception("Data conversion failed: $e");
      } catch (e, stackTrace) {
        log("Unexpected error during model conversion: $e\n$stackTrace");
        throw Exception("Data conversion failed: $e");
      }
    } catch (error, stackTrace) {
      log("Error fetching weather data: $error\n$stackTrace");
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeatherData("Nanyuki");
  }

  String displayTime(int hour) {
    if (hour == 0 || hour == 24) {
      return "12 AM";
    } else if (hour == 12) {
      return "12 PM";
    } else if (hour < 12) {
      return "$hour PM";
    } else {
      int pmTime = hour - 12;

      return "$pmTime PM";
    }
  }

  Widget weatherFuture(BuildContext ctx, AsyncSnapshot<TomorrowIoWeather> snap) {
    if (snap.connectionState == ConnectionState.waiting) {
      return Material(
        child: Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    if (snap.hasError) {
      log("snap has error ${snap.error}");
      return Material(
        child: Center(
          child: Text("Error loading weather data"),
        ),
      );
    }
    if (snap.hasData) {
      final weatherData = snap.data!;
      return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: Text(
            shortName(weatherData.location),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () async {
                final selectedLocaton = await showSearch(context: context, delegate: LocationSearchDelegate());
                if (selectedLocaton != null) {
                  setState(() {
                    futureWeather = fetchWeatherData(selectedLocaton.displayName);
                  });

                  print("Selected location:${selectedLocaton.displayName}");
                }
              },
            )
          ],
        ),
        body: Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade200,
                      Colors.blue,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(MediaQuery.of(context).size.width / 8),
                    bottomRight: Radius.circular(MediaQuery.of(context).size.width / 8),
                  ),
                ),
                child: selectedDay != null
                    ? DailyView(daily: selectedDay ?? weatherData.timelines.daily.first)
                    : HourlyView(
                        minutelyHourly: selectedHour ?? weatherData.timelines.hourly.first,
                      ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 21, 10, 10),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today",
                            style: TextStyle(color: Colors.white, fontSize: 21),
                          ),
                          TextButton(
                            onPressed: () {
                              log("Clicked next 7 days");
                            },
                            child: Row(
                              children: [
                                Text("Next 7 Days"),
                                Icon(Icons.chevron_right),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 185,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ...weatherData.timelines.hourly.map(
                              (e) => TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.all(8)),
                                onPressed: () {
                                  log("Pressed hour column at time ${e.time.hour}");
                                  setState(() {
                                    selectedHour = e;
                                    selectedDay = null;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(17),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat.E().format(e.time),
                                        style: TextStyle(color: Colors.white30, fontSize: 16),
                                      ),
                                      Text(
                                        displayTime(e.time.hour),
                                        style: TextStyle(color: Colors.white54, fontSize: 16),
                                      ),
                                      Image.asset(
                                        "assets/img/weather_icons/${getWeatherImgName(e.minutelyHourlyValues.weatherCode)}.png",
                                        width: 80,
                                      ),
                                      Text(
                                        "${e.minutelyHourlyValues.temperature}\u00B0",
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      // Weekly values
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "This Week",
                          style: TextStyle(color: Colors.white, fontSize: 21),
                        ),
                      ),
                      SizedBox(
                        height: 185,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            ...weatherData.timelines.daily.map(
                              (e) => TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.all(8)),
                                onPressed: () {
                                  log("Pressed day column at day ${e.time.day}");
                                  setState(() {
                                    selectedDay = e;
                                    selectedHour = null;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(17),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat.E().format(e.time),
                                        style: TextStyle(color: Colors.white54, fontSize: 16),
                                      ),
                                      Image.asset(
                                        "assets/img/weather_icons/${getWeatherImgName(e.dailyValues.weatherCodeMax)}.png",
                                        width: 80,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "${e.dailyValues.temperatureMax}\u00B0",
                                            style: TextStyle(color: Colors.white, fontSize: 16),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                            child: Text(
                                              "/",
                                              style: TextStyle(color: Colors.white60, fontSize: 16),
                                            ),
                                          ),
                                          Text(
                                            "${e.dailyValues.temperatureMin}\u00B0",
                                            style: TextStyle(color: Colors.white, fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // This should not render
      return Material(
        child: Center(
          child: Text("Loading..."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: futureWeather, builder: weatherFuture);
  }
}
