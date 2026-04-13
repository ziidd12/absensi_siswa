class PointLedger {
  final int id;
  final String transactionType; // EARN, SPEND, PENALTY
  final int amount;
  final int currentBalance;
  final String description;
  final String createdAt;

  PointLedger({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.currentBalance,
    required this.description,
    required this.createdAt,
  });

  // Fungsi konversi dari JSON API ke Object Flutter
  factory PointLedger.fromJson(Map<String, dynamic> json) {
    return PointLedger(
      id: json['id'],
      transactionType: json['transaction_type'],
      amount: json['amount'],
      currentBalance: json['current_balance'],
      description: json['description'],
      createdAt: json['created_at'],
    );
  }
}