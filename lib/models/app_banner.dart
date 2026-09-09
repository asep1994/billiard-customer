import '../core/api_client.dart';

class AppBanner {
  AppBanner({required this.id, required this.title, required this.imageUrl});

  factory AppBanner.fromJson(Map<String, dynamic> json) {
    final rawImageUrl = json['image_url'] as String?;

    return AppBanner(
      id: json['id'] as int,
      title: json['title'] as String?,
      imageUrl: rawImageUrl != null ? resolveMediaUrl(rawImageUrl) : null,
    );
  }

  final int id;
  final String? title;
  final String? imageUrl;
}
