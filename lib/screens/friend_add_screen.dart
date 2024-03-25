import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomado/services/club_api_service.dart'; // ClubApiService의 경로를 확인하고 수정하세요.

class FriendAddScreen extends StatefulWidget {
  const FriendAddScreen({Key? key}) : super(key: key);

  @override
  _FriendAddScreenState createState() => _FriendAddScreenState();
}

class _FriendAddScreenState extends State<FriendAddScreen> {
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _clubMemoController = TextEditingController();
  final TextEditingController _goalTomatoesController = TextEditingController();
  DateTimeRange? _dateRange;
  int _selectedMembers = 2;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final List<int> _memberOptions = [2, 3, 4];
  final ClubApiService _apiService = ClubApiService(); // API 서비스 인스턴스 생성

  @override
  void dispose() {
    _clubNameController.dispose();
    _clubMemoController.dispose();
    _goalTomatoesController.dispose();
    super.dispose();
  }

  Future<void> _createClub() async {
    final userIdString = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString('userId'));
    final int? userId =
        userIdString != null ? int.tryParse(userIdString) : null;

    if (userId == null) {
      // userId가 없는 경우, 예외 처리
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 ID를 불러오는데 실패했습니다')),
      );
      return;
    }

    try {
      await _apiService.createClub(
        userId: userId,
        title: _clubNameController.text,
        color: 'RED', // 색상 기본값 설정
        memberNumber: _selectedMembers,
        goal: int.parse(_goalTomatoesController.text),
        memo: _clubMemoController.text,
        startDate: _dateFormat.format(_dateRange!.start),
        endDate: _dateFormat.format(_dateRange!.end),
      );

      // 성공적으로 생성 후, 클럽 목록 화면 등으로 네비게이션 할 수 있습니다.
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('클럽 생성 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('토마 클럽'),
        actions: [
          TextButton(
            onPressed: _createClub,
            child: const Text('저장', style: TextStyle(color: Colors.black)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _clubNameController,
              decoration: const InputDecoration(
                labelText: '클럽 이름',
              ),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              title: Text(
                _dateRange == null
                    ? '기간 선택'
                    : '${_dateFormat.format(_dateRange!.start)} - ${_dateFormat.format(_dateRange!.end)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 5),
                );
                if (picked != null && picked != _dateRange) {
                  setState(() {
                    _dateRange = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: '클럽 인원',
                    ),
                    value: _selectedMembers,
                    items: _memberOptions
                        .map((number) => DropdownMenuItem(
                            value: number, child: Text('$number명')))
                        .toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedMembers = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: _goalTomatoesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '목표 토마량',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _clubMemoController,
              decoration: const InputDecoration(
                labelText: '클럽 메모',
              ),
              maxLength: 20,
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () {
                // 클럽 탈퇴 로직을 여기에 추가합니다.
              },
              child: const Text('클럽 탈퇴하기', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
