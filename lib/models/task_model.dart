import 'package:intl/intl.dart';

class TaskModel {
  final DateTime date;
  final int tomaCount;

  TaskModel({
    required this.date,
    required this.tomaCount,
  });

  // JSON에서 새 TaskModel 객체를 생성하는 팩토리 생성자
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      // JSON의 'date' 키를 사용하여 날짜 파싱
      date: DateTime.parse(json['date']),
      // JSON의 'tomaCount' 키를 사용하여 tomaCount 가져오기
      tomaCount: json['tomaCount'] as int,
    );
  }

  static List<TaskModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => TaskModel.fromJson(json)).toList();
  }
}
