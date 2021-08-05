import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slidable_text_field/slidable_text_field.dart';

class NussiTextFieldTest extends StatelessWidget {
  NussiTextFieldTest({Key? key}) : super(key: key);

  final max = 150000;
  final TextEditingController inputcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade200,
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        "Amount you want to finance:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 180,
                        child: SlidableTextField(
                          // customTextFormater: NumberFormat("\$#,##0.00", "en_US"),
                          textFormater: TextFormater.Number,
                          max: 1500000,
                          startValue: 10000,
                          controller: inputcontroller,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 60,
                ),
                Card(
                  color: Colors.blue.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Line of Credit:",
                          textScaleFactor: .9,
                          style: TextStyle(color: Colors.blueGrey.shade700),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '1,500,000 T',
                          style: TextStyle(
                              letterSpacing: .8,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
