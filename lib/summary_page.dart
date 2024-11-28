import 'package:flutter/material.dart';
import 'db_helper.dart';

class SummaryPage extends StatelessWidget {
  final DBHelper _dbHelper = DBHelper();

  Future<Map<String, double>> _getMonthlySummary() async {
    final transactions = await _dbHelper.getTransactions();
    double totalIncome = 0;
    double totalExpense = 0;

    transactions.forEach((transaction) {
      if (transaction.type == 'Pemasukan') {
        totalIncome += transaction.amount;
      } else if (transaction.type == 'Pengeluaran') {
        totalExpense += transaction.amount;
      }
    });

    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ringkasan Bulanan'),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: _getMonthlySummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pemasukan Bulanan: ${data['totalIncome']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Pengeluaran Bulanan: ${data['totalExpense']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Saldo Akhir: ${data['totalIncome']! - data['totalExpense']!}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
