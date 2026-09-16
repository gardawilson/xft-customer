/// Data model representing a single notification item.
class NotificationItem {
  final String id;
  final String title;
  final String body;

  /// Category label — typically `'Pesanan'` or `'Promo'`.
  final String category;
  final DateTime date;
  final bool isUnread;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.date,
    this.isUnread = true,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      body: json['message'] ?? '',
      category: json['category'] ?? '',
      date: DateTime.parse(json['created_at']),
      isUnread: json['is_read'] == false || json['is_read'] == 0,
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    String? category,
    DateTime? date,
    bool? isUnread,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      date: date ?? this.date,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}