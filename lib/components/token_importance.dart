import 'package:flutter/material.dart';

import '../pages/homepage.dart';

class TokenImportanceContainer extends StatelessWidget {
  const TokenImportanceContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 252, 252, 253),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: Offset(2, 5), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(
          color: Color.fromARGB(255, 207, 207, 207),
        ),
      ),
      child: Column(
        children: [
          const Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Token importance',
              style: TextStyle(
                fontSize: 22,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
