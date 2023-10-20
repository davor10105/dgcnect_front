import 'package:flutter/material.dart';

AppBar DGCNECTAppBar() {
  return AppBar(
    scrolledUnderElevation: 0.0,
    toolbarHeight: 150,
    backgroundColor: Colors.white,
    title: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            child: Image.asset('images/european_commission.png'),
          ),
          SizedBox(
            width: 64,
          ),
          Text(
            'DG CNECT - DG for Communications Networks, Content and Technology',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ],
      ),
    ),
  );
}
