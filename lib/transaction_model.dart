class Transaction {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String type; // Tambahkan properti type

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type, // Tambahkan parameter type
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type, // Tambahkan type ke map
    };
  }
}
