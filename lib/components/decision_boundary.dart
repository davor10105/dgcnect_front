import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

List<List<dynamic>> currentDecision = [
  ['kita', 0.95],
  ['kitolinica', 0.25],
  ['kurcina', -0.5]
];

Widget getHorizontalBars(List<List<dynamic>> decisions, BuildContext context) {
  double containerHeight = 20;

  List<Widget> bars = [];
  List<Widget> words = [];
  double currentValue = 0;
  for (var decision in decisions) {
    String word = decision[0];
    double value = decision[1];

    words.add(Container(
      height: containerHeight,
      child: Text(word),
    ));

    currentValue += value;
    bars.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 8,
            ),
            child: Text(
              word,
              textAlign: TextAlign.right,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 6,
              bottom: 6,
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      height: containerHeight,
                      width: value > 0
                          ? 50 * currentValue
                          : 50 * (currentValue - value),
                      decoration: BoxDecoration(
                        color: value > 0 ? Colors.redAccent : Colors.blueAccent,
                      ),
                    ),
                    Container(
                      height: containerHeight,
                      width: value > 0
                          ? 50 * (currentValue - value)
                          : 50 * currentValue,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 0, 255, 98),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                  ),
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: value > 0 ? Colors.redAccent : Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  return Placeholder();
}

class DecisionBoundaryContainer extends StatelessWidget {
  const DecisionBoundaryContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: getHorizontalBars(currentDecision, context),
    );
  }
}
