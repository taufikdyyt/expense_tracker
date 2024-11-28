import 'package:flutter/material.dart';
import 'transaction_model.dart' as my_model;
import 'db_helper.dart';

class AddEditTransactionPage extends StatefulWidget {
  final my_model.Transaction? transaction; // Tambahkan parameter transaksi

  const AddEditTransactionPage({super.key, this.transaction});

  @override
  AddEditTransactionPageState createState() => AddEditTransactionPageState();
}

class AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final newTransaction = my_model.Transaction(
        id: widget.transaction?.id,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: DateTime.now(), type: '',
      );
      if (widget.transaction == null) {
        _dbHelper.insertTransaction(newTransaction).then((_) {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      } else {
        _dbHelper.updateTransaction(newTransaction).then((_) {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Tambah Transaksi' : 'Edit Transaksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Jumlah harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
