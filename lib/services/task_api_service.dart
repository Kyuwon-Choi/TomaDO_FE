import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tomado/models/task_model.dart';

class TaskApiService {
  final String baseUrl =
      "http://43.201.79.243:8080/tasks"; // 기본 URL, 실제 서버 URL로 변경해야 합니다.

  Future<int> createTask(int userId, int categoryId, String title) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'category_id': categoryId,
        'title': title,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['data']['task_id'] as int;
    } else {
      throw Exception('Task 생성 실패: ${response.body}');
    }
  }

  Future<void> addToma(int userId, int taskId) async {
    final url = Uri.parse('$baseUrl/toma');
    final now = DateTime.now();
    final createdAt = now.toIso8601String();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'task_id': taskId,
        'created_at': createdAt,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Task 상태 업데이트 실패: ${response.body}');
    }
  }

  Future<List<TaskModel>> fetchMonth(int userId, int month) async {
    final url = Uri.parse('$baseUrl?user=$userId&month=$month');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      // 'data' 키 아래 'tomaCountList' 리스트에 접근
      List jsonResponse = jsonDecode(response.body)['data']['tomaCountList'];
      // TaskModel.fromJsonList 정적 메소드를 사용하여 List<TaskModel> 반환
      return TaskModel.fromJsonList(jsonResponse);
    } else {
      throw Exception('Failed to load month data: ${response.statusCode}');
    }
  }

  Future<void> addHardToma(int userId, int taskId) async {
    final url = Uri.parse('$baseUrl/hard');
    final now = DateTime.now();
    final createdAt = now.toIso8601String();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'task_id': taskId,
        'created_at': createdAt,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Task 상태 업데이트 실패: ${response.body}');
    }
  }
}
