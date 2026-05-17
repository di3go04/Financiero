import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/gemini_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../data/services/offline_service.dart';
import 'premium_button.dart';

class TransactionForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const TransactionForm({super.key, this.initialData});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late String _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  final List<String> _categories = [
    'Comida', 'Transporte', 'Ocio', 'Vivienda', 'Salud', 
    'Suscripciones', 'Educación', 'Compras', 'Otros'
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.initialData?['description'] ?? '');
    _amountController = TextEditingController(text: widget.initialData?['amount']?.toString() ?? '');
    _selectedType = widget.initialData?['type'] ?? 'expense';
    _selectedCategory = widget.initialData?['category'] ?? 'Otros';
    _selectedDate = widget.initialData != null 
        ? DateTime.parse(widget.initialData!['date']) 
        : DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

// ... inside _TransactionFormState ...

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _showError('Sesión no encontrada. Por favor inicia sesión de nuevo.');
      return;
    }

    setState(() => _isLoading = true);
    
    final amountValue = double.parse(_amountController.text.replaceAll(',', '.'));
    final Map<String, dynamic> data = {
      'user_id': user.id,
      'description': _descriptionController.text.trim(),
      'amount': amountValue,
      'category': _selectedCategory,
      'type': _selectedType,
      'date': _selectedDate.toIso8601String().split('T')[0],
    };

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        await OfflineService.saveTransactionOffline(data);
        if (mounted) {
          _showSuccess('Guardado localmente (Offline)');
          Navigator.pop(context);
        }
        return;
      }

      if (widget.initialData != null) {
        await _supabase.from('transactions').update(data).eq('id', widget.initialData!['id']);
      } else {
        await _supabase.from('transactions').insert(data);
      }

      if (mounted) {
        _showSuccess(widget.initialData != null ? 'Transacción actualizada' : 'Transacción guardada');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // If it fails due to network even if connectivity said OK, try offline
        await OfflineService.saveTransactionOffline(data);
        _showSuccess('Error de red. Guardado localmente.');
        Navigator.pop(context);
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.expenseRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _scanReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    try {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final data = await GeminiService.scanReceipt(base64Image);
      if (data != null && mounted) {
        setState(() {
          _descriptionController.text = data['merchant'] ?? '';
          _amountController.text = data['amount']?.toString() ?? '';
          if (_categories.contains(data['category'])) {
            _selectedCategory = data['category'];
          }
          _selectedType = 'expense';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recibo escaneado correctamente'), backgroundColor: AppTheme.successBlue),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al escanear: $e');
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
              _buildHeader(isDark),
              const SizedBox(height: 32),
              _buildTypeSelector(),
              const SizedBox(height: 32),
              _buildDescriptionInput(),
              const SizedBox(height: 20),
              _buildAmountInput(),
              const SizedBox(height: 20),
              _buildCategorySelector(),
              const SizedBox(height: 20),
              _buildDatePicker(isDark),
              const SizedBox(height: 40),
              PremiumButton(
                onPressed: _save,
                isLoading: _isLoading,
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: Text(
                    widget.initialData != null ? 'Actualizar' : 'Guardar Transacción', 
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.initialData != null ? 'Editar Movimiento' : 'Nuevo Movimiento',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: isDark ? AppTheme.textSnow : AppTheme.textSlate,
          ),
        ),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: _isLoading ? null : _scanReceipt,
              icon: const Icon(Icons.document_scanner_rounded),
              tooltip: 'Escanear Recibo',
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                foregroundColor: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            label: 'Gasto',
            isSelected: _selectedType == 'expense',
            color: AppTheme.expenseRed,
            onTap: () => setState(() => _selectedType = 'expense'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeButton(
            label: 'Ingreso',
            isSelected: _selectedType == 'income',
            color: AppTheme.successBlue,
            onTap: () => setState(() => _selectedType = 'income'),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descriptionController,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        labelText: 'Descripción',
        prefixIcon: Icon(Icons.description_outlined),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Ingresa una descripción' : null,
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: _amountController,
      style: const TextStyle(fontWeight: FontWeight.bold),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Monto',
        prefixIcon: Icon(Icons.attach_money_rounded),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Ingresa un monto';
        if (double.tryParse(val.replaceAll(',', '.')) == null) return 'Monto inválido';
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val!),
      decoration: const InputDecoration(
        labelText: 'Categoría',
        prefixIcon: Icon(Icons.category_outlined),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.borderDark.withValues(alpha: 0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppTheme.borderDark : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 20, color: AppTheme.primaryBlue),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
