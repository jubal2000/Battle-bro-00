import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

typedef JSON = Map<String, dynamic>;

// ignore: non_constant_identifier_names
LOG(msg) {
  print(msg);
}

// ignore: non_constant_identifier_names
bool BOL(dynamic value, {bool defaultValue = false}) {
  return value != null && value.runtimeType != Null && value != 'null' && value.toString().isNotEmpty ?
  value.toString() == '1' || value.toString() == 'on' || value.toString() == 'true' : defaultValue;
}

// ignore: non_constant_identifier_names
int INT(dynamic value, {int defaultValue = 0}) {
  if (value is double) {
    value = value.toInt();
  }
  return value.runtimeType != Null && value != 'null' && value.toString().isNotEmpty ? int.parse(value.toString()) : defaultValue;
}

// ignore: non_constant_identifier_names
double DBL(dynamic value, {var defaultValue = 0.0}) {
  return value.runtimeType != Null && value != 'null' && value.toString().isNotEmpty ? double.parse(value.toString()) : defaultValue;
}

// ignore: non_constant_identifier_names
double DBLV(dynamic value, {var defaultValue = 0.0}) {
  return DBL(value, defaultValue: defaultValue).toInt().toDouble();
}

// ignore: non_constant_identifier_names
String DBL1(dynamic value, {var defaultValue = 0.0}) {
  var result = value.runtimeType != Null && value != 'null' && value.toString().isNotEmpty ? double.parse(value.toString()) : defaultValue;
  return result.toStringAsFixed(1);
}

// ignore: non_constant_identifier_names
String DBL2(dynamic value, {var defaultValue = 0.0}) {
  var result = value.runtimeType != Null && value != 'null' && value.toString().isNotEmpty ? double.parse(value.toString()) : defaultValue;
  return result.toStringAsFixed(2);
}

// 소수점 아래에 값이 있을경우 DBL 로 표시하고, 없을경우 INT 로 표시..
// ignore: non_constant_identifier_names
String DBLS(dynamic value, {int defaultValue = 0, var fixValue = 1}) {
  if (value.runtimeType == double) {
    var values  = value.toString().split('.');
    var decimal = values.last;
    if (int.parse(decimal) <= 0) {
      return INT(values.first, defaultValue: defaultValue).toString();
    }
  } else if (value.runtimeType == int) {
    return INT(value, defaultValue: defaultValue).toString();
  }
  var result = value.runtimeType != Null && value != 'null' && value.toString().isNotEmpty ? double.parse(value.toString()) : defaultValue;
  return result.toStringAsFixed(fixValue);
}

// ignore: non_constant_identifier_names
String STR(dynamic value, {String defaultValue = ''}) {
  var result = value.runtimeType != Null && value != 'null' && value!.toString().isNotEmpty ? value!.toString() : defaultValue;
  result = result.replaceAll('\\n', ' ');
  result = result.replaceAll('\n', ' ');
  return result;
}

// ignore: non_constant_identifier_names
String DESC(dynamic value, {String defaultValue = ''}) {
  var result = value.runtimeType != Null && value != 'null' && value!.toString().isNotEmpty ? value!.toString() : defaultValue;
  result = result.replaceAll('\\n', '\n');
  return result;
}

// ignore: non_constant_identifier_names
TR(dynamic value, {String defaultValue = ''}) {
  return STR(value, defaultValue: defaultValue).toString();
}

// ignore: non_constant_identifier_names
STR_FLAG_TEXT(dynamic value, {String defaultValue = ''}) {
  return STR(value).toString().toUpperCase().replaceFirst('   ', '');
}

// ignore: non_constant_identifier_names
STR_FLAG_ONLY(dynamic value, {String defaultValue = ''}) {
  return STR(value).toString().split(' ').first;
}

// ignore: non_constant_identifier_names
COL(dynamic value, {Color defaultValue = Colors.white}) {
  return value.runtimeType != Null && value != 'null' && value!.toString().isNotEmpty ? hexStringToColor(value!.toString()) : defaultValue;
}

// ignore: non_constant_identifier_names
COL2STR(dynamic value, {String defaultValue = 'ffffff'}) {
  return value.runtimeType != Null && value != 'null' && value!.toString().isNotEmpty ? colorToHexString(value.runtimeType == MaterialColor ? Color(value.value) : value) : defaultValue;
}

