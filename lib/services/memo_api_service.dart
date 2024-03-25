import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tomado/models/memo_model.dart';

class MemoApiService {
  final String baseUrl =
      'http://43.201.79.243:8080/memos'; // 실제 API 엔드포인트로 변경하세요

  Future<List<MemoModel>> fetchMemoList(int userId) async {
    var url = Uri.parse('$baseUrl/$userId'); // 엔드포인트 수정이 필요할 수 있습니다
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> memoListJson =
          jsonDecode(utf8.decode(response.bodyBytes))['data']['memoList'];

      return memoListJson.map((json) => MemoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load memos: ${response.statusCode}');
    }
  }

  Future<void> createMemo(int userId, String content) async {
    var url = Uri.parse('$baseUrl/$userId');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      // 메모 작성 성공, 필요한 경우 여기서 추가 처리를 수행합니다.
      print('메모 작성 성공: ${response.body}');
    } else {
      // 서버로부터 받은 응답을 기반으로 오류 메시지를 생성합니다.
      var responseData = json.decode(response.body);
      throw Exception('Failed to create memo: ${responseData['message']}');
    }
  }
}
