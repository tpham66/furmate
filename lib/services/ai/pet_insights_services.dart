
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/event.dart';

class PetInsightsResult {
  final Map<String, int> activityCounts;
  final int totalEvents;
  final String summary;

  const PetInsightsResult({
    required this.activityCounts,
    required this.totalEvents,
    required this.summary,
  });
}

class PetInsightsService {
  Future<PetInsightsResult> generateInsights({
    required String petId,
    required String petName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));

    // 1. Load the user's event records.
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('events')
        .where('petId', isEqualTo: petId)
        .get();

    // 2. Keep records dated within the last 7 days.
    final events = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Event.fromMap(data);
    }).where((event) {
      return !event.time.isBefore(start) &&
          !event.time.isAfter(now);
    }).toList();

    // 3. Count recorded activity types.
    final activityCounts = <String, int>{};

    for (final event in events) {
      final type = event.type.trim().toLowerCase();

      if (type.isEmpty) continue;

      activityCounts[type] = (activityCounts[type] ?? 0) + 1;
    }

    // No need to call Gemini when there are no records
    if (events.isEmpty) {
      return const PetInsightsResult(
        activityCounts: {},
        totalEvents: 0,
        summary:
            'No activity records were found for the '
            'last 7 days. Add some events to get insights.',
      );
    }

    // 4. Prepare statistics for Gemini.
    final statistics = activityCounts.entries
        .map((entry) =>
            '${entry.key}: ${entry.value}')
        .join('\n');

    final prompt = '''
You are FurMate, a friendly pet care assistant.

Pet name: $petName
Reporting period: Last 7 days
Number of event records: ${events.length}

Recorded activities:
$statistics

Write a short weekly activity summary.

Requirements:
- Use only the supplied numbers.
- Describe the recorded activities.
- Suggest at most two practical routine improvements.
- Keep the response under 120 words.
- Do not invent activities or medical conditions.
- Do not provide veterinary diagnoses.
- The events may be scheduled activities, not
  confirmed completed activities.
- Missing records do not mean an activity
  did not happen.
''';

    // 5. Generate the AI summary.
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash-lite',
    );

    final response = await model.generateContent([
      Content.text(prompt),
    ]);

    return PetInsightsResult(
      activityCounts: activityCounts,
      totalEvents: events.length,
      summary: response.text?.trim().isNotEmpty == true
          ? response.text!.trim()
          : 'No AI summary was generated.',
    );
  }
}
