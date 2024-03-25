class CategoryModel {
  final int categoryId;
  final String title;
  final String color;
  final int tomato;

  CategoryModel({
    required this.categoryId,
    required this.title,
    required this.color,
    required this.tomato,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'],
      title: json['title'],
      color: json['color'],
      tomato: json['tomato'],
    );
  }
}

