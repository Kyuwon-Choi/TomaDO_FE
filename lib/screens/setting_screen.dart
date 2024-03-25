import 'package:flutter/material.dart';
import 'package:tomado/data/preference_manager.dart';
import 'package:tomado/models/tomado_model.dart';
import 'package:tomado/models/user_model.dart';
import 'package:tomado/services/tomado_api_service.dart';
import 'package:tomado/services/user_api_service.dart';

//이거 나중에 처리하기

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _characterUrl;
  String? _userId;
  List<TomatoModel> characterList = [];
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCharacterList();
  }

  Future<void> _loadUserInfo() async {
    _userId = await PreferenceManager.getUserId();
    if (_userId != null) {
      final userInfo = await UserApiService().getUserInfo(_userId!);
      setState(() {
        _nicknameController.text = userInfo.nickname;
        _idController.text = userInfo.loginId;
        // _passwordController.text = userInfo.password;
        _characterUrl = userInfo.characterUrl;
      });
    }
  }

  Future<void> _loadCharacterList() async {
    final userId = await PreferenceManager.getUserId();
    if (userId != null) {
      try {
        final tomatoes =
            await TomatoApiService().fetchTomatoModels(int.parse(userId));
        setState(() {
          characterList = tomatoes;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('캐릭터 목록을 불러오는데 실패: $e')),
        );
      }
    }
  }

  Future<void> _updateUserInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        await UserApiService().updateUserInfo(
          _userId!,
          _idController.text,
          _passwordController.text,
          _nicknameController.text,
          _characterUrl!,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 정보가 성공적으로 업데이트되었습니다.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 정보 업데이트 실패: $e')),
        );
      }
    }
  }

  void _showCharacterSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GridView.builder(
          padding: const EdgeInsets.all(8), // 그리드의 패딩 설정
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 한 줄에 표시할 아이템의 수
            crossAxisSpacing: 10, // 가로 간격
            mainAxisSpacing: 10, // 세로 간격
            childAspectRatio: 1, // 아이템의 가로세로 비율
          ),
          itemCount: characterList.length, // 캐릭터 리스트의 길이
          itemBuilder: (context, index) {
            final character = characterList[index];
            return GestureDetector(
              onTap: () {
                _updateCharacterUrl(character.url); // 캐릭터 URL 업데이트
                Navigator.pop(context); // 하단 시트 닫기
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey, // 배경 색상
                      radius: 100, // 아이콘 크기
                      backgroundImage: NetworkImage(character.url), // 캐릭터 이미지
                    ),
                  ),
                  // 캐릭터 이름
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateCharacterUrl(String newUrl) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 ID를 불러올 수 없습니다.')),
      );
      return;
    }

    try {
      // 여기에서는 characterUrl만 업데이트하고, 나머지 사용자 정보는 변경하지 않습니다.
      await UserApiService().updateUserInfo(
        _userId!,
        _idController.text, // 기존 정보 유지
        _passwordController.text, // 기존 정보 유지
        _nicknameController.text, // 기존 정보 유지
        newUrl, // 새로운 캐릭터 URL
      );

      setState(() {
        _characterUrl = newUrl; // UI를 업데이트하기 위해 상태를 설정합니다.
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('캐릭터가 성공적으로 업데이트되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('캐릭터 업데이트 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Column(
        children: [
          const Text('계정정보 설정'),
          const SizedBox(
            height: 50,
          ),
          FutureBuilder<String?>(
            future: PreferenceManager.getUserId(), // 사용자 ID를 비동기적으로 가져옵니다.
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  final String? userId = snapshot.data;
                  _userId = snapshot.data; // 이제 userId는 String? 타입입니다.
                  if (userId != null) {
                    // 이제 userId를 사용하여 UserApiService.getUserInfo를 호출할 수 있습니다.
                    return FutureBuilder<UserReference>(
                      future: UserApiService()
                          .getUserInfo(userId), // userId가 null이 아니어야 합니다.
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // 사용자 정보 로딩 성공
                          _characterUrl = snapshot.data!.characterUrl;
                          return _ProfileImage(snapshot.data!);
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return const CircularProgressIndicator(); // 로딩 중
                        }
                      },
                    );
                  } else {
                    return const ListTile(title: Text('사용자 ID가 존재하지 않습니다.'));
                  }
                } else {
                  return const ListTile(title: Text('사용자 정보를 불러올 수 없습니다.'));
                }
              } else {
                return const CircularProgressIndicator(); // 초기 로딩 중
              }
            },
          ),
          Center(
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _idController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '아이디를 입력해주세요';
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
                    const SizedBox(height: 16),
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
                        child: const Text('수정'),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            try {
                              var signUpResponse =
                                  await UserApiService().updateUserInfo(
                                _userId!,
                                _idController.text,
                                _passwordController.text,
                                _nicknameController.text,
                                _characterUrl!,
                              );
                              // 회원 가입 성공 처리
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        '회원정보 수정 성공: ${signUpResponse.message}')),
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              // 회원 가입 실패 처리 (예외 처리)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ProfileImage(UserReference userRef) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 180, // 배경 원의 크기를 설정하세요
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey[200], // 배경 원의 색상
            shape: BoxShape.circle,
          ),
        ),
        CircleAvatar(
          radius: 60, // 프로필 이미지의 반지름을 설정하세요
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(userRef.characterUrl),
        ),
        Positioned(
          bottom: 0, // 편집 버튼의 위치를 조정하세요
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // 편집 버튼 배경색
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.black), // 편집 아이콘 색상
              onPressed: () {
                _showCharacterSelection();
              },
            ),
          ),
        ),
      ],
    );
  }
}