// ignore: non_constant_identifier_names
TME(dynamic value, {dynamic defaultValue = '00:00'}) {
  DateTime? result;
  try {
    result =
    value is DateTime ? value :
    value is String ? DateTime.parse(value.toString()) :
    // value is Timestamp ? DateTime.fromMillisecondsSinceEpoch(value.seconds * 1000) :
    value is Map && value['seconds'] != null ? DateTime.fromMillisecondsSinceEpoch(value['seconds'] * 1000) :
    defaultValue != null && defaultValue != '' ? DateTime.parse(defaultValue!.toString())
        : DateTime.parse('00:00');
  } catch (e) {
    LOG("--> TME error : ${value.toString()} -> $e");
  }
  // LOG("--> TME result : ${result.toString()}");
  return result;
}

// ignore: non_constant_identifier_names
TME2(dynamic value, {dynamic defaultValue = '00:00'}) {
  var result = '';
  if (value == null || value == 'null') {
    result = defaultValue;
  } else {
    var timeArr = value.toString().split(':');
    if (timeArr.length > 1) {
      var count = 0;
      for (var item in timeArr) {
        if (item.length < 2) result += '0';
        result += item;
        if (count++ == 0) {
          result += ':';
        }
      }
    } else {
      result = defaultValue;
    }
  }
  LOG("--> TME2 result : $result");
  return result;
}

// ignore: non_constant_identifier_names
COMMENT_DESC(dynamic desc) {
  if (desc == null) return '';
  desc = desc.replaceAll('\\n', ' ');
  desc = desc.replaceAll('\n', ' ');
  return desc;
}

