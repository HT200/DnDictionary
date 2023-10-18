import 'package:flutter/services.dart';

class NumericalRangeFormatter extends TextInputFormatter {
  final double min;
  final double max;

  NumericalRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ){
    if (newValue.text == '') {
      return newValue;
    }
    // If the value is smaller than min, set it to min
    else if (int.parse(newValue.text) < min) {
      return TextEditingValue().copyWith(text: min.toStringAsFixed(0));
    } 
    // If the value is larger than max, set it to max
    else {
      return int.parse(newValue.text) > max ? TextEditingValue().copyWith(text: max.toStringAsFixed(0)) : newValue;
    }
  }
}