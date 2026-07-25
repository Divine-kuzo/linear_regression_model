import 'dart:async';
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

  String? _validate() {
    final fields = {
      'Age': _ageController.text,
      'Gender': _genderController.text,
      'Ethnicity': _ethnicityController.text,
      'Jaundice at birth': _jundiceController.text,
      'Family member with autism': _austimController.text,
      'Country of residence': _contryOfResController.text,
      'Used screening app before': _usedAppBeforeController.text,
      'Relation to person screened': _relationController.text,
      'Age group': _ageGroupController.text,
    };

    for (final entry in fields.entries) {
      if (entry.value.trim().isEmpty) {
        return '${entry.key} is required.';
      }
    }

    final age = num.tryParse(_ageController.text.trim());
    if (age == null || age < 1 || age > 100) {
      return 'Age must be a number between 1 and 100.';
    }

    return null;
  }

  Future<void> _predict() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() {
        _resultText = null;
        _errorText = validationError;
      });
      return;
    }

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

      final response = await http
          .post(
            Uri.parse(_predictUrl),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 45));

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() => _resultText = decoded['predicted_result'].toString());
      } else {
        setState(() => _errorText = _describeError(decoded));
      }
    } on TimeoutException {
      setState(() => _errorText = 'The server took too long to respond. Please try again.');
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autism Screening Predictor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionTitle('About you'),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _genderController,
                        decoration: const InputDecoration(labelText: 'Gender (f/m)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ethnicityController,
                        decoration: const InputDecoration(labelText: 'Ethnicity', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contryOfResController,
                        decoration: const InputDecoration(labelText: 'Country of residence', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ageGroupController,
                        decoration: const InputDecoration(
                          labelText: 'Age group (adult/child/adolescent)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sectionTitle('Background'),
                      TextFormField(
                        controller: _jundiceController,
                        decoration: const InputDecoration(
                          labelText: 'Jaundice at birth (yes/no)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _austimController,
                        decoration: const InputDecoration(
                          labelText: 'Family member with autism (yes/no)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _usedAppBeforeController,
                        decoration: const InputDecoration(
                          labelText: 'Used screening app before (yes/no)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _relationController,
                        decoration: const InputDecoration(
                          labelText: 'Relation to person screened',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _predict,
                child: const Text('Predict'),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Waking up the server, this can take up to a minute on '
                      'the first request...',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
