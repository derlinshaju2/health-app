import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../providers/diet_provider.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadFoodLog();
  }

  Future<void> _loadFoodLog() async {
    final dateString = _selectedDate.toIso8601String().split('T')[0];
    final dietProvider = context.read<DietProvider>();
    await dietProvider.fetchFoodLog(dateString);
  }

  @override
  Widget build(BuildContext context) {
    final dietProvider = context.watch<DietProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: dietProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : dietProvider.foodLog.isEmpty
              ? _buildEmptyState()
              : _buildFoodLogContent(dietProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFoodDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fastfood_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No food logged for this date',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first meal',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodLogContent(DietProvider provider) {
    return Column(
      children: [
        // Date Header
        _buildDateHeader(),
        const SizedBox(height: 16),

        // Daily Summary
        _buildDailySummary(provider),
        const SizedBox(height: 16),

        // Food Log List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.foodLog.length,
            itemBuilder: (context, index) {
              final log = provider.foodLog[index];
              return _buildFoodLogCard(log);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader() {
    return Card(
      color: AppColors.secondary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Log',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(_selectedDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              onPressed: _selectDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummary(DietProvider provider) {
    // Calculate totals from food log
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFats = 0;

    for (var log in provider.foodLog) {
      totalCalories += log['calories'] as int? ?? 0;
      totalProtein += log['protein'] as int? ?? 0;
      totalCarbs += log['carbs'] as int? ?? 0;
      totalFats += log['fats'] as int? ?? 0;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Calories',
                  '$totalCalories kcal',
                  Icons.local_fire_department,
                  AppColors.primary,
                ),
                _buildSummaryItem(
                  'Protein',
                  '${totalProtein}g',
                  Icons.fitness_center,
                  AppColors.secondary,
                ),
                _buildSummaryItem(
                  'Carbs',
                  '${totalCarbs}g',
                  Icons.grain,
                  AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFoodLogCard(dynamic log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    log['foodName'] ?? 'Unknown Food',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${log['calories'] ?? 0} kcal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            if (log['mealType'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  log['mealType'],
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildNutrientChip('Protein', '${log['protein'] ?? 0}g'),
                _buildNutrientChip('Carbs', '${log['carbs'] ?? 0}g'),
                _buildNutrientChip('Fats', '${log['fats'] ?? 0}g'),
                if (log['fiber'] != null) _buildNutrientChip('Fiber', '${log['fiber']}g'),
              ],
            ),
            if (log['notes'] != null && log['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                log['notes'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadFoodLog();
    }
  }

  void _showAddFoodDialog() {
    final formKey = GlobalKey<FormState>();
    final foodNameController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatsController = TextEditingController();
    final notesController = TextEditingController();
    String selectedMealType = 'Snack';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Food Log'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: foodNameController,
                    decoration: const InputDecoration(
                      labelText: 'Food Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedMealType,
                    decoration: const InputDecoration(
                      labelText: 'Meal Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                      DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                      DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                      DropdownMenuItem(value: 'Snack', child: Text('Snack')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedMealType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: caloriesController,
                          decoration: const InputDecoration(
                            labelText: 'Calories',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: proteinController,
                          decoration: const InputDecoration(
                            labelText: 'Protein (g)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: carbsController,
                          decoration: const InputDecoration(
                            labelText: 'Carbs (g)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: fatsController,
                          decoration: const InputDecoration(
                            labelText: 'Fats (g)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final dietProvider = context.read<DietProvider>();
                  final success = await dietProvider.addFoodLog({
                    'foodName': foodNameController.text,
                    'mealType': selectedMealType,
                    'calories': int.tryParse(caloriesController.text) ?? 0,
                    'protein': int.tryParse(proteinController.text) ?? 0,
                    'carbs': int.tryParse(carbsController.text) ?? 0,
                    'fats': int.tryParse(fatsController.text) ?? 0,
                    'notes': notesController.text,
                    'date': _selectedDate.toIso8601String(),
                  });

                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Food log added successfully')),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(dietProvider.errorMessage ?? 'Failed to add food log'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}