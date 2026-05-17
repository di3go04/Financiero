import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';

class GoalForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const GoalForm({super.key, this.initialData});

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _currentController;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name'] ?? '');
    _targetController = TextEditingController(text: widget.initialData?['target_amount']?.toString() ?? '');
    _currentController = TextEditingController(text: widget.initialData?['current_amount']?.toString() ?? '');
    if (widget.initialData?['deadline'] != null) {
      _selectedDate = DateTime.parse(widget.initialData!['deadline']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      final data = {
        'user_id': userId,
        'name': _nameController.text.trim(),
        'target_amount': double.parse(_targetController.text.trim()),
        'current_amount': double.tryParse(_currentController.text.trim()) ?? 0.0,
        'deadline': _selectedDate?.toIso8601String(),
      };

      if (widget.initialData != null) {
        await supabase.from('savings_goals').update(data).eq('id', widget.initialData!['id']);
      } else {
        await supabase.from('savings_goals').insert(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialData != null ? 'Meta actualizada' : 'Meta creada'),
            backgroundColor: AppTheme.successBlue,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.expenseRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 32,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialData != null ? 'Editar Meta' : 'Nueva Meta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Meta',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Ingresa un nombre' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Monto Objetivo',
                  prefixIcon: Icon(Icons.track_changes_rounded),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Ingresa un monto';
                  if (double.tryParse(val) == null) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _currentController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Ahorro Actual',
                  prefixIcon: Icon(Icons.savings_outlined),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha Límite',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(
                    _selectedDate == null 
                        ? 'Seleccionar fecha' 
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text(
                      widget.initialData != null ? 'Actualizar Meta' : 'Crear Meta', 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
