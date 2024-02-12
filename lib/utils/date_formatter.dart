import 'package:intl/intl.dart';

String dateFormatter(String dateTimeStr) {
  DateTime dateTime = DateTime.parse(dateTimeStr);
  Duration difference = DateTime.now().difference(dateTime);

  if (difference.inDays < 1) {
    if (difference.inHours < 1) {
      return "${difference.inMinutes} minutes ago";
    }

    return "${difference.inHours} hours ago";
  } else {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }
}
