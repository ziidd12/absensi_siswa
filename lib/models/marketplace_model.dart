class MarketplaceResponse {
  final String status;
  final MarketplaceData data;

  MarketplaceResponse({required this.status, required this.data});

  factory MarketplaceResponse.fromJson(Map<String, dynamic> json) {
    return MarketplaceResponse(
      status: json['status'],
      data: MarketplaceData.fromJson(json['data']),
    );
  }
}

class MarketplaceData {
  final int balance;
  final List<FlexibilityItem> items;

  MarketplaceData({required this.balance, required this.items});

  factory MarketplaceData.fromJson(Map<String, dynamic> json) {
    return MarketplaceData(
      balance: json['balance'],
      items: (json['items'] as List)
          .map((i) => FlexibilityItem.fromJson(i))
          .toList(),
    );
  }
}

class FlexibilityItem {
  final int id;
  final String itemName;
  final int pointCost;
  final int stockLimit;

  FlexibilityItem({
    required this.id,
    required this.itemName,
    required this.pointCost,
    required this.stockLimit,
  });

  factory FlexibilityItem.fromJson(Map<String, dynamic> json) {
    return FlexibilityItem(
      id: json['id'],
      itemName: json['item_name'],
      pointCost: json['point_cost'],
      stockLimit: json['stock_limit'],
    );
  }
}