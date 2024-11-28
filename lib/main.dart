import 'package:flutter/material.dart';
import 'add_edit_transaction_page.dart';
import 'summary_page.dart';
import 'db_helper.dart';
import 'transaction_model.dart' as my_model;

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [HomePage(), SummaryPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Summary',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final DBHelper _dbHelper = DBHelper();
  late List<my_model.Transaction> _transactions = [];
  late List<my_model.Transaction> _filteredTransactions = [];
  String _selectedMonthFilter = 'Semua';
  String _selectedTypeFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await _dbHelper.getTransactions();
    setState(() {
      _transactions = transactions;
      _applyFilter();
    });
  }

  void _applyFilter() {
    _filteredTransactions = _transactions.where((transaction) {
      final bool matchesMonth = _selectedMonthFilter == 'Semua' ||
          (transaction.date.month == 10 && _selectedMonthFilter == 'Oktober') ||
          (transaction.date.month == 11 && _selectedMonthFilter == 'November');
      final bool matchesType = _selectedTypeFilter == 'Semua' ||
          transaction.type == _selectedTypeFilter;
      return matchesMonth && matchesType;
    }).toList();
  }

  Future<void> _navigateToAddEditTransaction({my_model.Transaction? transaction}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditTransactionPage(transaction: transaction)),
    );
    if (result == true) {
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = _filteredTransactions[index];
                return ListTile(
                  title: Text(transaction.title),
                  subtitle: Text('${transaction.date} - ${transaction.type}'),
                  trailing: Text(transaction.amount.toString()),
                  onTap: () => _navigateToAddEditTransaction(transaction: transaction),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: _selectedMonthFilter,
                  items: ['Semua', 'Oktober', 'November']
                      .map((filter) => DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonthFilter = value!;
                      _applyFilter();
                    });
                  },
                ),
                DropdownButton<String>(
                  value: _selectedTypeFilter,
                  items: ['Semua', 'Pemasukan', 'Pengeluaran']
                      .map((filter) => DropdownMenuItem(
                            value: filter,
                            child: Text(filter),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTypeFilter = value!;
                      _applyFilter();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditTransaction(),
        child: Icon(Icons.add),
      ),
    );
  }
}
