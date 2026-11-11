
import 'package:url_launcher/url_launcher.dart';
import '../../data/event.dart';

class CalendarService {
  static String _formatUtc(DateTime date) {
    final utc = date.toUtc();

    String two(int value) => value.toString().padLeft(2, '0');

    return '${utc.year}'
        '${two(utc.month)}'
        '${two(utc.day)}'
        'T${two(utc.hour)}'
        '${two(utc.minute)}'
        '${two(utc.second)}Z';
  }

  static Future<void> addToGoogleCalendar(Event event) async {
    final start = event.time;

    // Default 30-minute calendar event.
    final end = start.add(const Duration(minutes: 30));

    final title = '${event.type} - ${event.petName}';

    final description =
        'Pet care reminder from FurMate\n'
        'Pet: ${event.petName}\n'
        'Activity: ${event.type}\n'
        'Assigned to: ${event.person}';

    final url = Uri.https(
      'calendar.google.com',
      '/calendar/r/eventedit',
      {
        'action': 'TEMPLATE',
        'text': title,
        'dates': '${_formatUtc(start)}/${_formatUtc(end)}',
        'details': description,
      },
    );

    final launched = await launchUrl(
      url,
      mode: LaunchMode.platformDefault,
    );

    if (!launched) {
      throw Exception('Unable to open Google Calendar');
    }
  }
}
