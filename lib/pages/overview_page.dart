import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:smokeless_weather/models/tommorrow_io_weather_model.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late Future<TomorrowIoWeather> futureWeather;

  Future<TomorrowIoWeather> fetchWeatherData() async {
    String url =
        "https://api.tomorrow.io/v4/weather/forecast?location=nanyuki&apikey=2SslbqUIwtb7NPqscYTT9wtHPkVy6JTc";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> rawWeatherData =
          jsonDecode(response.body) as Map<String, dynamic>;
      final weatherData = TomorrowIoWeather.fromJson(rawWeatherData);
      log(weatherData.toString());
      return weatherData;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeatherData();
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureWeather,
        builder: (context, snapshot) {
          final weatherData = snapshot.data;
          if (snapshot.hasData) {
            return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Colors.black87,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                centerTitle: true,
                foregroundColor: Colors.white,
                title: const Text(
                  'Nanyuki',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
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
                            Colors.lightBlue.shade200,
                            Colors.lightBlue,
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                              MediaQuery.of(context).size.width / 8),
                          bottomRight: Radius.circular(
                              MediaQuery.of(context).size.width / 8),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "Mostly sunny",
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                      Text(
                                        "24\u00B0",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 60,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  SvgPicture.asset(
                                    "assets/svg/weather_icons/partly-cloudy-day.svg",
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/svg/weather_icons/wind-beaufort-0.svg",
                                      width: MediaQuery.of(context).size.width /
                                          10,
                                    ),
                                    Text(
                                      "9km/hr",
                                      style:
                                          TextStyle(color: Colors.grey.shade50),
                                    ),
                                    Text(
                                      "Wind",
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/svg/weather_icons/raindrop.svg",
                                      width: MediaQuery.of(context).size.width /
                                          10,
                                    ),
                                    Text(
                                      "25%",
                                      style:
                                          TextStyle(color: Colors.grey.shade50),
                                    ),
                                    Text(
                                      "Humidity",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    Text(
                                      "1.7km",
                                      style:
                                          TextStyle(color: Colors.grey.shade50),
                                    ),
                                    Text(
                                      "visibility",
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: Colors.black87,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Today",
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Row(
                                    children: [
                                      Text(
                                        "Next 7 Days",
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 140,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                ...weatherData!.timelines.hourly.map(
                                  (e) => TextButton(
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.all(0)),
                                    onPressed: () {
                                      log("Press hour column at time ${e.time.hour}");
                                    },
                                    child: Container(
                                      height: 120,
                                      width: 70,
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            displayTime(e.time.hour),
                                            style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 16),
                                          ),
                                          SvgPicture.asset(
                                            "assets/svg/weather_icons/${(e.minutelyHourlyValues.weatherCode)}.png",
                                            semanticsLabel: "Weather Icon",
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                          ),
                                          Text(
                                            "${e.minutelyHourlyValues.temperature}\u00B0",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Weekly",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 130,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Container(
                          height: 200,
                          width: 70,
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Monday",
                                  style: TextStyle(color: Colors.white)),
                              SvgPicture.asset(
                                "assets/svg/weather_icons/thunderstorms.svg",
                                semanticsLabel: "Weather Icon",
                                width: MediaQuery.of(context).size.width / 10,
                              ),
                              Text(
                                "18\u00B0",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text("$snapshot.error");
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
