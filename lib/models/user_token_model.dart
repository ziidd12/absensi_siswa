import 'marketplace_model.dart';

class UserInventoryResponse {
  final String status;
  final List<UserToken> data;

  UserInventoryResponse({required this.status, required this.data});

  factory UserInventoryResponse.fromJson(Map<String, dynamic> json) {
    return UserInventoryResponse(
      status: json['status'],
      data: (json['data'] as List)
          .map((i) => UserToken.fromJson(i))
          .toList(),
    );
  }
}

class UserToken {
  final int id;
  final String status; // AVAILABLE, USED
  final DateTime? usedAt;
  final FlexibilityItem item; // Relasi ke detail item

  UserToken({
    required this.id,
    required this.status,
    this.usedAt,
    required this.item,
  });

  factory UserToken.fromJson(Map<String, dynamic> json) {
    return UserToken(
      id: json['id'],
      status: json['status'],
      usedAt: json['used_at'] != null ? DateTime.parse(json['used_at']) : null,
      item: FlexibilityItem.fromJson(json['item']),
    );
  }
}