import 'package:cloud_firestore/cloud_firestore.dart';

String timestampToString(Timestamp timestamp, {bool absolute = false}) {
  final deltaT = Timestamp.now().millisecondsSinceEpoch - timestamp.millisecondsSinceEpoch;

  String toTwoDigitString(int n) {
    final t = n.toString();
    return t.length == 1 ? '0$t' : t;
  }

  String hour = toTwoDigitString(timestamp.toDate().hour);
  String minute = toTwoDigitString(timestamp.toDate().minute);
  int day = timestamp.toDate().day;
  int month = timestamp.toDate().month;
  int year = timestamp.toDate().year;

  if (absolute) {
    return '$year/${toTwoDigitString(month)}/${toTwoDigitString(day)} at $hour:$minute';
  }

  Map<int, String> toMonth = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };

  if (Duration(milliseconds: deltaT).inMinutes <= 5) {
    return 'Now';
  } else if (Duration(milliseconds: deltaT).inMinutes <= 60) {
    return "${Duration(milliseconds: deltaT).inMinutes} minutes ago";
  } else if (Duration(milliseconds: deltaT).inHours < 2) {
    return "${Duration(milliseconds: deltaT).inHours} hour ago";
  } else if (Duration(milliseconds: deltaT).inHours <= 6) {
    return "${Duration(milliseconds: deltaT).inHours} hours ago";
  } else if (timestamp.toDate().day == DateTime.now().day) {
    return "Today at $hour:$minute";
  } else if (Duration(milliseconds: deltaT).inDays <= 2) {
    return "Yesterday at $hour:$minute";
  } else if (Duration(milliseconds: deltaT).inDays <= 7) {
    return '${Duration(milliseconds: deltaT).inDays} days ago at $hour:$minute';
  } else if (Duration(milliseconds: deltaT).inDays <= 365) {
    return '${toMonth[month]} $day at $hour:$minute';
  } else {
    return '$year/${toTwoDigitString(month)}/${toTwoDigitString(day)} at $hour:$minute';
  }
}
