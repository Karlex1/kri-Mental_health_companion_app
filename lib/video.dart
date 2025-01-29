class Video {
  final String videoId;
  final String title;
  final String description;
  final String thumbnail;

  Video({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnail,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      videoId: json['videoId'],
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
    );
  }
}
