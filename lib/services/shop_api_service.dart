import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tomado/models/tomado_model.dart';

class ShopApiService {
  final String baseUrl =
      "http://43.201.79.243:8080/shop"; // 기본 URL, 실제 서버 URL로 변경해야 합니다.

  // 사용자 ID로 기본 토마토 모델 리스트를 가져오는 메서드
  Future<Map<String, List<TomadoModel>>> fetchTomatoData(int userId) async {
  final url = Uri.parse('$baseUrl?user=$userId');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data is Map) {
      final List<dynamic> tomadoHaveList = data['data']['tomadoHaveList'];
      final List<dynamic> tomadoNotHaveList = data['data']['tomadoNotHaveList'];

      List<TomadoModel> haveList = tomadoHaveList.map((item) => TomadoModel.fromJson(item)).toList();
      List<TomadoModel> notHaveList = tomadoNotHaveList.map((item) => TomadoModel.fromJson(item)).toList();

      return {
        'have': haveList,
        'notHave': notHaveList,
      };
    } else {
      throw Exception('Invalid response format');
    }
  } else if (response.statusCode == 404) {
    throw Exception('존재하지 않는 회원');
  } else {
    throw Exception('Failed to load tomados: Status code ${response.statusCode}');
  }
}


  //토마토 ID로 토마토의 세부 정보를 가져오는 메서드
  Future<TomatoDetailModel> fetchTomatoDetail(int tomatoId) async {
    final url = Uri.parse('$baseUrl/$tomatoId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse =
          jsonDecode(utf8.decode(response.bodyBytes));
      // 'data' 필드에서 세부 정보를 추출
      final tomatoDetailData = jsonResponse['data'];
      if (tomatoDetailData != null) {
        return TomatoDetailModel.fromJson(tomatoDetailData, tomatoId);
      } else {
        throw Exception('토마토 세부 정보가 없습니다.');
      }
    } else {
      throw Exception('토마토 세부 정보를 가져오는 데 실패했습니다: ${response.body}');
    }
  }

  Future<void> buyTomato(int userId, int tomatoId) async {
    var url = Uri.parse('$baseUrl?user=$userId&tomado=$tomatoId');

    var response = await http.post(url);

    if (response.statusCode == 200) {
      print('구매성공');
    } else {
      throw Exception(
          '구매 실패: ${jsonDecode(utf8.decode(response.bodyBytes))['message']}');
    }
  }
}
