class ListItems {
  DateTime? time;
  List<dynamic> itemList;

  ListItems({this.time, this.itemList = const []});

  // Convert ListItems object to JSON
  Map<String, dynamic> toJson() {
    return {
      'time': time?.toIso8601String(),
      'itemList': itemList.map((item) {
        if (item is ListItems) {
          return item.toJson();
        }
        return item;
      }).toList(),
    };
  }

  // Create a ListItems object from JSON
  factory ListItems.fromJson(Map<String, dynamic> json) {
    return ListItems(
      time: json['time'] != null ? DateTime.parse(json['time']) : null,
      itemList: (json['itemList'] as List<dynamic>).map((item) {
        if (item is Map<String, dynamic> &&
            item.containsKey('time') &&
            item.containsKey('itemList')) {
          return ListItems.fromJson(
              item); // Recursively convert JSON to ListItems
        }
        return item; // Assume it's a basic type (e.g., String, int)
      }).toList(),
    );
  }
}