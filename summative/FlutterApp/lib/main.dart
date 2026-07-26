import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'theme.dart';
import 'valid_values.dart';

const _predictUrl = 'https://linear-regression-model-3iyp.onrender.com/predict';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bobo',
      theme: buildBoboTheme(),
      debugShowCheckedModeBanner: false,
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

  Widget _sectionTitle(String text, {IconData? icon, Color? accentColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            text,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: BoboColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, {List<String>? options}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      helperText: options == null ? null : 'Accepted: ${options.join(', ')}',
    );
  }

  TextStyle get _inputTextStyle =>
      GoogleFonts.nunito(fontWeight: FontWeight.w700, color: BoboColors.textDark, fontSize: 16);

  Widget _sectionCard({required Color tintColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: tintColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BoboColors.textDark.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  PreferredSizeWidget _buildHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(96),
      child: Container(
        decoration: BoxDecoration(
          color: BoboColors.cardBackground,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: BoboColors.coral.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: BoboColors.coral, shape: BoxShape.circle),
                  child: const Icon(Icons.child_care, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bobo',
                      style: GoogleFonts.nunito(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: BoboColors.textDark,
                      ),
                    ),
                    Text(
                      'Autism screening helper',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: BoboColors.textDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionCard(
                tintColor: BoboColors.mutedCoral,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle('About you', icon: Icons.person_rounded, accentColor: BoboColors.coralDark),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      style: _inputTextStyle,
                      decoration: _fieldDecoration('Age'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _genderController,
                      style: _inputTextStyle,
                      decoration: _fieldDecoration('Gender (f/m)', options: BoboValidValues.gender),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ethnicityController,
                      style: _inputTextStyle,
                      decoration: _fieldDecoration('Ethnicity', options: BoboValidValues.ethnicity),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contryOfResController,
                      style: _inputTextStyle,
                      decoration: _fieldDecoration('Country of residence', options: BoboValidValues.contryOfRes),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageGroupController,
                      style: _inputTextStyle,
                      decoration: _fieldDecoration('Age group (adult/child/adolescent)', options: BoboValidValues.ageGroup),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionCard(
                tintColor: BoboColors.mutedTeal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle('Background'),
                    TextFormField(
                      controller: _jundiceController,
                      style: _inputTextStyle,
                      decoration: _fieldDecoration('Jaundice at birth (yes/no)', options: BoboValidValues.jundice),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _austimController,
                      style: _inputTextStyle,
                      decoration:
                          _fieldDecoration('Family member with autism (yes/no)', options: BoboValidValues.austim),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usedAppBeforeController,
                      style: _inputTextStyle,
                      decoration: _fieldDecoration(
                        'Used screening app before (yes/no)',
                        options: BoboValidValues.usedAppBefore,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _relationController,
                      style: _inputTextStyle,
                      decoration: _fieldDecoration('Relation to person screened', options: BoboValidValues.relation),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _predict,
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  child: Text(
                    'Predict',
                    style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(color: BoboColors.coral),
                    const SizedBox(height: 12),
                    Text(
                      'One moment...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(color: BoboColors.textDark.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              if (!_isLoading && _resultText != null)
                Card(
                  color: BoboColors.softTeal,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: BoboColors.tealDark, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Predicted result: $_resultText',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: BoboColors.tealDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!_isLoading && _errorText != null)
                Card(
                  color: BoboColors.softCoral,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_rounded, color: BoboColors.coralDark, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _errorText!,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: BoboColors.coralDark,
                            ),
                          ),
                        ),
                      ],
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
