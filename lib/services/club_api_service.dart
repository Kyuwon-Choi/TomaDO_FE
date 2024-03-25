import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tomado/models/club_model.dart';

class ClubApiService {
  final String baseUrl =
      "http://43.201.79.243:8080/clubs"; // 실제 API 엔드포인트로 변경하세요.

  Future<List<ClubModel>> fetchClubList(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> clubList = jsonResponse['data']['clubList'];

      return clubList.map((club) => ClubModel.fromJson(club)).toList();
    } else {
      throw Exception('클럽 리스트를 불러오는데 실패했습니다: ${response.statusCode}');
    }
  }

  Future<void> createClub({
    required int userId,
    required String title,
    required String color,
    required int memberNumber,
    required int goal,
    required String memo,
    required String startDate,
    required String endDate,
  }) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'color': color,
        'member_number': memberNumber,
        'goal': goal,
        'memo': memo,
        'start_date': startDate,
        'end_date': endDate,
      }),
    );

    if (response.statusCode == 200) {
      // 성공적으로 클럽이 생성되었을 때의 처리 로직
      print('클럽 생성 성공');
    } else {
      // 실패했을 때의 처리 로직
      print(response.body);
      throw Exception('클럽 생성 실패: ${response.body}');
    }
  }
}
