import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class QuantityDialog extends StatefulWidget {
  final String coinName;
  final Function(int quantity) onBuy;

  const QuantityDialog({
    Key? key,
    required this.coinName,
    required this.onBuy,
  }) : super(key: key);

  @override
  State<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);
      widget.onBuy(quantity);
      context.pop(); // close dialog
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Quantity for ${widget.coinName}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'Quantity (max 10000)',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter quantity';
            }
            final intValue = int.tryParse(value);
            if (intValue == null) return 'Enter a valid number';
            if (intValue <= 0) return 'Quantity must be greater than 0';
            if (intValue > 10000) return 'Quantity must be <= 10000';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Buy'),
        ),
      ],
    );
  }
}
