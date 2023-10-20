import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:convert/convert.dart';

import 'decision_boundary.dart';
import 'token_importance.dart';

Future<http.Response> getTenderVisualization(
    String country2AlphaCode, String tenderID) {
  print("Call Fine Tender Details");
  print('$country2AlphaCode $tenderID ${tenderID.runtimeType}');
  return http.post(
    Uri.parse(
        'http://192.168.1.11:7000/dgcnect/tender_details/$country2AlphaCode/$tenderID'),
    headers: {'Access-Control-Allow-Origin': '*'},
  );
}

class TenderVisualization extends StatefulWidget {
  final dynamic currentCountry;
  final String tenderID;

  const TenderVisualization({
    super.key,
    required this.currentCountry,
    required this.tenderID,
  });

  @override
  State<TenderVisualization> createState() => _TenderVisualizationState();
}

class _TenderVisualizationState extends State<TenderVisualization> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future result = getTenderDetails();

    return FutureBuilder(
      future: result,
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        } else {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 20,
                ),
                Text('Loading data'),
              ],
            ),
          );
        }
      }),
    );
  }

  Future<Widget> getTenderDetails() async {
    var result = await getTenderVisualization(
        widget.currentCountry['Country2Alpha'], widget.tenderID);
    var jsonResult = jsonDecode(result.body);
    print(jsonResult);
    Widget wordScoreWidget = await tenderWordText(jsonResult);
    print('KOJI KURAC');

    return Column(
      children: [
        Container(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16.0, left: 128.0, right: 128.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'TOKEN IMPORTANCE',
                    style: TextStyle(
                      color: Color.fromARGB(255, 62, 107, 255),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                wordScoreWidget,
              ],
            ),
          ),
        ),
        Divider(),
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'DECISION BOUNDARY',
                style: TextStyle(
                  color: Color.fromARGB(255, 62, 107, 255),
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.memory(
                (Uint8List.fromList(hex.decode(jsonResult['Plot']))),
                height: 500,
              ),
            ),
          ],
        )
      ],
    );
  }

  Future<Widget> tenderWordText(dynamic _currentTenderDetails) async {
    List<TextSpan> retval = [];
    print('UNISAO U TENDER');
    List<dynamic> wordScoreList = _currentTenderDetails['WordScores'];
    print(wordScoreList.length);
    for (var wordScore in wordScoreList) {
      String word = wordScore[0];
      double score = wordScore[1];
      if (score > 0) {
        retval.add(TextSpan(
          text: word,
          style: TextStyle(
            //color: Colors.redAccent,
            backgroundColor:
                Color.fromARGB((255 * score.clamp(0, 1)).round(), 255, 96, 33),
          ),
        ));
      } else if (score < 0) {
        retval.add(TextSpan(
          text: word,
          style: TextStyle(
            backgroundColor: Color.fromARGB(
                (255 * score.clamp(-1, 0)).round(), 68, 138, 255),
          ),
        ));
      } else {
        retval.add(TextSpan(
          text: word,
        ));
      }
      retval.add(
        const TextSpan(text: ' '),
      );
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: retval,
      ),
    );
  }
}
