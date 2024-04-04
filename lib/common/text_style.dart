import 'package:flutter/material.dart';

import 'theme_style.dart';
import 'utils.dart';

var text20bold = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 20,
    fontWeight: FontWeight.bold
);

var text24bold = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 24,
    fontWeight: FontWeight.bold
);

var text18bold = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 18,
    fontWeight: FontWeight.bold
);

var text16bold = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 16,
    fontWeight: FontWeight.bold
);

var text14bold = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 14,
    fontWeight: FontWeight.bold
);

var text14semiBold = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 14,
    fontWeight: FontWeight.w400
);

var text12bold = TextStyle(
  color: MAIN_TEXT_COLOR,
  fontSize: 12,
  fontWeight: FontWeight.bold,
);

var text12boldOut = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    shadows: OutlinedText()
);

var text12bold50 = TextStyle(
    color: GRAY_50,
    fontSize: 12,
    fontWeight: FontWeight.bold
);

var text12 = TextStyle(
  color: MAIN_TEXT_COLOR,
  fontSize: 12,
);

var text10bold = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 10,
    fontWeight: FontWeight.bold
);

var text10 = TextStyle(
  color: MAIN_TEXT_COLOR,
  fontSize: 10,
);

var text10boldOut = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 10,
    fontWeight: FontWeight.bold,
    shadows: OutlinedText()
);

var text9bold = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 9,
    fontWeight: FontWeight.bold
);

var text8bold = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 8,
    fontWeight: FontWeight.bold
);

var text8 = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 8,
    height: 1.0
);

var text6bold = TextStyle(
    color: MAIN_TEXT_COLOR,
    fontSize: 6,
    fontWeight: FontWeight.bold
);

var grayBorderButtonStyle = OutlinedButton.styleFrom(
  backgroundColor: WHITE,
  padding: EdgeInsets.symmetric(vertical: 9, horizontal: 8),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  side: BorderSide(color: GRAY_20, width: 1),
);