// ignore: non_constant_identifier_names
CURRENT_DATE() {
  var format = DateFormat('yyyy-MM-dd');
  var date = DateTime.now();
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
DATETIME_STR(DateTime date) {
  var format = DateFormat('yyyy-MM-dd HH:mm');
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
DATETIME_FULL_STR(DateTime date) {
  var format = DateFormat('yyyy-MM-dd HH:mm:ss');
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
DATETIME_UUID_STR(DateTime date) {
  var format = DateFormat('yyyy-MM-dd_HH:mm:ss');
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
TIME_24_STR(DateTime date) {
  var format = DateFormat('HH:mm:ss');
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
TIME_HOUR_MIN_STR(DateTime date) {
  var format = DateFormat('HH:mm');
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
TIME_DATA_DESC(dynamic data, [String defaultValue = '']) {
  var result = '';
  if (data == null || data == 'null') return defaultValue;
  if (STR(data['day']).isNotEmpty) result += data['day'].first;
  if (data['startDate'] != null)  result += data['startDate'];
  if (data['endDate'] != null)    result += '~${data['endDate']}';
  var weekStr = '';
  if (data['week'] != null && data['week'].isNotEmpty) {
    if (result.isNotEmpty) result += ' / ';
    for (var item in data['week']) {
      if (weekStr.isNotEmpty) weekStr += ', ';
      weekStr += item + ' week';
    }
    result += weekStr;
  }
  var timeStr = '';
  if (data['startTime'] != null && data['startTime'].isNotEmpty) timeStr += data['startTime'];
  if (data['endTime'] != null && data['endTime'].isNotEmpty) timeStr += '~${data['endTime']}';
  if (result.isNotEmpty && timeStr.isNotEmpty) result += ' / ';
  result += timeStr;
  return result;
}

// ignore: non_constant_identifier_names
String SERVER_TIME_STR(value, [bool isTodayCut = false]) {
  if (value == null) return '';
  var format1 = DateFormat('yyyy-MM-dd HH:mm:ss');
  var format2 = DateFormat('HH:mm:ss');
  DateTime? date = TME(value);
  DateTime toDay = DateTime.now();
  if (date != null) {
    if (isTodayCut &&
        date.year == toDay.year && date.month == toDay.month && date.day == toDay.day) {
      return format2.format(date).toString();
    } else {
      return format1.format(date).toString();
    }
  }
  return '';
}

// ignore: non_constant_identifier_names
String SERVER_TIME_ONE_STR(value) {
  var timeData = value as JSON;
  if (JSON_EMPTY(timeData)) return '';
  return timeData.entries.first.value['title'];
}

String SERVER_DATE_STR(value) {
  if (value == null) return '';
  var format = DateFormat('yyyy-MM-dd');
  var date = TME(value);
  if (date != null) {
    return format.format(date).toString();
  }
  return '';
}

// ignore: non_constant_identifier_names
String EVENT_TIMEDATA_TITLE_STR(value) {
  var timeData = value as JSON;
  if (JSON_EMPTY(timeData)) return '';
  var result = '';
  for (var item in timeData.entries) {
    if (STR(item.value['title']).isNotEmpty) {
      if (result.isNotEmpty) result += ' / ';
      result += STR(item.value['title']);
    }
  }
  return result;
}

// ignore: non_constant_identifier_names
String EVENT_TIMEDATA_TIME_STR(value) {
  var timeData = value as JSON;
  if (JSON_EMPTY(timeData)) return '';
  var result = '';
  for (var item in timeData.entries) {
    if (result.isNotEmpty) result += ' / ';
    if (STR(item.value['startTime']).isNotEmpty) {
      result += STR(item.value['startTime']);
    }
    result += '~';
    if (STR(item.value['endTime']).isNotEmpty) {
      result += STR(item.value['endTime']);
    }
  }
  return result;
}

// ignore: non_constant_identifier_names
String EVENT_TIMEDATA_TITLE_TIME_STR(value) {
  var timeData = value as JSON;
  if (JSON_EMPTY(timeData)) return '';
  var result = '';
  for (var item in timeData.entries) {
    if (result.isNotEmpty) result += ' / ';
    if (STR(item.value['title']).isNotEmpty) {
      result += STR(item.value['title']) + ': ';
    }
    if (STR(item.value['startTime']).isNotEmpty) {
      result += STR(item.value['startTime']);
    }
    result += '~';
    if (STR(item.value['endTime']).isNotEmpty) {
      result += STR(item.value['endTime']);
    }
  }
  return result;
}

// ignore: non_constant_identifier_names
SERVER_DATE(DateTime date) {
  Timestamp currentTime = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
  return currentTime;
}

// ignore: non_constant_identifier_names
CURRENT_SERVER_TIME() {
  Timestamp currentTime = Timestamp.fromDate(DateTime.now());
  return currentTime;
}

// ignore: non_constant_identifier_names
OFFSET_CURRENT_SERVER_TIME(Duration duration) {
  var now = DateTime.now();
  Timestamp currentTime = Timestamp.fromDate(DateTime(now.year, now.month, now.day).add(duration));
  return currentTime;
}

// ignore: non_constant_identifier_names
CURRENT_SERVER_TIME_JSON() {
  Timestamp currentTime = Timestamp.fromDate(DateTime.now());
  return {
    '_seconds' : currentTime.seconds,
    '_nanoseconds' : currentTime.nanoseconds,
  };
}

// ignore: non_constant_identifier_names
CURRENT_SERVER_DATE() {
  var now = DateTime.now();
  return SERVER_DATE(now);
}

// ignore: non_constant_identifier_names
CURRENT_LOCAL_DATE() {
  var format = DateFormat('yyyy-MM-dd HH:mm:ss');
  return format.format(DateTime.now()).toString();
}

// ignore: non_constant_identifier_names
DATE_STR(DateTime date) {
  var format = DateFormat('yyyy-MM-dd');
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
TIME_STR(DateTime date) {
  var format = DateFormat('HH:mm');
  return format.format(date).toString();
}

// ignore: non_constant_identifier_names
PRICE_STR(price) {
  if (price == null || price.toString().isEmpty) return '0';
  var value = 0.0;
  if (price is String) {
    value = double.parse(price);
  } else {
    value = double.parse('$price');
  }
  var priceFormat = NumberFormat('###,###,###,###.##');
  return priceFormat.format(value).toString();
}

var fileIconList = ['ai','avi','doc','docx','fla','html','mp3','mp4','pdf','ppt','pptx','psd','txt','xls','xlsx'];

// ignore: non_constant_identifier_names
FILE_ICON(String? ext) {
  if (ext == null) return NO_IMAGE;
  if (fileIconList.contains(ext)) {
    return 'assets/file_icons/icon_$ext.png';
  }
  return 'assets/file_icons/icon_none.png';
}

// ignore: non_constant_identifier_names
SALE_STR(value) {
  if (value == null) return '';
  double tmpNum = value;
  var format1 = NumberFormat('###,###,###,###.##');
  var format2 = NumberFormat('###,###,###,###');
  return tmpNum - tmpNum.floor() > 0 ? format1.format(tmpNum).toString() : format2.format(tmpNum).toString();
}

// ignore: non_constant_identifier_names
REMAIN_DATETIME(dynamic dateTime) {
  if (dateTime == null) {
    LOG('---> REMAIN_DATETIME is Zero');
    return 0;
  }
  var format = DateFormat('yyyy-MM-dd');
  var dateStr = '';
  try {
    if (dateTime is Map && dateTime['_seconds'] != null) {
      var date = TME(dateTime);
      dateStr = format.format(date).toString();
      LOG('---> REMAIN_DATETIME dateStr : $dateStr');
    } else {
      dateStr = dateTime;
    }
    DateTime date = format.parse(dateStr);
    LOG('---> REMAIN_DATETIME : $dateStr / ${date.difference(DateTime.now()).inDays} / ${date.difference(DateTime.now()).inHours}');
    return date.difference(DateTime.now()).inDays + (date.difference(DateTime.now()).inHours > 0 ? 1 : 0);
  } catch (e) {
    LOG('---> REMAIN_DATETIME Error : $e / $dateStr');
    return 0;
  }
}

// ignore: non_constant_identifier_names
JSON_START_DAY_SORT_DESC(JSON data) {
  // LOG("--> JSON_START_DAY_SORT_DESC : ${data.length}");
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    return INT(data[a]['startDay']) > INT(data[b]['startDay']) ? -1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_CREATE_TIME_SORT_DESC(JSON data) {
  // LOG("--> JSON_CREATE_TIME_SORT_DESC : ${data.length}");
  try {
    if (JSON_EMPTY(data)) return JSON.from({});
    if (data.length < 2) return data;
    return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
      // LOG("--> check : ${data[a]['createTime']}");
      return data[a]['createTime'] != null && data[b]['createTime'] != null ?
      DateTime.parse(data[a]['createTime']).isBefore(DateTime.parse(data[b]['createTime'])) ? -1 : 1 : 1;
    }));
  } catch (e) {
    LOG("--> JSON_CREATE_TIME_SORT_DESC error : $e");
  }
}

// ignore: non_constant_identifier_names
JSON_UPDATE_TIME_SORT_DESC(JSON data) {
  // LOG("--> JSON_UPDATE_TIME_SORT_DESC : ${data.length}");
  if (JSON_EMPTY(data)) return JSON.from({});
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    return data[a]['updateTime'] != null && data[b]['updateTime'] != null ?
    DateTime.parse(data[a]['updateTime']).isBefore(DateTime.parse(data[b]['updateTime'])) ? -1 : 1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_CREATE_TIME_SORT_ASCE(JSON data) {
  // LOG("--> JSON_CREATE_TIME_SORT_DESC : $data");
  if (JSON_EMPTY(data)) return JSON.from({});
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']} > ${data[b]['createTime']}");
    return data[a]['createTime'] != null && data[b]['createTime'] != null ?
    DateTime.parse(data[a]['createTime']).isBefore(DateTime.parse(data[b]['createTime'])) ? -1 : 1 : 1;
    // data[a]['createTime']['_seconds'] > data[b]['createTime']['_seconds'] ? 1 : -1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_TIME_STR_SORT_ASCE(JSON data) {
  // LOG("--> JSON_CREATE_TIME_SORT_DESC : $data");
  if (JSON_EMPTY(data)) return JSON.from({});
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    return data[a]['createTime'] != null && data[b]['createTime'] != null ?
    data[a]['createTime'] < data[b]['createTime'] ? -1 : 1 : 1;
    // data[a]['createTime']['_seconds'] > data[b]['createTime']['_seconds'] ? 1 : -1 : 1;
  }));
}

// ignore: non_constant_identifier_names
JSON_TARGET_DATE_SORT_ASCE(JSON data) {
  // LOG("--> JSON_TARGET_DATE_SORT_ASCE : $data");
  try {
    if (JSON_EMPTY(data)) return JSON.from({});
    if (data.length < 2) return data;
    return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
      // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
      return DateTime.parse(STR(data[a]['targetDate'])).isBefore(DateTime.parse(STR(data[b]['targetDate']))) ? -1 : 1;
    }));
  } catch (e) {
    LOG("--> JSON_TARGET_DATE_SORT_ASCE error : $e");
  }
  return data;
}

