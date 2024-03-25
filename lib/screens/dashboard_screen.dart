import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tomado/data/preference_manager.dart';
import 'package:tomado/models/task_model.dart';
import 'package:tomado/services/task_api_service.dart';
import 'package:tomado/widgets/personal_pomodoro_widget.dart';
import 'package:tomado/widgets/team_pomodoro_widget.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // 가상의 데이터로, 실제로는 서버로부터 받아와야 합니다.
  final Map<DateTime, int> tomaCountMap = {};

  @override
  void initState() {
    super.initState();
    _fetchMonthData(); // 앱 시작 시 월별 데이터 불러오기
  }

  Color getDayColor(int tomaCount) {
    if (tomaCount <= 3) {
      return const Color(0xfff2f3f5);
    } else if (tomaCount <= 7) {
      return const Color(0xffffc3aa); // 엷은 주황색
    } else if (tomaCount <= 11) {
      return const Color(0xffff8473);
    } else {
      return const Color(0xffff452c);
    }
  }

  Future<void> _fetchMonthData() async {
    try {
      final userId = await PreferenceManager.getUserId();
      if (userId != null) {
        List<TaskModel> monthDataList = await TaskApiService()
            .fetchMonth(int.parse(userId), (DateTime.now().month));
        setState(() {
          tomaCountMap.clear(); // 기존 데이터 클리어
          for (TaskModel taskModel in monthDataList) {
            // date를 DateTime 타입으로 변환하여 tomaCountMap에 추가
            DateTime dateOnly = DateTime(
                taskModel.date.year, taskModel.date.month, taskModel.date.day);
            tomaCountMap[dateOnly] = taskModel.tomaCount;
            print('월별 데이터 로딩 완료: $tomaCountMap');
          }
        });
      } else {
        print('사용자 ID를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('월별 데이터 불러오기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Text(
              '월간 토마',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Card(
              margin: const EdgeInsets.all(30),
              color: const Color(0xfff2f3f5),
              child: TableCalendar(
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronPadding: EdgeInsets.only(left: 100),
                  rightChevronPadding: EdgeInsets.only(right: 100),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final tomaCount =
                        tomaCountMap[DateTime(day.year, day.month, day.day)] ??
                            0;

                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: getDayColor(tomaCount),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.day.toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  },
                  todayBuilder: (context, day, focusedDay) {
                    // 오늘 날짜에 대한 처리를 defaultBuilder와 동일하게 설정
                    final tomaCount =
                        tomaCountMap[DateTime(day.year, day.month, day.day)] ??
                            0;
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: getDayColor(tomaCount),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.day.toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    // 선택된 날짜에 대한 처리를 defaultBuilder와 동일하게 설정
                    final tomaCount =
                        tomaCountMap[DateTime(day.year, day.month, day.day)] ??
                            0;
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: getDayColor(tomaCount),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        day.day.toString(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  },
                ),
                calendarStyle: const CalendarStyle(
                    // todayDecoration: BoxDecoration(
                    //   color: Colors.transparent, // 배경을 투명하게 설정
                    //   shape: BoxShape.circle,
                    // ),
                    // selectedDecoration: BoxDecoration(
                    //   color: Colors.transparent,
                    // ),
                    defaultTextStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    weekendTextStyle: TextStyle(color: Colors.grey),
                    outsideDaysVisible: false,
                    todayTextStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                locale: 'ko_KR',
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2024, 4, 30),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    // Call `setState()` when updating the selected day
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay =
                          focusedDay; // update `_focusedDay` here as well
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  // No need to call `setState()` here
                  _focusedDay = focusedDay;
                },
              ),
            ),
            const Text(
              '토마 카테고리',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 300, // 적절한 높이를 설정하세요
              child: PageView(
                children: const <Widget>[
                  PersonalPomodoroGrid(), // 개인 뽀모도로 카테고리 그리드
                  TeamPomodoroGrid(), // 팀 뽀모도로 카테고리 그리드
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
