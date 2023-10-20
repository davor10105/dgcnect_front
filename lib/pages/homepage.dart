import 'dart:convert';
import 'dart:math';

import 'package:country_flags/country_flags.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../components/decision_boundary.dart';
import '../components/tender_visualization.dart';
import '../components/token_importance.dart';

const List<String> list = ['00000', '00001', '00002'];
const List<String> confusionList = [
  'True Positive',
  'False Positive',
  'True Negative',
  'False Negative'
];

enum ExplainabilityType {
  LOCAL,
  GLOBAL,
}

class HomePage extends StatefulWidget {
  final dynamic currentCountry;
  final dynamic currentCountryDetails;
  final dynamic currentGlobalDetails;

  const HomePage({
    super.key,
    required this.currentCountry,
    required this.currentCountryDetails,
    required this.currentGlobalDetails,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String chosenTenderID = '';
  String chosenConfusionMatrixEntry = 'True Positive';
  ExplainabilityType currentExplainabilityType = ExplainabilityType.LOCAL;

  @override
  Widget build(BuildContext context) {
    String indexedChosenConfusionMatrixEntry =
        chosenConfusionMatrixEntry.replaceAll(' ', '');
    List<String> currentConfusionTenderList =
        ((widget.currentCountryDetails['Details']
                [indexedChosenConfusionMatrixEntry] as List)
            .map((el) => el.toString())
            .toList());
    currentConfusionTenderList.add('');

    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CountryFlag.fromCountryCode(
                  widget.currentCountry['Country2Alpha'] == 'UK'
                      ? 'GB'
                      : widget.currentCountry['Country2Alpha'],
                  height: 25,
                  width: 50,
                  borderRadius: 16,
                ),
              ),
              Text(
                widget.currentCountry['CountryName'].toUpperCase(),
                style: TextStyle(fontSize: 32),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total number of tenders: ${widget.currentCountryDetails["Metadata"]["NumExamples"]}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  width: 32,
                ),
                Text(
                  'Current number of innovative tenders: ${widget.currentCountryDetails["Metadata"]["NumInnovative"]}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  width: 32,
                ),
                Text(
                  'Current number of non-innovative tenders: ${widget.currentCountryDetails["Metadata"]["NumNonInnovative"]}',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  width: 32,
                ),
                Text(
                  'Innovative tender percent: ${(widget.currentCountryDetails["Metadata"]["NumInnovative"] / widget.currentCountryDetails["Metadata"]["NumExamples"] * 1000).round() / 10} %',
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: () {
                  setState(() {
                    currentExplainabilityType = ExplainabilityType.LOCAL;
                    chosenTenderID = '';
                  });
                },
                child: Text('Local Explainability'),
              ),
              SizedBox(
                width: 30,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent, // background
                  foregroundColor: Colors.white, // foreground
                ),
                onPressed: () {
                  setState(() {
                    currentExplainabilityType = ExplainabilityType.GLOBAL;
                    chosenTenderID = '';
                  });
                },
                child: Text('Global Explainability'),
              )
            ],
          ),
        ),
        Divider(),
        currentExplainabilityType == ExplainabilityType.LOCAL
            ? getLocalTenderChoice(currentConfusionTenderList)
            : getGlobalTenderChoice(),
        Divider(),
        //Spacer(),
      ],
    );
  }

  Widget getGlobalTenderChoice() {
    List<Widget> topList = [];
    for (var topWord in widget.currentGlobalDetails['TopWords']) {
      topList.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              topWord[0],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              (((topWord[1] as double) * 1000).roundToDouble() / 1000)
                  .toString(),
              style: TextStyle(
                color: Colors.redAccent,
              ),
            ),
            SizedBox(
              width: 50,
            ),
            InkWell(
              child: Container(
                child: Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                ),
              ),
              onTap: () {
                print(topWord[0]);
              },
            )
          ],
        ),
      );
    }

    List<Widget> botList = [];
    for (var botWord in widget.currentGlobalDetails['BottomWords']) {
      botList.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              botWord[0],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 20,
            ),
            Text(
                (((botWord[1] as double) * 1000).roundToDouble() / 1000)
                    .toString(),
                style: TextStyle(
                  color: Colors.blueAccent,
                )),
            SizedBox(
              width: 50,
            ),
            InkWell(
              child: Container(
                child: Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                ),
              ),
              onTap: () {
                print(botWord[0]);
              },
            )
          ],
        ),
      );
    }

    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(50, 0, 0, 0)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Text(
                'GLOBAL TOKEN IMPORTANCE',
                style: TextStyle(
                  color: Color.fromARGB(255, 62, 107, 255),
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: topList,
                  ),
                  Column(
                    children: botList,
                  )
                ],
              ),
            ],
          ),
        ));
  }

  Column getLocalTenderChoice(List<String> currentConfusionTenderList) {
    print('OVDJE JE ${widget.currentCountryDetails["Metadata"]}');
    if (!currentConfusionTenderList.contains(chosenTenderID)) {
      setState(() {
        chosenTenderID = '';
      });
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Choose a confusion matrix entry:'),
              SizedBox(
                width: 8,
              ),
              DropdownButton<String>(
                value: chosenConfusionMatrixEntry,
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    chosenConfusionMatrixEntry = value!;
                    chosenTenderID = '';
                    print('$chosenConfusionMatrixEntry, $chosenTenderID');
                  });
                },
                items: confusionList.map((String value) {
                  print(value);
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
              ),
              SizedBox(
                width: 20,
              ),
              Text('Choose a tender ID:'),
              SizedBox(
                width: 8,
              ),
              DropdownButton<String>(
                //initialSelection: currentConfusionTenderList.first,
                value: currentConfusionTenderList.contains(chosenTenderID)
                    ? chosenTenderID
                    : '',

                onChanged: (String? value) {
                  print(currentConfusionTenderList);
                  // This is called when the user selects an item.
                  setState(() {
                    chosenTenderID = value!;
                  });

                  print('$chosenConfusionMatrixEntry, $chosenTenderID');
                },
                items: currentConfusionTenderList.map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
              ),
            ],
          ),
        ),
        if (chosenTenderID == '')
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'images/document.png',
                          height: 300,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Please select a tender ID to visualize its results',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (chosenTenderID != '')
          Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(50, 0, 0, 0)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TenderVisualization(
                currentCountry: widget.currentCountry,
                tenderID: chosenTenderID,
              )),
        if (chosenTenderID != '')
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {},
                  backgroundColor: Color.fromARGB(255, 241, 249, 253),
                  label: Text('Innovative'),
                  icon: Icon(
                    Icons.thumb_up,
                    color: Color.fromARGB(255, 0, 110, 255),
                  ),
                ),
                FloatingActionButton.extended(
                  onPressed: () {},
                  backgroundColor: const Color.fromARGB(255, 241, 249, 253),
                  label: Text('Non-Innovative'),
                  icon: Icon(
                    Icons.thumb_down,
                    color: Colors.redAccent,
                  ),
                ),
                FloatingActionButton.extended(
                  onPressed: () {
                    int nextTenderIndex =
                        (currentConfusionTenderList.indexOf(chosenTenderID) +
                                1) %
                            currentConfusionTenderList.length;
                    setState(() {
                      if (currentConfusionTenderList[nextTenderIndex] == '') {
                        chosenTenderID = currentConfusionTenderList.first;
                      } else {
                        chosenTenderID =
                            currentConfusionTenderList[nextTenderIndex];
                      }
                    });
                  },
                  backgroundColor: const Color.fromARGB(255, 241, 249, 253),
                  label: Text('Next Tender'),
                  icon: Icon(
                    Icons.arrow_forward_outlined,
                    color: const Color.fromARGB(255, 46, 46, 46),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