// ignore: non_constant_identifier_names
JSON_INDEX_SORT_ASCE(JSON data) {
  // LOG("--> JSON_INDEX_SORT_ASCE : $data");
  if (JSON_EMPTY(data)) return JSON.from({});
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) {
    // LOG("--> check : ${data[a]['createTime']['_seconds']} > ${data[b]['createTime']['_seconds']}");
    if (data[a]['index'] != null) {
      return data[a]['index'] != null && data[b]['index'] != null ?
      INT(data[a]['index']) > INT(data[b]['index']) ? 1 : -1 : 0;
    } else if (data[a]['sortIndex'] != null) {
      return data[a]['sortIndex'] != null && data[b]['sortIndex'] != null ?
      INT(data[a]['sortIndex']) > INT(data[b]['sortIndex']) ? 1 : -1 : 0;
    }
    return 0;
  }));
}

// ignore: non_constant_identifier_names
LIST_CREATE_TIME_SORT_DESC(List<JSON> data) {
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => a['createTime'] != null && b['createTime'] != null ?
  DateTime.parse(a['createTime']).isAfter(DateTime.parse(b['createTime'])) ? -1 : 1 : 0);
  return data;
}

// ignore: non_constant_identifier_names
LIST_CREATE_TIME_SORT_ASCE(List<JSON> data) {
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => a['createTime'] != null && b['createTime'] != null ?
  DateTime.parse(a['createTime']).isAfter(DateTime.parse(b['createTime'])) ? 1 : -1 : 0);
  return data;
}

