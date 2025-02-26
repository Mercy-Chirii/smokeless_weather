import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:smokeless_weather/models/location_result_model.dart';

import 'package:smokeless_weather/utils/location_service.dart';

class LocationSearchDelegate extends SearchDelegate<LocationResult?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
      IconButton(
          onPressed: () {
            log("Just testing");
          },
          icon: Icon(MdiIcons.headCog))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text("Enter a location name"));
    }

    return FutureBuilder<List<LocationResult>>(
      future: searchLocation(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error fetching locations"));
        }
        final results = snapshot.data;
        if (results == null || results.isEmpty) {
          return Center(child: Text("No locations found"));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final location = results[index];
            return ListTile(
              title: Text(location.displayName),
              onTap: () {
                close(context, location);
              },
            );
          },
        );
      },
    );
  }
}
