class PointHistoryResponse {
  final String status;
  final List<PointLedger> data;

  PointHistoryResponse({required this.status, required this.data});

  factory PointHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PointHistoryResponse(
      status: json['status'],
      data: (json['data'] as List)
          .map((i) => PointLedger.fromJson(i))
          .toList(),
    );
  }
}

class PointLedger {
  final int id;
  final String transactionType; // EARN, PENALTY, SPEND
  final int amount;
  final int currentBalance;
  final String description;
  final DateTime createdAt;

  PointLedger({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.currentBalance,
    required this.description,
    required this.createdAt,
  });

  factory PointLedger.fromJson(Map<String, dynamic> json) {
    return PointLedger(
      id: json['id'],
      transactionType: json['transaction_type'],
      amount: json['amount'],
      currentBalance: json['current_balance'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}