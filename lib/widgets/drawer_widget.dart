import 'package:flutter/material.dart';
import 'package:tomado/data/preference_manager.dart';
import 'package:tomado/models/user_model.dart';
import 'package:tomado/screens/club_screen.dart';
import 'package:tomado/screens/dashboard_screen.dart';
import 'package:tomado/screens/dictionary_screen.dart';
import 'package:tomado/screens/memo_screen.dart';
import 'package:tomado/screens/setting_screen.dart';
import 'package:tomado/screens/store_screen.dart';
import 'package:tomado/services/user_api_service.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          FutureBuilder<String?>(
            future: PreferenceManager.getUserId(), // 사용자 ID를 비동기적으로 가져옵니다.
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  final String? userId =
                      snapshot.data; // 이제 userId는 String? 타입입니다.
                  if (userId != null) {
                    // 이제 userId를 사용하여 UserApiService.getUserInfo를 호출할 수 있습니다.
                    return FutureBuilder<UserReference>(
                      future: UserApiService()
                          .getUserInfo(userId), // userId가 null이 아니어야 합니다.
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // 사용자 정보 로딩 성공
                          return _createDrawerHeader(snapshot.data!, context);
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
          ListTile(
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DashBoardScreen()),
              );
            },

            leading: Image.asset(
              'images/dashboard.jpg',
            ),
            title: const Text('모아보기'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ), // 오른쪽 화살표 아이콘
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClubScreen()),
              );
            },
            leading: Image.asset(
              'images/club.jpg',
            ),
            title: const Text('토마클럽'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ), //
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DictionaryScreen()),
              );
            },
            leading: Image.asset(
              'images/dictionary.jpg',
            ),
            title: const Text('토마도감'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ), //
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StoreScreen()),
              );
            },
            leading: Image.asset(
              'images/shop.jpg',
            ),
            title: const Text('토마상점'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ), //
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context); // Drawer 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MemoScreen()),
              );
            },
            leading: Image.asset(
              'images/memo.jpg',
            ),
            title: const Text('긴급메모'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ), //
          ),
        ],
      ),
    );
  }
}

Widget _createDrawerHeader(UserReference userRef, BuildContext context) {
  return SizedBox(
    height: 350, // 여기에 원하는 높이를 설정하세요
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 10, // 여백을 주고 싶으면 값을 조정하세요
          left: 120, // 왼쪽 여백을 주고 싶으면 값을 조정하세요
          child: Text(
            userRef.nickname, // 여기에 원하는 텍스트를 입력하세요
            style: const TextStyle(
              fontSize: 20, // 텍스트의 크기를 조정하세요
              fontWeight: FontWeight.bold, // 텍스트 스타일을 조정하세요
              color: Colors.black, // 텍스트 색상을 조정하세요
            ),
          ),
        ),
        // 배경
        Positioned(
          top: 50,
          right: 0,
          left: 0,
          child: Container(
            height: 180, // 원하는 배경의 높이를 설정하세요
            decoration: BoxDecoration(
              color: Colors.grey[200], // 원하는 배경 색상을 설정하세요
              shape: BoxShape.circle,
            ),
          ),
        ),
        // 프로필 이미지
        Positioned(
          top: 80,
          child: CircleAvatar(
            radius: 60, // 원하는 프로필 이미지의 반지름을 설정하세요
            backgroundColor: Colors.transparent,
            backgroundImage:
                NetworkImage(userRef.characterUrl), // 이전에 업로드된 이미지 사용
          ),
        ),

        // 수정 버튼
        Positioned(
          top: 185, // 위치 조정
          right: 75, // 위치 조정
          child: Container(
            width: 56, // FAB와 동일한 크기
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200], // 버튼의 배경 색상
              shape: BoxShape.circle, // 동그란 모양
              border: Border.all(color: Colors.white, width: 4), // 하얀색 테두리 추가
            ),
            child: InkWell(
              onTap: () {
                // 수정 버튼 클릭 시 SettingScreen으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const SettingScreen()), // SettingScreen으로 이동
                );
              },
              child: const Icon(
                Icons.edit,
                color: Colors.black, // 아이콘 색상
              ),
            ),
          ),
        ),

        // 개수
        Positioned(
          bottom: 60, // 위치 조정
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/tomadoNumber.png',
                  width: 40, height: 40, // 이미지가 컨테이너에 맞게 조정되도록 설정
                ),
                Text(
                  '${userRef.tomato}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