// ignore: non_constant_identifier_names
LIST_START_TIME_SORT(List<JSON> data) {
  // LOG("--> LIST_START_TIME_SORT : $data");
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => a['startTime'] != null && b['startTime'] != null ?
  DateTime.parse(a['startTime']).isAfter(DateTime.parse(b['startTime'])) ? 1 : -1 : 0);
  return data;
}

// ignore: non_constant_identifier_names
LIST_DATE_SORT_ASCE(List<String> data) {
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => DateTime.parse(a).isAfter(DateTime.parse(b)) ? 1 : -1);
  return data;
}

// ignore: non_constant_identifier_names
LIST_LIKES_SORT_DESC(List<JSON> data) {
  if (JSON_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => INT(a['likes']) > INT(b['likes']) ? -1 : 1);
  return data;
}

// ignore: non_constant_identifier_names
JSON_INDEX_SORT(JSON data) {
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) =>
  INT(data[a]['index']) > INT(data[b]['index']) ? 1 : -1));
}

// ignore: non_constant_identifier_names
JSON_LAST_INDEX(JSON data, int offset) {
  var result = 0;
  data.forEach((key, value) {
    var checkIndex = INT(value['index']);
    if (checkIndex > result) result = checkIndex;
  });
  return result + offset;
}

// ignore: non_constant_identifier_names
JSON_START_DAY_SORT(JSON data) {
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) =>
  INT(data[a]['startDay']) > INT(data[b]['startDay']) ? -1 : 1));
}


// ignore: non_constant_identifier_names
JSON_SEEN_SORT(JSON data) {
  if (JSON_EMPTY(data)) return {};
  if (data.length < 2) return data;
  return JSON.from(SplayTreeMap<String,dynamic>.from(data, (a, b) =>
  BOL(data[a]['isSeen']) && !BOL(data[b]['isSeen']) ? 1 : -1));
}

// ignore: non_constant_identifier_names
LIST_INDEX_SORT(List<JSON> data) {
  if (JSON_EMPTY(data)) return [];
  data.sort((a, b) => INT(a['index']) > INT(b['index']) ? 1 : -1);
  return data;
}

// ignore: non_constant_identifier_names
LIST_LAST_INDEX(List<JSON> data, int offset) {
  var result = 0;
  for (var item in data) {
    var checkIndex = INT(item['index']);
    if (checkIndex > result) result = checkIndex;
  }
  return result + offset;
}

// ignore: non_constant_identifier_names
LIST_RECOMMEND_SORT_DESC(List<JSON> data) {
  if (LIST_EMPTY(data)) return [];
  if (data.length < 2) return data;
  data.sort((a, b) => a['creditQty'] < b['creditQty'] ? 1 : -1);
  return data;
}

colorToHexString(Color color) {
  return color.value.toRadixString(16).substring(2, 8);
}

hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}

// ignore: non_constant_identifier_names
JSON_NOT_EMPTY(dynamic data) {
  return data != null && data.isNotEmpty;
}

// ignore: non_constant_identifier_names
JSON_EMPTY(dynamic data) {
  return !JSON_NOT_EMPTY(data);
}

// ignore: non_constant_identifier_names
LIST_NOT_EMPTY(dynamic data) {
  return data != null && List.from(data).isNotEmpty;
}

// ignore: non_constant_identifier_names
LIST_IN_ITEM(dynamic data, dynamic item) {
  return LIST_NOT_EMPTY(data) && data.contains(item);
}

// ignore: non_constant_identifier_names
LIST_EMPTY(dynamic data) {
  if (data == null) return true;
  return !LIST_NOT_EMPTY(data);
}

// ignore: non_constant_identifier_names
STR_NOT_EMPTY(dynamic data) {
  return STR(data).isNotEmpty;
}

// ignore: non_constant_identifier_names
STR_EMPTY(dynamic data) {
  return !STR_NOT_EMPTY(data);
}

