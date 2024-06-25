import 'package:flutter/material.dart';

class Styles {
  static ButtonStyle blankButton = ButtonStyle(
    overlayColor: MaterialStateProperty.all(Colors.transparent),
    backgroundColor:
    MaterialStateProperty.all<Color>(const Color(0xFFD9EAFD)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),)
    ),
  );
  static ButtonStyle blankButton2 = ButtonStyle(
    minimumSize: MaterialStateProperty.all<Size>(
        const Size.fromHeight(40)),
    overlayColor: MaterialStateProperty.all(Colors.transparent),
    foregroundColor:
    MaterialStateProperty.all<Color>(const Color(0xFF6D7275)),
    backgroundColor:
    MaterialStateProperty.all<Color>(const Color(0xFFEEEFF2)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),)
    ),
  );
  static ButtonStyle blankButton3 = ButtonStyle(
    overlayColor: MaterialStateProperty.all(Colors.transparent),
    backgroundColor:
    MaterialStateProperty.all<Color>(const Color(0x00FFFFFF)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),)
    ),
  );
  static ButtonStyle blankButton4 = ButtonStyle(
    minimumSize: MaterialStateProperty.all<Size>(
        const Size.fromHeight(40)),
    overlayColor: MaterialStateProperty.all(Colors.transparent),
    foregroundColor:
    MaterialStateProperty.all(Colors.blue),
    backgroundColor:
    MaterialStateProperty.all<Color>(const Color(0xFFEEEFF2)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),)
    ),
  );
  static createButton(color) {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor:
      MaterialStateProperty.all<Color>(const Color(0xFF0e0e0e)),
      backgroundColor:
      MaterialStateProperty.all<Color>(color),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),)
      ),
    );
  }
  static createButton2(color, {Color border = Colors.transparent}) {
    return ButtonStyle(
      elevation: MaterialStateProperty.all<double>(1.5),
      minimumSize: MaterialStateProperty.all<Size>(const Size( 160, 75),),
      maximumSize: MaterialStateProperty.all<Size>(const Size( 160, 75),),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      foregroundColor:
      MaterialStateProperty.all<Color>(const Color(0xFF0e0e0e)),
      backgroundColor:
      MaterialStateProperty.all<Color>(color),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: border, width: 1),
          )
      ),
    );
  }
}


