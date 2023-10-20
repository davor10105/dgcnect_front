import 'dart:convert';

import 'package:country_flags/country_flags.dart';
import 'package:dgcnect_app/settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:dgcnect_app/pages/homepage.dart';

import 'components/countries_navigation_rail.dart';
import 'components/dgcnect_appbar.dart';

void main() {
  runApp(const DGCNECTApp());
}

class DGCNECTAppState extends ChangeNotifier {
  // stores data used between pages
  String chosenTenderID = '';

  void setChosenTenderID(String newTenderID) {
    chosenTenderID = newTenderID;
    notifyListeners();
  }
}

class DGCNECTApp extends StatelessWidget {
  const DGCNECTApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DG CNECT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 30, 108, 253)),
        useMaterial3: true,
      ),
      home: const DGCNECTPage(),
    );
  }
}

enum Pages { HOMEPAGE }

Future<http.Response> getSupportedCountries() {
  print("Getting supported countries");
  return http.get(Uri.parse('${DGCNECT_BACKEND_URL}/dgcnect/countries_data'),
      headers: {'Access-Control-Allow-Origin': '*'});
}

class DGCNECTState extends ChangeNotifier {
  // stores data used between pages
  Pages currentPage = Pages.HOMEPAGE;

  void setCurrentPage(Pages newPage) {
    currentPage = newPage;
    notifyListeners();
  }
}

class DGCNECTPage extends StatefulWidget {
  const DGCNECTPage({super.key});

  @override
  State<DGCNECTPage> createState() => _DGCNECTPageState();
}

class _DGCNECTPageState extends State<DGCNECTPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<List<String>> supportedCountries = [
      ['GB', 'United Kingdom'],
      ['HR', 'Croatia'],
      ['IE', 'Ireland'],
      ['FR', 'France'],
      ['IT', 'Italy'],
    ];

    Future<http.Response> result = getSupportedCountries();
    //Map<String, dynamic> jsonResult = jsonDecode(result.body);
    //print(jsonResult);

    return FutureBuilder(
      future: result,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          dynamic supportedCountries = jsonDecode(snapshot.data!.body);
          print(supportedCountries);
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: DGCNECTAppBar(),
            body: SafeArea(
              child: CountriesNavigationAndContent(
                  supportedCountries: supportedCountries),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: DGCNECTAppBar(),
            body: const SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.stop_circle_outlined,
                      color: Colors.redAccent,
                      size: 100,
                    ),
                    Text('Failed to reach backend'),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: DGCNECTAppBar(),
          body: const SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('Loading country data'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
