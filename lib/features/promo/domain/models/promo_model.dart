/// Data model for a promotional item shown in the promos list and detail page.
class PromoData {
  final int id;
  final String imageUrl;
  final String title;
  final String postDate;
  final String summary;
  final String? content;

  const PromoData({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.postDate,
    required this.summary,
    this.content,
  });

  factory PromoData.fromJson(Map<String, dynamic> json) {
    return PromoData(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
      title: json['title'] as String? ?? '',
      postDate: json['posted_at'] as String? ?? '',
      summary: json['short_description'] as String? ?? '',
      content: json['content'] as String?,
    );
  }
}