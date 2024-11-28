import 'package:flutter/material.dart';
import 'transaction_model.dart' as my_model;
import 'db_helper.dart';

class AddEditTransactionPage extends StatefulWidget {
  final my_model.Transaction? transaction;

  AddEditTransactionPage({this.transaction});

  @override
  _AddEditTransactionPageState createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'Pemasukan';
  DateTime _selectedDate = DateTime.now(); // Tambahkan variabel untuk tanggal transaksi
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedType = widget.transaction!.type;
      _selectedDate = widget.transaction!.date; // Setel tanggal transaksi
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final newTransaction = my_model.Transaction(
        id: widget.transaction?.id,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate, // Gunakan tanggal yang dipilih
        type: _selectedType,
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

  void _deleteTransaction() {
    if (widget.transaction != null) {
      _dbHelper.deleteTransaction(widget.transaction!.id!).then((_) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      });
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
                decoration: InputDecoration(labelText: 'Judul'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Jumlah'),
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
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(labelText: 'Jenis Transaksi'),
                items: ['Pemasukan', 'Pengeluaran']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih jenis transaksi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tanggal: ${_selectedDate.toLocal()}'.split(' ')[0],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text('Pilih Tanggal'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _saveTransaction,
                    child: Text('Simpan'),
                  ),
                  if (widget.transaction != null)
                    ElevatedButton(
                      onPressed: _deleteTransaction,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text('Hapus'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
