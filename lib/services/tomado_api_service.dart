import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tomado/models/tomado_model.dart';

class TomatoApiService {
  final String baseUrl =
      "http://43.201.79.243:8080/book"; // 기본 URL, 실제 서버 URL로 변경해야 합니다.

  // 사용자 ID로 기본 토마토 모델 리스트를 가져오는 메서드
  Future<List<TomatoModel>> fetchTomatoModels(int userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/tomados');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('성공');
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        final categoryList = data['data'];
        if (categoryList is List) {
          return categoryList
              .map((item) => TomatoModel.fromJson(item))
              .toList();
        }
      }
      throw Exception('Invalid response format');
    } else if (response.statusCode == 404) {
      throw Exception('존재하지 않는 회원');
    } else {
      throw Exception(
          'Failed to load categories: Status code ${response.statusCode}');
    }
  }

  // 사용자 ID와 토마토 ID로 토마토의 세부 정보를 가져오는 메서드
  Future<TomatoDetailModel> fetchTomatoDetail(int userId, int tomatoId) async {
    final url = Uri.parse('$baseUrl?user=$userId&tomado=$tomatoId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return TomatoDetailModel.fromJson(jsonResponse, tomatoId);
    } else {
      throw Exception('토마토 세부 정보를 가져오는 데 실패했습니다: ${response.body}');
    }
  }
}
