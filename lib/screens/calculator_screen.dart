import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/attendance_math.dart';
import '../utils/validators.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _attendedController = TextEditingController();
  final _totalController = TextEditingController();
  final _targetController = TextEditingController(text: '75');

  // Results state
  double? _currentPercentage;
  int? _neededClasses;
  int? _safeSkips;
  bool _hasCalculated = false;

  @override
  void dispose() {
    _attendedController.dispose();
    _totalController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _calculate() {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final attended = int.parse(_attendedController.text);
    final total = int.parse(_totalController.text);
    final target = int.parse(_targetController.text);

    setState(() {
      _currentPercentage = AttendanceMath.currentPercentage(attended, total);
      _neededClasses = AttendanceMath.classesNeededToReach(attended, total, target);
      _safeSkips = AttendanceMath.safeSkips(attended, total, target);
      _hasCalculated = true;
    });

    // Dismiss keyboard
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Icon(
                    Icons.calculate,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Attendance Simulator',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Calculate how many classes you need to attend or can skip.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Inputs
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _attendedController,
                          decoration: const InputDecoration(
                            labelText: 'Attended',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) => AppValidators.validateNumber(value, 'Attended'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _totalController,
                          decoration: const InputDecoration(
                            labelText: 'Total Conducted',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            final attended = int.tryParse(_attendedController.text) ?? 0;
                            return AppValidators.validateTotalClasses(value, attended);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetController,
                    decoration: const InputDecoration(
                      labelText: 'Target Percentage (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => AppValidators.validateTarget(value),
                  ),

                  const SizedBox(height: 24),

                  // Calculate Button
                  FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Calculate Result'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Animated Results Section (Experiment 8)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _hasCalculated
                        ? _buildResultsCard(context)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    final isBelowTarget = _currentPercentage! < int.parse(_targetController.text);
    final mainColor = isBelowTarget ? Colors.red : Colors.green;

    return Card(
      key: const ValueKey('results'), // Required for AnimatedSwitcher
      elevation: 4,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Current Attendance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${_currentPercentage!.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: mainColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32),

            _buildResultRow(
              context,
              icon: Icons.arrow_upward,
              title: 'Classes needed to reach target:',
              value: _neededClasses == null
                  ? 'Impossible'
                  : _neededClasses == 0
                  ? 'Target Met!'
                  : '$_neededClasses',
              valueColor: _neededClasses == null ? Colors.red : Colors.green,
            ),

            const SizedBox(height: 16),

            _buildResultRow(
              context,
              icon: Icons.beach_access,
              title: 'Safe skips remaining:',
              value: _safeSkips == null
                  ? 'Infinite'
                  : '$_safeSkips',
              valueColor: _safeSkips == 0 ? Colors.orange : Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}