// ignore: non_constant_identifier_names
PARAMETER_JSON(String key, dynamic value) {
  if (value == null) return {};
  return {key: json.encode(value)};
}

// ignore: non_constant_identifier_names
GET_COUNTRY_EXCEPT_FLAG(String value) {
  var result = '';
  var arr = value.split(' ');
  for (var i=1; i<arr.length; i++) {
    var item = arr[i];
    if (item != ' ' && result.isNotEmpty) result += ' ';
    result += item;
  }
  return result;
}

// ignore: non_constant_identifier_names
STRING_TO_UINT8LIST(String value) {
  return Uint8List.fromList(List<int>.from(value.codeUnits));
}

// ignore: non_constant_identifier_names
ADDR(dynamic desc) {
  if (desc != null) {
    var addr1 = desc['address1'] ?? '';
    return STR(addr1);
  }
  return '';
}

// ignore: non_constant_identifier_names
LAT(dynamic desc) {
  if (desc == null) return 0;
  return DBL(desc['lat']);
}

LNG(dynamic desc) {
  if (desc == null) return 0;
  return DBL(desc['lng']);
}

// ignore: non_constant_identifier_names
ADDR_GOOGLE(dynamic desc, String title, String pic) {
  if (desc == null) return null;
  return {'title': title, 'pic': pic, 'lat': DBL(desc['lat']), 'lng': DBL(desc['lng'])};
}

// ignore: non_constant_identifier_names
NUMBER_K(int number) {
  String result = "";
  if (number > 1000) {
    var num1 = number / 1000;
    result = num1.toStringAsFixed(1);
    result += 'K';
  } else {
    result = '$number';
  }
  return result;
}

Widget getCircleImage(String url, double size) {
  return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(size),
          child: showImageWidget(url, BoxFit.cover)
      )
  );
}

Widget showSizedImage(dynamic imagePath, double size) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(size / 8),
    child: SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.fill,
        child: showImageFit(imagePath),
      ),
    ),
  );
}

Widget showCardRoundImage(dynamic imagePath, double size,
    [BorderRadius radius = const BorderRadius.only(topLeft:Radius.circular(10), bottomLeft:Radius.circular(20))]) {
  return ClipRRect(
    borderRadius: radius,
    child: SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.fill,
        child: showImageFit(imagePath),
      ),
    ),
  );
}

Widget showSizedRoundImage(dynamic imagePath, double size, double round) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(round),
    child: SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.fill,
        child: showImageFit(imagePath),
      ),
    ),
  );
}

Widget showImage(String url, Size size, {Color? color, var fit = BoxFit.cover}) {
  return SizedBox(
      width: size.width,
      height: size.height,
      child: showImageWidget(url, fit, color:color)
  );
}

Widget showImageFit(dynamic imagePath) {
  return showImageWidget(imagePath, BoxFit.fill);
}

Widget showImageWidget(dynamic imagePath, BoxFit fit, {Color? color}) {
  if (imagePath != null && imagePath.isNotEmpty) {
    try {
      if (imagePath.runtimeType == String && imagePath
          .toString()
          .isNotEmpty) {
        var url = imagePath.toString();
        if (url == 'empty') {
          return Container(
            width: 30,
            height: 30,
            color: Colors.transparent,
          );
        }
        if (url.contains("http")) {
          return CachedNetworkImage(
            imageUrl: url,
            cacheKey: url
                .split('=')
                .last,
            progressIndicatorBuilder: (context, name, value) =>
                Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            errorWidget: (context, error, stackTrace) => const Icon(Icons.error),
          );
        } else if (url.contains('/cache')) {
          return Image.file(File(url), fit: fit, color: color);
        } else if (url.contains('assets')) {
          return Image.asset(url, fit: fit, color: color);
        }
      } else if (imagePath.runtimeType == Uint8List) {
        return Image.memory(imagePath as Uint8List, fit: fit, color: color);
      }
    } catch (e) {
      LOG('--> showImage Error : $e');
    }
  }
  return Image.asset(NO_IMAGE);
}

Widget showLoadingCircleSquare(double size) {
  return Container(
      child: Center(
          child: SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(strokeWidth: size >= 50 ? 2 : 1)
          )
      )
  );
}

Widget showLoadingFullPage(BuildContext context) {
  return showLoadingPage(context, 150);
}

