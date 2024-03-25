import 'package:flutter/material.dart';
import 'package:tomado/services/user_api_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isIdUnique = false; // 아이디 중복 상태를 추적하는 변수 추가

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('회원가입'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nicknameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '닉네임을 입력해주세요';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                    hintText: '닉네임',
                    prefixIcon: Icon(Icons.face),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 80),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _idController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '아이디를 입력해주세요';
                          }
                          if (!_isIdUnique) {
                            return '아이디 중복 검사를 해주세요';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: '아이디',
                          hintText: '아이디',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0xffE2E4E8)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          // 모서리 둥글게 설정
                          RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5), // 모서리의 둥글기 정도 설정
                          ),
                        ),
                      ),
                      onPressed: () async {
                        // 아이디 중복 검사 실행
                        var isUnique = await UserApiService()
                            .checkIdDuplicate(_idController.text);
                        setState(() {
                          // 중복이 없다면 isUnique == false이므로, _isIdUnique을 true로 설정
                          _isIdUnique = isUnique == false;
                        });

                        // 중복 검사 결과에 따른 사용자 피드백
                        if (!isUnique) {
                          // 중복이 없을 경우
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('사용 가능한 아이디입니다.')),
                          );
                        } else {
                          // 중복이 있는 경우
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('아이디가 이미 사용중입니다. 다른 아이디를 사용해주세요.')),
                          );
                        }
                      },
                      child: const Text(
                        '중복 확인',
                        style: TextStyle(color: Color(0xff84888F)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 최소 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '비밀번호',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isIdUnique
                        ? () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              try {
// 회원가입 진행
                                var signUpResponse =
                                    await UserApiService().signUp(
                                  _idController.text,
                                  _passwordController.text,
                                  _nicknameController.text,
                                );
                                // 회원 가입 성공 처리
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '회원가입 성공: ${signUpResponse.message}')),
                                );

                                // 회원가입 성공 후 로그인 화면으로 돌아가기
                                Navigator.pop(context);
                              } catch (e) {
                                // 회원 가입 실패 처리
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('회원가입 실패: $e')),
                                );
                              }
                            }
                          }
                        : null,
                    child: const Text('회원가입'), // _isIdUnique가 false일 경우 버튼 비활성화
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
