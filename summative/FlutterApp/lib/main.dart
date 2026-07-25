import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _predictUrl = 'https://linear-regression-model-3iyp.onrender.com/predict';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autism Screening Predictor',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const PredictionPage(),
    );
  }
}

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _ethnicityController = TextEditingController();
  final _jundiceController = TextEditingController();
  final _austimController = TextEditingController();
  final _contryOfResController = TextEditingController();
  final _usedAppBeforeController = TextEditingController();
  final _relationController = TextEditingController();
  final _ageGroupController = TextEditingController();

  bool _isLoading = false;
  String? _resultText;
  String? _errorText;

  Future<void> _predict() async {
    setState(() {
      _isLoading = true;
      _resultText = null;
      _errorText = null;
    });

    try {
      final body = jsonEncode({
        'age': num.tryParse(_ageController.text) ?? _ageController.text,
        'gender': _genderController.text.trim(),
        'ethnicity': _ethnicityController.text.trim(),
        'jundice': _jundiceController.text.trim(),
        'austim': _austimController.text.trim(),
        'contry_of_res': _contryOfResController.text.trim(),
        'used_app_before': _usedAppBeforeController.text.trim(),
        'relation': _relationController.text.trim(),
        'age_group': _ageGroupController.text.trim(),
      });

      final response = await http.post(
        Uri.parse(_predictUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() => _resultText = decoded['predicted_result'].toString());
      } else {
        setState(() => _errorText = _describeError(decoded));
      }
    } catch (e) {
      setState(() => _errorText = 'Could not reach the server. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _describeError(dynamic decoded) {
    final detail = decoded is Map ? decoded['detail'] : null;
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      return detail.map((e) => e is Map ? e['msg'] ?? e.toString() : e.toString()).join('\n');
    }
    return 'Invalid input. Please check the values and try again.';
  }

  @override
  void dispose() {
    _ageController.dispose();
    _genderController.dispose();
    _ethnicityController.dispose();
    _jundiceController.dispose();
    _austimController.dispose();
    _contryOfResController.dispose();
    _usedAppBeforeController.dispose();
    _relationController.dispose();
    _ageGroupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gender (f/m)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ethnicityController,
                decoration: const InputDecoration(labelText: 'Ethnicity'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jundiceController,
                decoration: const InputDecoration(labelText: 'Jaundice at birth (yes/no)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _austimController,
                decoration: const InputDecoration(labelText: 'Family member with autism (yes/no)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contryOfResController,
                decoration: const InputDecoration(labelText: 'Country of residence'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usedAppBeforeController,
                decoration: const InputDecoration(labelText: 'Used screening app before (yes/no)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _relationController,
                decoration: const InputDecoration(labelText: 'Relation to person screened'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageGroupController,
                decoration: const InputDecoration(labelText: 'Age group (adult/child/adolescent)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _predict,
                child: const Text('Predict'),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              if (!_isLoading && _resultText != null)
                Card(
                  color: Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Predicted result: $_resultText',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (!_isLoading && _errorText != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _errorText!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
