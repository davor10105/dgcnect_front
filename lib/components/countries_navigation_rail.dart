import 'dart:convert';

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../main.dart';
import '../pages/homepage.dart';
import '../settings.dart';

Future<http.Response> getCountryDetails(String country2AlphaCode) {
  print("Call Fancy Details");
  return http.post(
      Uri.parse('${DGCNECT_BACKEND_URL}/country_details/$country2AlphaCode'),
      headers: {'Access-Control-Allow-Origin': '*'});
}

Future<http.Response> getGlobalDetails(String country2AlphaCode) {
  print("Call Global Details");
  return http.post(
      Uri.parse(
          '${DGCNECT_BACKEND_URL}/dgcnect/global_explanation/$country2AlphaCode'),
      headers: {'Access-Control-Allow-Origin': '*'});
}

class CountriesNavigationAndContent extends StatefulWidget {
  final List<dynamic> supportedCountries;

  const CountriesNavigationAndContent(
      {super.key, required this.supportedCountries});

  @override
  State<CountriesNavigationAndContent> createState() =>
      _CountriesNavigationAndContentState();
}

class _CountriesNavigationAndContentState
    extends State<CountriesNavigationAndContent> {
  int selectedIndex = 0;
  dynamic currentCountryDetails;
  dynamic currentGlobalDetails;

  @override
  void initState() {
    super.initState();

    print('KURCONALASNDOANSD');

    getCountryDetails(widget.supportedCountries.first['Country2Alpha'])
        .then((result) {
      print(result);
      setState(() {
        currentCountryDetails = jsonDecode(result.body);
      });
    });

    getGlobalDetails(widget.supportedCountries.first['Country2Alpha'])
        .then((result) {
      print(result);
      setState(() {
        currentGlobalDetails = jsonDecode(result.body);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.supportedCountries.length > 1) {
      return Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.white,
            extended: true,
            destinations: [
              for (var supportedCountry in widget.supportedCountries)
                NavigationRailDestination(
                  icon: CountryFlag.fromCountryCode(
                    supportedCountry['Country2Alpha'] == 'UK'
                        ? 'GB'
                        : supportedCountry['Country2Alpha'],
                    height: 25,
                    width: 50,
                    borderRadius: 16,
                  ),
                  label: Text(supportedCountry['CountryName']),
                ),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) async {
              print('selected: ${widget.supportedCountries[value]}');
              var result = await getCountryDetails(
                  widget.supportedCountries[value]['Country2Alpha']);
              var jsonResult = jsonDecode(result.body);

              var globalResult = await getGlobalDetails(
                  widget.supportedCountries[value]['Country2Alpha']);
              var globalJsonResult = jsonDecode(globalResult.body);

              print(jsonResult);
              setState(() {
                selectedIndex = value;
                currentCountryDetails = jsonResult;
                currentGlobalDetails = globalJsonResult;
              });
            },
          ),
          currentCountryDetails == null
              ? const CircularProgressIndicator()
              : Expanded(
                  child: HomePage(
                    currentCountry: widget.supportedCountries[selectedIndex],
                    currentCountryDetails: currentCountryDetails,
                    currentGlobalDetails: currentGlobalDetails,
                  ),
                ),
        ],
      );
    }

    return currentCountryDetails == null
        ? const CircularProgressIndicator()
        : HomePage(
            currentCountry: widget.supportedCountries[selectedIndex],
            currentCountryDetails: currentCountryDetails,
            currentGlobalDetails: currentGlobalDetails,
          );
  }
}