Widget showLoadingPage(BuildContext context, [int offset = 0]) {
  var size = 50.0;
  return LayoutBuilder(
      builder: (context, layout) {
        return Container(
            width:  layout.maxWidth,
            height: layout.maxHeight > offset ? layout.maxHeight - offset : double.infinity,
            color: Colors.blueGrey.withOpacity(0.1),
            child: Center(
                child: SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(strokeWidth: size >= 50 ? 2 : 1)
                )
            )
        );
      }
  );
}

Widget showLogoLoadingPage(BuildContext context) {
  var size = 120.0;
  return LayoutBuilder(
      builder: (context, layout) {
        return Container(
            width:  layout.maxWidth,
            height: layout.maxHeight,
            color: Colors.blueGrey.withOpacity(0.1),
            child: Center(
              child: showImage('assets/ui/logo_01_00.png', Size(size, size)),
            )
        );
      }
  );
}


class showVerticalDivider extends StatelessWidget {
  showVerticalDivider(this.size,
      {Key ? key, this.color = Colors.grey, this.thickness = 1})
      : super (key: key);

  Size size = Size(20, 20);
  Color? color;
  double? thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: size.width,
        height: size.height,
        child: Center(
            child: VerticalDivider(
              color: color,
              thickness: thickness,
              width: size.width,
            )
        )
    );
  }
}

class showHorizontalDivider extends StatelessWidget {
  showHorizontalDivider(this.size,
      {Key ? key, this.color, this.thickness = 1})
      : super (key: key);

  Size size;
  Color? color;
  double? thickness;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size.width,
        height: size.height,
        child: Center(
            child: Divider(
              color: color ?? Colors.grey.withOpacity(0.35),
              thickness: thickness,
              height: size.height,
            )
        )
    );
  }
}

// ignore: non_constant_identifier_names
Future<Uint8List?> ReadFileByte(String filePath) async {
  Uri myUri = Uri.parse(filePath);
  File audioFile = File.fromUri(myUri);
  Uint8List? bytes;
  await audioFile.readAsBytes().then((value) {
    bytes = Uint8List.fromList(value);
    LOG('--> reading of bytes is completed');
  }).catchError((onError) {
    LOG('--> Exception Error while reading audio from path: ${onError.toString()}');
  });
  return bytes;
}

inputLabel(BuildContext context, String label, String hint, {double width = 2, EdgeInsets? padding}) {
  return inputLabelSuffix(context, label, hint, width: width, padding: padding);
}

viewLabel(BuildContext context, String label, String hint, {double width = 0, EdgeInsets? padding}) {
  return inputLabelSuffix(context, label, hint, width: width, padding: padding, fillColor: Theme.of(context).canvasColor.withOpacity(0.2));
}

inputLabelSuffix(BuildContext context, String label, String hint,
    {String suffix = '', bool isEnabled = true, double width = 1, EdgeInsets? padding, Color? fillColor}) {
  return InputDecoration(
    filled: true,
    isDense: true,
    alignLabelWithHint: true,
    hintText: hint,
    suffixText: suffix,
    labelText: label,
    enabled: isEnabled,
    contentPadding: padding ?? EdgeInsets.all(10),
    hintStyle: TextStyle(color: Theme.of(context).hintColor.withOpacity(0.5), fontSize: 10),
    fillColor: fillColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width, color: Colors.yellow),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width, color: Theme.of(context).colorScheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width + 1, color: Theme.of(context).colorScheme.error),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width, color: Theme.of(context).focusColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width, color: Theme.of(context).primaryColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(width: width, color: Colors.grey.withOpacity(0.5)),
    ),
  );
}

ShowToast(text, [Color backColor = Colors.black87, Color textColor = Colors.white]) {
  // Fluttertoast.showToast(
  //     msg: text,
  //     toastLength: Toast.LENGTH_SHORT,
  //     gravity: ToastGravity.BOTTOM,
  //     timeInSecForIosWeb: 1,
  //     backgroundColor: backColor,
  //     textColor: textColor,
  //     fontSize: 16.0
  // );
}

ShowErrorToast(text)  {
  ShowToast(text, Colors.black87, Colors.yellow);
}

enum DropdownItemType {
  none,
  enter,
}

class DropdownItem {
  final DropdownItemType type;
  final String? text;
  final IconData? icon;
  final bool isLine;
  final double height;
  final bool color;
  final bool alert;
  final bool manager;

  const DropdownItem(
      this.type,
      {
        this.text,
        this.icon,
        this.isLine = false,
        this.height = 40,
        this.color = false,
        this.alert = false,
        this.manager = false,
      }
      );
}

const dropMenuEnter = DropdownItem(DropdownItemType.enter, text: 'ENTER', icon: Icons.login);
const dropMenuLine  = DropdownItem(DropdownItemType.none, isLine: true);

