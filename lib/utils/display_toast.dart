import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DisplayToast{

  static Future<bool?> displayToast(String message) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        );
  }
}