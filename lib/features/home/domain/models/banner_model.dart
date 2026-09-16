class BannerModel {
  final int id;
  final String? title;
  final String imageUrl;
  final String? actionLink;

  const BannerModel({
    required this.id,
    this.title,
    required this.imageUrl,
    this.actionLink,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      title: json['title'] as String?,
      imageUrl: json['image_url'] as String,
      actionLink: json['action_link'] as String?,
    );
  }
}