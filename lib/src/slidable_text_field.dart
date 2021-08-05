import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:slidable_text_field/src/defult_fomater_types.dart';
import 'package:slidable_text_field/src/utils.dart';

import 'enums.dart';
import 'leaf_text_field.dart';

class SlidableTextField extends StatelessWidget {
  SlidableTextField(
      {Key? key,
      NumberFormat? customTextFormater,
      TextFormater? textFormater,
      required this.max,
      final double startValue = 0,
      required this.controller})
      : formater = customTextFormater ?? getFormater(textFormater!),
        assert(customTextFormater == null && textFormater != null ||
            customTextFormater != null && textFormater == null),
        super(key: key) {
    value = startValue;
  }
  final NumberFormat formater;
  final double max;
  final TextEditingController controller;
  final ValueNotifier<int> percent = ValueNotifier(0);
  final ValueNotifier<double> currentValue = ValueNotifier(0);
  set value(double? newValue) {
    if (newValue == null) return;

    final cleanValue = double.parse(newValue.toStringAsFixed(2));
    final formattedText = formater.format(cleanValue.clamp(0, max));
    final currentTextOffset = controller.selection.baseOffset;
    final newSymbols =
        findNewSymbols(formattedText, fixNumbers(controller.text));
    log("$currentTextOffset + $newSymbols = ${currentTextOffset + newSymbols}");
    controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(
            offset: (currentTextOffset + newSymbols)
                .clamp(-10, formattedText.length)));

    currentValue.value = (cleanValue / max).clamp(0, 1);
    percent.value = (cleanValue * 100 ~/ max).clamp(0, 100);
  }

  int findNewSymbols(String a, String b) {
    final symbols = [
      formater.symbols.DECIMAL_SEP,
      formater.symbols.GROUP_SEP,
      '.'
    ];
    a = fixNumbers(a).replaceAll(RegExp(r'[^0-9 . ]'), 's');
    b = b.replaceAll(RegExp(r'[^0-9 . ]'), 's');
    return (a.characters.where((char) => char == 's').length -
        b.characters.where((char) => char == 's').length);
  }

  void reset() {
    currentValue.value = 0;
    percent.value = 0;
    controller.clear();
  }

  void onTextFieldChanged(final String newString) {
    final cleanString = fixNumbers(newString)
        .replaceAll(',', '')
        .replaceAll(RegExp(r'[^0-9 \. ` ]'), '');
    double? cleanDouble = double.tryParse(cleanString);
    if (cleanDouble == null) {
      reset();
      return;
    }
    if (currentValue.value == 0) {
      if (newString.contains('\$')) cleanDouble *= 1 / 10;
    } else if (cleanDouble.ceil() >= (currentValue.value * max).ceil() * 99) {
      cleanDouble *= 1 / 100;
    }
    value = cleanDouble;
  }

  void textFieldListener() {
    onTextFieldChanged(controller.text);
  }

  Widget textField(
    TextEditingController controller,
    Function(String value) onChanged,
  ) {
    final textFieldSuffix = Padding(
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
    );
    final textField = CupertinoTextField(
      maxLines: 1,
      onChanged: onTextFieldChanged,
      textInputAction: TextInputAction.done,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]*.*'))],
      suffix: textFieldSuffix,
      style: TextStyle(color: Colors.blueGrey.shade700),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blue.withOpacity(.3))),
    );
    return textField;
  }

  CustomTextFieldBuilder? customTextFieldBuilder;
  @override
  build(BuildContext context) {
    final slider = Positioned(
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
        ));
    return Stack(
      children: [
        if (customTextFieldBuilder == null)
          textField(controller, onTextFieldChanged)
        else
          customTextFieldBuilder!(controller, onTextFieldChanged),
        slider
      ],
    );
  }
}

typedef CustomTextFieldBuilder = Widget Function(
  TextEditingController controller,
  Function(String value) onChanged,
);
