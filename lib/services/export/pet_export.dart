import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/event.dart';

class ExportService {
  // Escape values so commas and quotation marks
  // don't break the CSV file.
  String csvCell(Object? value) {
    var text = (value ?? '').toString();

    // Prevent spreadsheet formula injection.
    if (RegExp(r'^[\s]*[=+\-@]').hasMatch(text)) {
      text = "'$text";
    }

    return '"${text.replaceAll('"', '""')}"';
  }

  Future<void> exportEvents() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('events')
        .get();

    final events = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Event.fromMap(data);
    }).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    // Define CSV columns.
    final rows = <List<Object?>>[
      ['Pet', 'Activity', 'Date', 'Time', 'Person'],
      ...events.map((event) => [
        event.petName,
        event.type,
        DateFormat('yyyy-MM-dd').format(event.time),
        DateFormat('hh:mm a').format(event.time),
        event.person,
      ]),
    ];

    final csvText = rows
        .map(
          (row) => row.map(csvCell).join(','),
        )
        .join('\r\n');

    final filename =
        'furmate_data_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            utf8.encode('\uFEFF$csvText'),
            mimeType: 'text/csv',
          ),
        ],
        fileNameOverrides: [filename],
        title: 'FurMate Events',
      ),
    );
  }
}
