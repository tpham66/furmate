import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../data/pet.dart';
import '../data/feeding_log.dart';
import '../services/feeding_service.dart';
import '../services/nutrition_service.dart';
import 'dart:async';

class FeedingTracker extends StatefulWidget {
  final Pet pet;
  const FeedingTracker({super.key, required this.pet});

  @override
  State<FeedingTracker> createState() => _FeedingTrackerState();
}

class _FeedingTrackerState extends State<FeedingTracker> {
  final FeedingService _service = FeedingService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Log a Meal'),
                  onPressed: () {
                    _showFeedingForm(widget.pet.id);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<FeedingLog>>(
            key: ValueKey(widget.pet.id),
            stream: _service.getFeedingLogs(widget.pet.id),
            builder: (context, logSnapshot) {
              if (logSnapshot.hasError) {
                return const Center(
                  child: Text('Failed to load feeding logs'),
                );
              }

              if (!logSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final logs = logSnapshot.data!;

              if (logs.isEmpty) {
                return const Center(
                  child: Text('No meals recorded yet.'),
                );
              }

              final today = DateTime.now();

              final mealsToday = logs.where((log) {
                return log.fedAt.year == today.year &&
                    log.fedAt.month == today.month &&
                    log.fedAt.day == today.day;
              }).length;

              final caloriesToday = logs
                  .where((log) =>
                      log.fedAt.year == today.year &&
                      log.fedAt.month == today.month &&
                      log.fedAt.day == today.day)
                  .fold<double>(
                    0,
                    (sum, log) => sum + (log.calories ?? 0),
                  );

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '$mealsToday',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                const Text('Meals today'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  caloriesToday.toStringAsFixed(0),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                const Text('Logged kcal today'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Feeding History',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...logs.map((log) {
                    return Card(
                      child: ListTile(
                        titleAlignment: ListTileTitleAlignment.center,
                        leading: const CircleAvatar(
                          child: Icon(Icons.restaurant),
                        ),
                        title: Text(log.foodName),
                        subtitle: Text(
                          '${log.mealType} • '
                          '${log.quantity} ${log.unit}\n'
                          '${DateFormat('MMM d, yyyy • h:mm a').format(log.fedAt)}'
                          '${log.calories != null ? '\n${log.calories} kcal' : ''}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                          tooltip: 'Delete meal',
                          onPressed: () => _deleteLog(log),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showFeedingForm(String petId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _FeedingForm(
          petId: petId,
          service: _service,
        );
      },
    );
  }

  Future<void> _deleteLog(FeedingLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete meal?'),
        content: Text(
          'Remove "${log.foodName}" from feeding history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.deleteFeedingLog(log.id);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete meal: $e')),
      );
    }
  }
}

// Bottom-sheet form for recording a completed feeding.
class _FeedingForm extends StatefulWidget {
  final String petId;
  final FeedingService service;

  const _FeedingForm({
    required this.petId,
    required this.service,
  });

  @override
  State<_FeedingForm> createState() => _FeedingFormState();
}

class _FeedingFormState extends State<_FeedingForm> {
  final _formKey = GlobalKey<FormState>();

  final _foodController = TextEditingController();
  final _quantityController = TextEditingController();
  final _caloriesController = TextEditingController();

  String _mealType = 'Breakfast';
  String _unit = 'g';
  bool _isSaving = false;

  final nutritionService = NutritionService();

  List<dynamic> foods = [];

  bool isSearching = false;

  Timer? _debounce;
  int _searchVersion = 0;

  double? _kcalPer100g;

  Future<void> searchFood(String query) async {
    if (query.trim().length < 2) return;

    setState(() => isSearching = true);

    try {
      final results = await nutritionService.searchFood(query);

      if (!mounted) return;

      setState(() {
        foods = results;
      });
    } catch (e) {
      debugPrint('Nutrition API error: $e');
    } finally {
      if (mounted) {
        setState(() => isSearching = false);
      }
    }
  }


  void _onFoodChanged(String query) {
    _debounce?.cancel();

    // Invalidate previous searches.
    final version = ++_searchVersion;

    setState(() {
      foods = [];
      _kcalPer100g = null;
      _caloriesController.clear();
      isSearching = false;
    });

    if (query.trim().length < 3) return;

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _searchSuggestions(query.trim(), version),
    );
  }

  Future<void> _searchSuggestions(
    String query,
    int version,
  ) async {
    if (!mounted || version != _searchVersion) return;

    setState(() => isSearching = true);

    try {
      final results = await nutritionService.searchFood(query);

      // Ignore results from older requests.
      if (!mounted || version != _searchVersion) return;

      setState(() {
        foods = results;
      });
    } catch (e) {
      debugPrint('Nutrition suggestions failed: $e');

      if (!mounted || version != _searchVersion) return;

      setState(() {
        foods = [];
      });
    } finally {
      if (mounted && version == _searchVersion) {
        setState(() => isSearching = false);
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();

    _foodController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final caloriesText = _caloriesController.text.trim();

      await widget.service.addFeedingLog(
        petId: widget.petId,
        foodName: _foodController.text.trim(),
        mealType: _mealType,
        quantity: double.parse(
          _quantityController.text.trim(),
        ),
        unit: _unit,
        calories: caloriesText.isEmpty
            ? null
            : double.parse(caloriesText),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save meal: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  double estimateCalories({
    required double grams,
    required double kcalPer100g,
  }) {
    return grams * kcalPer100g / 100;
  }

  void _calculateCalories() {
    final quantity = double.tryParse(
      _quantityController.text.trim(),
    );

    if (quantity == null ||
        !quantity.isFinite ||
        quantity <= 0 ||
        _kcalPer100g == null) {
      _caloriesController.clear();
      return;
    }

    double grams;

    switch (_unit) {
      case 'g':
        grams = quantity;
        break;

      case 'oz':
        grams = quantity * 28.3495;
        break;

      default:
        // Cups require a product-specific grams-per-cup value.
        _caloriesController.clear();
        return;
    }

    final estimatedCalories =
        grams * _kcalPer100g! / 100;

    _caloriesController.text =
        estimatedCalories.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Log Feeding',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _foodController,
                decoration: const InputDecoration(
                  labelText: 'Search Food',
                  hintText: 'e.g. Chicken, egg, Royal Canin',
                  prefixIcon: Icon(Icons.search)
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Enter a food name'
                        : null,
                onChanged: _onFoodChanged,
              ),

              if (isSearching)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),

              if (foods.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      final name = food['name']?.toString() ?? 'Unknown food';
                      final calories =
                          (food['kcalPer100g'] as num?)?.toDouble();

                      return ListTile(
                        title: Text(name),
                        subtitle: Text(
                          calories == null
                              ? 'Calories unavailable'
                              : '${calories.toStringAsFixed(1)} kcal / 100 g',
                        ),
                        onTap: () {
                          _debounce?.cancel();
                          _searchVersion++;

                          setState(() {
                            _foodController.text = name;
                            _kcalPer100g = calories;
                            foods = [];
                            isSearching = false;
                          });

                          _calculateCalories();
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _mealType,
                decoration: const InputDecoration(
                  labelText: 'Meal Type',
                ),
                items: [
                  'Breakfast',
                  'Lunch',
                  'Dinner',
                  'Snack',
                ].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _mealType = value);
                  }
                },
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                      validator: (value) {
                        final number = double.tryParse(
                          value?.trim() ?? '',
                        );

                        if (number == null ||
                            !number.isFinite ||
                            number <= 0) {
                          return 'Enter a valid amount';
                        }

                        return null;
                      },
                      onChanged: (value) {
                        _calculateCalories();
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                      ),
                      items: ['g', 'oz', 'cups'].map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _unit = value);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _caloriesController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Calories (optional)',
                  suffixText: 'kcal',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }

                  final number = double.tryParse(value.trim());

                  if (number == null ||
                      !number.isFinite ||
                      number < 0) {
                    return 'Enter valid calories';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Meal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
