class NoticeModel {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;

  const NoticeModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) => NoticeModel(
        id:        json['id'],
        title:     json['title'],
        body:      json['body'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {'title': title, 'body': body};
}
