class MemoModel {
  final int id;
  final String content;
  final DateTime createdAt;

  MemoModel({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory MemoModel.fromJson(Map<String, dynamic> json) {
    return MemoModel(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
