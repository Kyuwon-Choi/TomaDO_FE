import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tomado/data/preference_manager.dart';
import 'package:tomado/models/user_model.dart';

class UserApiService {
  static const String baseUrl = 'http://43.201.79.243:8080/users';

  //로그인
  Future<UserModel> login(String loginId, String password) async {
    var url = Uri.parse('$baseUrl/login');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login_id': loginId, 'password': password}),
    );

    if (response.statusCode == 200) {
      // 로그인 성공
      var userModel = UserModel.fromJson(json.decode(response.body));
      // 로그인 성공 후, 사용자 ID를 저장
      await PreferenceManager.saveUserId(userModel.userId.toString());
      return userModel;
    } else {
      // 실패 응답 처리 (404 또는 기타 오류)
      var responseData = json.decode(response.body);
      throw Exception(responseData['message']);
    }
  }

  //회원가입
  Future<SignUp> signUp(
      String loginId, String password, String nickname) async {
    var url = Uri.parse('$baseUrl/signup');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'login_id': loginId, 'password': password, 'nickname': nickname}),
    );
    print(response.body); // 서버 응답 전체를 로깅합니다.

    if (response.statusCode == 201 || response.statusCode == 200) {
      return SignUp.fromJson(json.decode(response.body));
    } else {
      var responseData = json.decode(response.body);
      throw Exception("회원가입 실패: ${responseData['message']}");
    }
  }

  //중복체크
  Future<bool> checkIdDuplicate(String loginId) async {
    var url = Uri.parse('$baseUrl/signup/exists');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'login_id': loginId}),
    );

    if (response.statusCode == 200) {
      return false;
    } else {
      var responseData = json.decode(response.body);
      throw Exception("아이디 중복:${responseData['message']}");
    }
  }
  //회원정보조회

  Future<UserReference> getUserInfo(String userId) async {
    var url = Uri.parse('$baseUrl/$userId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return UserReference.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes))['data']);
    } else if (response.statusCode == 404) {
      throw Exception('존재하지 않는 회원');
    } else {
      throw Exception('Failed to load user');
    }
  }

  //회원정보 수정

  Future<UserUpdateResponse> updateUserInfo(String userId, String loginID,
      String password, String nickname, String characterUrl) async {
    var url = Uri.parse('$baseUrl/$userId');
    var response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'login_id': loginID,
        'password': password,
        'nickname': nickname,
        'character_url': characterUrl,
      }),
    );

    if (response.statusCode == 200) {
      return UserUpdateResponse.fromJson(json.decode(response.body));
    } else {
      var responseData = json.decode(response.body);
      throw Exception('${responseData['status']}: ${responseData['message']}');
    }
  }
}
