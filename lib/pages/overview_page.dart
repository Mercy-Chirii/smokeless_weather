import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:smokeless_weather/models/tommorrow_io_weather_model.dart';
import 'package:smokeless_weather/utils/get_weather_image_name.dart';
import 'package:smokeless_weather/widgets/daily_view.dart';
import 'package:smokeless_weather/widgets/hourly_view.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
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

  Future<TomorrowIoWeather> fetchWeatherData() async {
    String url = "https://api.tomorrow.io/v4/weather/forecast?location=nanyuki&apikey=2SslbqUIwtb7NPqscYTT9wtHPkVy6JTc";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> rawWeatherData = jsonDecode(response.body) as Map<String, dynamic>;
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
                title: Text(
                  shortName(weatherData!.location),
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
                            bottomLeft: Radius.circular(MediaQuery.of(context).size.width / 8),
                            bottomRight: Radius.circular(MediaQuery.of(context).size.width / 8),
                          ),
                        ),
                        child: selectedDay == null
                            ? DailyView(daily: selectedDay ?? weatherData.timelines.daily.first)
                            : HourlyView(minutelyHourly: selectedHour ?? weatherData.timelines.hourly.first)),
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
                            height: 185,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                ...weatherData.timelines.hourly.map(
                                  (e) => TextButton(
                                    style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                                    onPressed: () {
                                      log("Press hour column at time ${e.time.hour}");
                                      setState(() {
                                        selectedHour = e;
                                        selectedDay = null;
                                      });
                                    },
                                    child: Container(
                                      height: 120,
                                      width: 70,
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat.E().format(e.time),
                                            style: TextStyle(color: Colors.white54),
                                          ),
                                          Text(
                                            displayTime(e.time.hour),
                                            style: TextStyle(color: Colors.white54, fontSize: 16),
                                          ),
                                          Image.asset(
                                            "assets/img/weather_icons/${getWeatherImgName(e.minutelyHourlyValues.weatherCode)}.png",
                                            width: MediaQuery.of(context).size.width / 10,
                                          ),
                                          Text(
                                            "${e.minutelyHourlyValues.temperature}\u00B0",
                                            style: TextStyle(
                                                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
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
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  "This week",
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
                    height: 170,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ...weatherData.timelines.daily.map(
                          (e) => TextButton(
                            style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                            onPressed: () {
                              log("Press column for ${DateFormat.E().format(e.time)}");
                              setState(() {
                                selectedHour = null;
                                selectedDay = e;
                              });
                            },
                            child: Container(
                              height: 120,
                              width: 70,
                              margin: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat.E().format(e.time),
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                                  ),
                                  Text(
                                    DateFormat.MMMd().format(e.time),
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                                  ),
                                  Image.asset(
                                    "assets/img/weather_icons/${getWeatherImgName(e.dailyValues.weatherCodeMax)}.png",
                                    width: MediaQuery.of(context).size.width / 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "${e.dailyValues.temperatureMin}\u00B0",
                                        style:
                                            TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        "/",
                                        style:
                                            TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        "${e.dailyValues.temperatureMax}\u00B0",
                                        style:
                                            TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
