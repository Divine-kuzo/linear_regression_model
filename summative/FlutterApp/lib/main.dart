import 'package:flutter/material.dart';

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
            ],
          ),
        ),
      ),
    );
  }
}
