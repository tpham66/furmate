
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/ai/pet_insights_services.dart';

class AiInsightsPage extends StatefulWidget {
  const AiInsightsPage({super.key});

  @override
  State<AiInsightsPage> createState() => _AiInsightsPageState();
}

class _AiInsightsPageState extends State<AiInsightsPage> {
  final _service = PetInsightsService();

  Map<String, String> pets = {};
  String? selectedPetId;
  PetInsightsResult? result;

  bool isLoading = true;
  bool isGenerating = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPets();
  }

  Future<void> loadPets() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        throw Exception('Please sign in first.');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('pets')
          .get();

      final loadedPets = {
        for (final doc in snapshot.docs)
          doc.id: (doc.data()['name'] ?? 'Unnamed pet')
              .toString(),
      };

      if (!mounted) return;

      setState(() {
        pets = loadedPets;
        selectedPetId =
            loadedPets.isEmpty ? null : loadedPets.keys.first;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> generateInsights() async {
    final petId = selectedPetId;
    if (petId == null || isGenerating) return;

    setState(() {
      isGenerating = true;
      result = null;
      errorMessage = null;
    });

    try {
      final insights = await _service.generateInsights(
        petId: petId,
        petName: pets[petId] ?? 'Your pet',
      );

      if (!mounted) return;

      setState(() {
        result = insights;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not generate insights: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
                  'Weekly Pet Insights ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
              children: [
                const Text(
                  'Discover patterns in your pet\'s '
                  'recorded activities.',
                  style: TextStyle(
                  ),
                ),
                const SizedBox(height: 24),

                if (pets.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: selectedPetId,
                    decoration: const InputDecoration(
                      labelText: 'Select Pet',
                      border: OutlineInputBorder(),
                    ),
                    items: pets.entries.map((pet) {
                      return DropdownMenuItem<String>(
                        value: pet.key,
                        child: Text(pet.value),
                      );
                    }).toList(),
                    onChanged: isGenerating
                        ? null
                        : (value) {
                            setState(() {
                              selectedPetId = value;
                              result = null;
                              errorMessage = null;
                            });
                          },
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: isGenerating
                        ? null
                        : generateInsights,
                    icon: isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      isGenerating
                          ? 'Generating...'
                          : 'Generate Insights',
                    ),
                  ),
                ] else
                  const Text(
                    'Add a pet profile to get started.',
                  ),

                if (errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                if (result != null) ...[
                  const SizedBox(height: 30),

                  Text(
                    'Last 7 Days · '
                    '${result!.totalEvents} records',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: result!.activityCounts.entries
                        .map(
                          (entry) => Chip(
                            label: Text(
                              '${entry.key}: ${entry.value}',
                            ),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '✨ AI Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            result!.summary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Based on saved event records, '
                    'not confirmed completed activities. '
                    'Not veterinary advice.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
