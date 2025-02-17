import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:smokeless_weather/models/tommorrow_io_weather_model.dart';
import 'package:smokeless_weather/utils/get_weather_conditions.dart';
import 'package:smokeless_weather/utils/get_weather_image_name.dart';

class HourlyView extends StatelessWidget {
  final MinutelyHourly minutelyHourly;
  const HourlyView({Key? key, required this.minutelyHourly}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top + 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: (MediaQuery.of(context).size.height / 2 - 200),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment(0, -0.7),
                    child: Text(
                      getWeatherCondition(minutelyHourly.minutelyHourlyValues.weatherCode),
                      style: TextStyle(color: Colors.white54, fontSize: 18),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, -0.5),
                    child: Text(
                      "${minutelyHourly.minutelyHourlyValues.temperature}\u00B0",
                      style: TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.w400),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      "assets/img/weather_icons/${getWeatherImgName(minutelyHourly.minutelyHourlyValues.weatherCode)}@2x.png",
                      fit: BoxFit.cover,
                      scale: 0.75,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(
                        MdiIcons.weatherWindy,
                        color: Colors.white70,
                      ),
                      Text(
                        "${minutelyHourly.minutelyHourlyValues.windSpeed}",
                        style: TextStyle(color: Colors.grey.shade50),
                      ),
                      Text(
                        "Wind",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(
                        MdiIcons.waterPercent,
                        color: Colors.white60,
                      ),
                      Text(
                        "${minutelyHourly.minutelyHourlyValues.humidity}%",
                        style: TextStyle(color: Colors.grey.shade50),
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
                        color: Colors.white54,
                        size: 20,
                      ),
                      Text(
                        "${minutelyHourly.minutelyHourlyValues.visibility}km",
                        style: TextStyle(color: Colors.grey.shade50),
                      ),
                      Text(
                        "visibility",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
