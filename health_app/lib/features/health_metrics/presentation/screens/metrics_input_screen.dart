import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../providers/metrics_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class MetricsInputScreen extends StatefulWidget {
  const MetricsInputScreen({super.key});

  @override
  State<MetricsInputScreen> createState() => _MetricsInputScreenState();
}

class _MetricsInputScreenState extends State<MetricsInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _cholesterolController = TextEditingController();
  final _ldlController = TextEditingController();
  final _hdlController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _bloodSugarController.dispose();
    _cholesterolController.dispose();
    _ldlController.dispose();
    _hdlController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveMetrics() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final metricsProvider = context.read<MetricsProvider>();

    final metricsData = {
      'date': _selectedDate.toIso8601String(),
      'metrics': {
        if (_systolicController.text.isNotEmpty && _diastolicController.text.isNotEmpty)
          'bloodPressure': {
            'systolic': int.parse(_systolicController.text),
            'diastolic': int.parse(_diastolicController.text),
          },
        if (_bloodSugarController.text.isNotEmpty)
          'bloodSugar': double.parse(_bloodSugarController.text),
        if (_cholesterolController.text.isNotEmpty ||
            _ldlController.text.isNotEmpty ||
            _hdlController.text.isNotEmpty)
          'cholesterol': {
            if (_cholesterolController.text.isNotEmpty)
              'total': double.parse(_cholesterolController.text),
            if (_ldlController.text.isNotEmpty) 'ldl': double.parse(_ldlController.text),
            if (_hdlController.text.isNotEmpty) 'hdl': double.parse(_hdlController.text),
          },
        if (_weightController.text.isNotEmpty)
          'weight': double.parse(_weightController.text),
      },
      if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
    };

    final success = await metricsProvider.saveMetrics(metricsData);

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health metrics saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(metricsProvider.errorMessage ?? 'Failed to save metrics'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Health Metrics'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date Selection
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectDate,
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Blood Pressure Section
            _buildSectionHeader('Blood Pressure', Icons.favorite),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _systolicController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Systolic (mmHg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.arrow_upward),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = int.tryParse(value);
                        if (num == null || num < 70 || num > 250) {
                          return 'Invalid value (70-250)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _diastolicController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Diastolic (mmHg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.arrow_downward),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = int.tryParse(value);
                        if (num == null || num < 40 || num > 150) {
                          return 'Invalid value (40-150)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Blood Sugar Section
            _buildSectionHeader('Blood Sugar', Icons.bloodtype),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bloodSugarController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Blood Sugar (mg/dL)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.water_drop),
                suffixText: 'mg/dL',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final num = double.tryParse(value);
                  if (num == null || num < 50 || num > 600) {
                    return 'Invalid value (50-600)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Cholesterol Section
            _buildSectionHeader('Cholesterol', Icons.monitor_heart),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cholesterolController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Cholesterol (mg/dL)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.show_chart),
                suffixText: 'mg/dL',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final num = double.tryParse(value);
                  if (num == null || num < 100 || num > 400) {
                    return 'Invalid value (100-400)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ldlController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'LDL (mg/dL)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixText: 'mg/dL',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = double.tryParse(value);
                        if (num == null || num < 50 || num > 250) {
                          return 'Invalid value (50-250)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _hdlController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'HDL (mg/dL)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixText: 'mg/dL',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final num = double.tryParse(value);
                        if (num == null || num < 20 || num > 100) {
                          return 'Invalid value (20-100)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Weight Section
            _buildSectionHeader('Weight', Icons.monitor_weight),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.scale),
                suffixText: 'kg',
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final num = double.tryParse(value);
                  if (num == null || num < 2 || num > 300) {
                    return 'Invalid value (2-300)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Notes Section
            _buildSectionHeader('Notes', Icons.note),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveMetrics,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Metrics',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}