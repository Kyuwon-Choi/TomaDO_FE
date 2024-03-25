import 'package:flutter/material.dart';
import 'package:tomado/data/preference_manager.dart';
import 'package:tomado/models/club_model.dart';
import 'package:tomado/screens/friend_add_screen.dart';
import 'package:tomado/services/club_api_service.dart';

class ClubScreen extends StatefulWidget {
  const ClubScreen({Key? key}) : super(key: key);

  @override
  _ClubScreenState createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen>
    with SingleTickerProviderStateMixin {
  final ClubApiService _apiService = ClubApiService();
  final PageController _pageController =
      PageController(viewportFraction: 0.85); // 페이지 뷰의 viewport 비율 설정

  Future<int?> _fetchUserId() async {
    final userIdString = await PreferenceManager.getUserId();
    return userIdString != null ? int.tryParse(userIdString) : null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '토마클럽',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FriendAddScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // 버튼의 높이를 50으로 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // 버튼의 모서리를 둥글게 설정
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20), // 좌우 패딩 추가
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min, // 버튼 내부 컨텐츠의 너비에 맞춤
                children: [
                  Text(
                    '토마클럽 만들기',
                    style: TextStyle(color: Colors.black),
                  ), // 버튼의 텍스트
                  SizedBox(width: 230), // 텍스트와 아이콘 사이 간격
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                  ), // 오른쪽 화살표 아이콘
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<int?>(
              future: _fetchUserId(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('사용자 ID를 불러올 수 없습니다.');
                } else {
                  final userId = snapshot.data!;
                  return FutureBuilder<List<ClubModel>>(
                    future: _apiService.fetchClubList(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        List<ClubModel> ongoingClubs = snapshot.data!
                            .where((club) => !club.completed)
                            .toList();
                        List<ClubModel> completedClubs = snapshot.data!
                            .where((club) => club.completed)
                            .toList();

                        return Column(
                          children: [
                            const Text(
                              '진행중인 토마클럽',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: ongoingClubs.length,
                                itemBuilder: (context, index) {
                                  return ClubCard(club: ongoingClubs[index]);
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Text(
                              '완료한 토마클럽',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: completedClubs.length,
                                itemBuilder: (context, index) {
                                  return ClubCard(club: completedClubs[index]);
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Text('데이터가 없습니다.');
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ClubCard extends StatelessWidget {
  final ClubModel club;

  const ClubCard({Key? key, required this.club}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 이곳에 카드 디자인을 구현합니다. 예시는 아래와 같습니다.
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Container(
        width:
            MediaQuery.of(context).size.width * 0.6, // 카드의 너비를 화면의 60%로 설정합니다.
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              club.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // 기간, 멤버 수, 메모, 진행 상황 등의 세부 정보를 표시하는 위젯들을 추가합니다.
            const SizedBox(height: 4),
            Text(
              '${club.startDate} - ${club.endDate}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 80, // 캐릭터 이미지의 높이 설정

              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: club.memberList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      club.memberList[index].url, // 멤버 캐릭터 URL
                      fit: BoxFit.cover,
                      // 이미지 비율을 유지하면서 영역을 채웁니다.
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Text(
              club.memo,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: club.currentAmount / club.goal,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).cardColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
