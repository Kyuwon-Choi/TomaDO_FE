class TomatoModel {
  final String name;
  final String url;
  final int tomato_id;

  TomatoModel({
    required this.name,
    required this.url,
    required this.tomato_id,
  });

  factory TomatoModel.fromJson(Map<String, dynamic> json) {
    return TomatoModel(
      name: json['name'],
      url: json['url'],
      tomato_id: json['tomato_id'] as int? ?? 0,
    );
  }
}

class TomatoDetailModel {
  final TomatoModel tomatoModel;
  final String content;
  final int tomato;
  final int tomatoId;

  TomatoDetailModel({
    required this.tomatoModel,
    required this.content,
    required this.tomato,
    required this.tomatoId,
  });

  factory TomatoDetailModel.fromJson(Map<String, dynamic> json, int tomatoId) {
    final tomatoModel = TomatoModel(
      name: json['name'] as String,
      url: json['url'] as String,
      tomato_id: json['tomato_id'] as int? ?? 0, // null일 경우 기본값으로 0을 사용
    );

    return TomatoDetailModel(
      tomatoModel: tomatoModel,
      content: json['content'] as String,
      tomato: json['tomato'] as int? ?? 0,
      tomatoId: tomatoId, // null일 경우 기본값으로 0을 사용
    );
  }
}
class TomadoModel {
  final int tomadoId;
  final String url;
  final String name;
  final String content;
  final int tomato;

  TomadoModel({
    required this.tomadoId,
    required this.url,
    required this.name,
    required this.content,
    required this.tomato,
  });

  factory TomadoModel.fromJson(Map<String, dynamic> json) {
    return TomadoModel(
      tomadoId: json['tomado_id'],
      url: json['url'],
      name: json['name'],
      content: json['content'],
      tomato: json['tomato'],
    );
  }
}