class DropdownItems {
  static const List<DropdownItem> eventAddItem = [dropMenuEnter];

  static Widget buildItem(BuildContext context, DropdownItem item) {
    var color = item.alert ? Theme.of(context).colorScheme.error :
    item.color ? Theme.of(context).primaryColor : Theme.of(context).hintColor;
    // var style = item.alert ? ItemTitleAlertStyle(context) :
    //   ItemTitleStyle(context, color: item.color ? color : null);
    if (item.manager) {
      color = Theme.of(context).colorScheme.tertiary;
    }
    return Row(
        children: [
          if (!item.isLine)...[
            Icon(
                item.icon,
                color: color,
                size: 20
            ),
            SizedBox(width: 5),
            if (item.text != null)...[
              SizedBox(width: 3),
              Text(item.text!, maxLines: 1),
              // Text(item.text!, style: style, maxLines: 1),
            ]
          ],
          if (item.isLine)...[
            Expanded(
              child: showHorizontalDivider(Size(double.infinity, 2),
                  color: Colors.grey),
            )
          ]
        ]
    );
  }
}

TextCheckBox(BuildContext context, String title, bool value,
    {
      var subTitle = '',
      var padding = EdgeInsets.zero,
      var height = 30.0,
      var textSpace = 10.0,
      var isExpanded = true,
      Color? textColor,
      Function(bool)? onChanged
    }) {
  return Container(
      padding: padding,
      child: Column(
          children: [
            Row(
                children: [
                  if (isExpanded)
                    Expanded(
                      child: Text(
                          title,
                          style: TextStyle(fontSize: 14, color: textColor ??
                              Theme.of(context).primaryColor.withOpacity(0.5),
                              fontWeight: FontWeight.w800)
                      ),
                    ),
                  if (!isExpanded)...[
                    Text(
                        title,
                        style: TextStyle(fontSize: 14, color: textColor ??
                            Theme.of(context).primaryColor.withOpacity(0.5),
                            fontWeight: FontWeight.w800)
                    ),
                    SizedBox(width: textSpace),
                  ],
                  Switch(
                    value: value,
                    onChanged: onChanged,
                  )
                ]
            ),
            if (subTitle.isNotEmpty)...[
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Text(
                    subTitle,
                    style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600)
                ),
              ),
            ]
          ]
      )
  );
}

// ignore: non_constant_identifier_names
SubTitle(BuildContext context, String title,
    {Color? textColor, double height = 30, double topPadding = 0, double bottomPadding = 0, Widget? child}) {
  return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Row(
          children: [
            Text(title,
                style: TextStyle(
                  // color: textColor ?? SubTitleColor(context),
                    fontWeight: FontWeight.w800)),
            if (child != null)...[
              SizedBox(width: 10.w),
              child
            ]
          ]
      )
  );
}

// ignore: non_constant_identifier_names
SubTitleSmall(BuildContext context, String title, {double height = 30, double topPadding = 0, double bottomPadding = 0, Color? color}) {
  return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Text(title, style: TextStyle(color: color ?? Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w500, fontSize: 12))
  );
}

// ignore: non_constant_identifier_names
SubTitleEx(BuildContext context, String text, String desc, [double height = 30, double topPadding = 0, double bottomPadding = 0]) {
  return Container(
      height: height,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: Row(
          children: [
            Text(text,
                style: TextStyle(
                  // color: SubTitleColor(context),
                    fontWeight: FontWeight.w800)),
            SizedBox(width: 5),
            Text(desc,
                style: TextStyle(
                  // color: DescColor(context),
                    fontWeight: FontWeight.w600, fontSize: 12)),
          ]
      )
  );
}

List<Shadow> OutlinedText({double strokeWidth = 2, Color strokeColor = Colors.black, int precision = 5}) {
  Set<Shadow> result = HashSet();
  for (int x = 1; x < strokeWidth + precision; x++) {
    for(int y = 1; y < strokeWidth + precision; y++) {
      double offsetX = x.toDouble();
      double offsetY = y.toDouble();
      result.add(Shadow(offset: Offset(-strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
      result.add(Shadow(offset: Offset(-strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
      result.add(Shadow(offset: Offset(strokeWidth / offsetX, -strokeWidth / offsetY), color: strokeColor));
      result.add(Shadow(offset: Offset(strokeWidth / offsetX, strokeWidth / offsetY), color: strokeColor));
    }
  }
  return result.toList();
}

Route createAniRoute(Widget target) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => target,
    transitionDuration: Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end   = Offset.zero;
      var curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
