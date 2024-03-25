//로그인
class UserModel {
  final int userId;

  UserModel({required this.userId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['data']['user_id'] as int,
    );
  }
}

//아이디 중복조회
class SignUpResponse {
  final int status;
  final String message;
  final bool data;

  SignUpResponse(
      {required this.status, required this.message, required this.data});

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    return SignUpResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'],
    );
  }
}

//회원가입
class SignUp {
  final int status;
  final String message;
  final int userId;

  SignUp({
    required this.status,
    required this.message,
    required this.userId,
  });

  // JSON에서 SignUpResponse 객체로 변환
  factory SignUp.fromJson(Map<String, dynamic> json) {
    return SignUp(
      status: json['status'],
      message: json['message'],
      userId: json['data']['user_id'] as int,
    );
  }
}

//회원조회
class UserReference {
  final String loginId;
  final String password; // 비밀번호를 클라이언트 측에 저장하는 것은 권장되지 않습니다.
  final String nickname;
  final String characterUrl;
  final int tomato;

  UserReference({
    required this.loginId,
    required this.password,
    required this.nickname,
    required this.characterUrl,
    required this.tomato,
  });

  factory UserReference.fromJson(Map<String, dynamic> json) {
    return UserReference(
      loginId: json['login_id'] as String,
      password: json['password'] as String,
      nickname: json['nickname'] as String,
      characterUrl: json['character_url'] as String,
      tomato: json['tomato'] as int,
    );
  }
}

class UserUpdateResponse {
  final int status;
  final String message;
  final int userId;

  UserUpdateResponse({
    required this.status,
    required this.message,
    required this.userId,
  });

  factory UserUpdateResponse.fromJson(Map<String, dynamic> json) {
    return UserUpdateResponse(
      status: json['status'],
      message: json['message'],
      userId: json['data']['user_id'],
    );
  }
}
