import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:slidable_text_field/src/defult_fomater_types.dart';

import 'enums.dart';
import 'leaf_text_field.dart';

class SlidableTextField extends StatelessWidget {
  SlidableTextField(
      {Key? key,
      NumberFormat? customTextFormater,
      TextFormater? textFormater,
      this.textDirection = TextDirection.ltr,
      required this.max,
      final double startValue = 0,
      required this.controller})
      : assert(customTextFormater == null && textFormater != null ||
            customTextFormater != null && textFormater == null),
        // assert(customTextFormater != null && textFormater == null),
        super(key: key) {
    formater = customTextFormater ?? getFormater(textFormater!);
    value = startValue;
  }
  late final NumberFormat formater;
  final double max;
  final TextDirection textDirection;
  final TextEditingController controller;
  final ValueNotifier<int> percent = ValueNotifier(0);
  final ValueNotifier<double> currentValue = ValueNotifier(0);
  // String oldValue = '';

  set value(double? newValue) {
    if (newValue == null) return;
    final cleanValue = double.parse(newValue.toStringAsFixed(2));
    final formattedText = formater.format(cleanValue.clamp(0, max));
    final currentTextOffset = controller.selection.baseOffset;
    final newSymbols = findNewSymbols(formattedText, controller.text);
    controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(
            offset: (currentTextOffset + newSymbols)
                .clamp(0, formattedText.length)));
    currentValue.value = (cleanValue / max).clamp(0, 1);
    percent.value = (cleanValue * 100 ~/ max).clamp(0, 100);
  }

  int findNewSymbols(String a, String b) {
    a = a.replaceAll(RegExp(r'[^0-9 .]'), 's');
    b = b.replaceAll(RegExp(r'[^0-9 .]'), 's');
    return a.characters.where((char) => char == 's').length -
        b.characters.where((char) => char == 's').length;
  }

  // download

  void reset() {
    currentValue.value = 0;
    percent.value = 0;
    controller.clear();
  }

  void onTextFieldChanged(String newString) {
    final cleanString = newString
        .replaceAll('\$', '')
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^ 0-9 , .]'), '');

    double? cleanDouble = double.tryParse(cleanString);
    if (cleanDouble == null) {
      reset();
      return;
    }
    if (currentValue.value == 0) {
      if (newString.contains('\$')) cleanDouble *= 1 / 10;
      // cleanDouble = cleanDouble.floorToDouble();
    } else if (cleanDouble.ceil() >= (currentValue.value * max).ceil() * 99) {
      cleanDouble *= 1 / 100;
      // cleanDouble =);
    }
    value = cleanDouble;
  }
  // void onTextFieldChanged(String value) {
  //   if (formater.format(currentValue.value * max) != value) {
  //     if(value.characters.isEmpty) return;
  //     if (value.characters.last == '.')
  //       formater.maximumFractionDigits = 2;
  //     else if (!value.contains('.')) formater.maximumFractionDigits = 0;
  //     if (oldValue.contains('.') && !value.contains('.')) {
  //       value = oldValue.split('.').first;
  //     }
  //     final dv =
  //         double.tryParse(value.replaceAll('\$', '').replaceAll(',', ''));
  //     if (dv == null) return;
  //     String newvalue = '\$' + formater.format(dv);
  //     if (dv <= max) {
  //       final offset = controller.value.selection.extentOffset;
  //       currentValue.value = dv / max;
  //       percent.value = (currentValue.value * 100).toInt();
  //       controller.value = TextEditingValue(
  //           text: newvalue,
  //           selection: TextSelection.collapsed(
  //               offset: formater.maximumFractionDigits == 0
  //                   ? newvalue.length
  //                   : offset >
  //                           newvalue.length -
  //                               (formater.maximumFractionDigits + 1)
  //                       ? offset <= newvalue.length
  //                           ? offset
  //                           : newvalue.length
  //                       : newvalue.length -
  //                           (formater.maximumFractionDigits + 1)));
  //     } else {
  //       controller.text = "\$" + max.toString();
  //       currentValue.value = 1;
  //       percent.value = 100;
  //     }
  //   }
  //   oldValue = controller.text;
  // }

  @override
  build(BuildContext context) {
    return Stack(
      children: [
        Directionality(
          textDirection: textDirection,
          child: CupertinoTextField(
            maxLines: 1,
            textInputAction: TextInputAction.done,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onTextFieldChanged,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]*.*'))
            ],
            suffix: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.blueGrey.withOpacity(.15),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: ValueListenableBuilder<int>(
                      valueListenable: percent,
                      builder: (context, value, _) => Text("$value%")),
                ),
              ),
            ),
            style: TextStyle(color: Colors.blueGrey.shade700),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withOpacity(.3))),
          ),
        ),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: currentValue,
              builder: (context, currentValue, _) => LeafSlidableTextField(
                value: currentValue,
                onChange: (v) {
                  value = v * max;
                },
              ),
            ))
      ],
    );
  }
}
