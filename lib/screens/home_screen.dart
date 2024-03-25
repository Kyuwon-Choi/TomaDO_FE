import 'package:flutter/material.dart';
import 'package:tomado/data/preference_manager.dart';
import 'package:tomado/models/category_model.dart';
import 'package:tomado/screens/timer_screen.dart';
import 'package:tomado/services/category_api_service.dart';
import 'package:tomado/services/club_api_service.dart';
import 'package:tomado/services/task_api_service.dart';
import 'dart:async';

import 'package:tomado/widgets/drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const twentyFiveMinutes = 15;
  static const shortRest = 3;
  static const longRest = 12;
  int totalSeconds = twentyFiveMinutes; //타이머 변수, 메소드
  bool switchValue = false; //false - 이지 true - 하드
  int totalPomodoros = 0;
  String? _selectedItem = '25m'; //이지뽀모도로일 때 선택한 메뉴
  String todayTask = '';
  TextEditingController todayTaskController =
      TextEditingController(text: '오늘 할 일');
  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _fetchCategories() async {
    try {
      // SharedPreferences에서 유저 ID를 비동기적으로 가져옵니다.
      final String? userId = await PreferenceManager.getUserId();
      if (userId != null) {
        // 유저 ID를 사용하여 카테고리 목록을 조회합니다.
        List<CategoryModel> categoryList1 =
            await CategoryApiService().getClubCategories(int.parse(userId));
        List<CategoryModel> categoryList2 =
            await CategoryApiService().getCategories(int.parse(userId));
        // 상태를 업데이트합니다.
        setState(() {
          categories = categoryList1;
          categories.addAll(categoryList2);
        });
      } else {
        // 유저 ID가 null일 경우, 에러 처리를 합니다.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('유저 ID를 찾을 수 없습니다.'),
          ),
        );
      }
    } catch (e) {
      // 오류 처리를 수행합니다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카테고리를 불러오는 데 실패했습니다: $e'),
        ),
      );
    }
  }

  void onStartPressed() async {
    final String? userId = await PreferenceManager.getUserId();
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카테고리를 선택해주세요.')),
      );
      return;
    }

    int taskId;
    try {
      taskId = await TaskApiService().createTask(
          int.parse(userId!), selectedCategory!.categoryId, todayTask);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task 생성에 실패했습니다: $e')),
      );
      return;
    }

    // 이지 뽀모도로 모드에서만 시간 선택 적용
    //taskId 넘기기

    final duration = switchValue ? 0 : getTimerDuration();

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => TimerScreen(
        timerDuration: duration,
        pomodoroType: switchValue ? "Hard" : "Easy",
        sessionType: switchValue
            ? "Hard"
            : (_selectedItem == "25m"
                ? "Focus"
                : (_selectedItem == "5m" ? "Short Break" : "Long Break")),
        todayTask: todayTask,
        selectedCategory: selectedCategory,
        taskId: taskId,
      ),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ));
  }

  void onDropdownItemSelected(String? value) {
    setState(() {
      _selectedItem = value;
      // 타이머 시간을 업데이트합니다.
      totalSeconds = getTimerDuration();
    });
  }

  int getTimerDuration() {
    switch (_selectedItem) {
      case "25m":
        return twentyFiveMinutes;
      case "5m":
        return shortRest;
      case "20m":
        return longRest;
      default:
        return twentyFiveMinutes;
    }
  }

  String format(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    // 초기 상태에서 '오늘 할 일'을 TextEditingController에 설정합니다.
    todayTaskController =
        TextEditingController(text: todayTask.isEmpty ? '오늘 할 일' : todayTask);
  }

  @override
  void dispose() {
    // 화면이 종료될 때 TextEditingController를 정리합니다.
    todayTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // GestureDetector를 사용하여 화면의 어느 곳이든 탭할 때 키보드를 숨깁니다.
        FocusScope.of(context).requestFocus(FocusNode());
        // 텍스트 필드 외부를 탭했을 때의 동작을 여기에 추가할 수 있습니다.
        // 예를 들어, '오늘 할 일' 텍스트 필드의 현재 값을 저장합니다.
        setState(() {
          todayTask = todayTaskController.text;
        });
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ],
        ),
        endDrawer: const DrawerWidget(),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: todayTaskController,
                    textAlign: TextAlign.center, // 텍스트를 가운데 정렬합니다.
                    decoration: const InputDecoration(
                      hintText: '오늘 할 일', // 사용자가 입력할 내용의 예시를 보여주는 힌트 텍스트입니다.
                      // 텍스트 필드 주위에 표준 경계를 추가합니다.
                    ),
                    style: const TextStyle(
                      fontSize: 24, // 텍스트의 크기를 설정합니다.
                      fontWeight: FontWeight.bold, // 텍스트의 굵기를 설정합니다.
                    ),
                    onTap: () {
                      // 텍스트 필드를 탭했을 때 기본 텍스트를 삭제합니다.
                      if (todayTaskController.text == '오늘 할 일') {
                        todayTaskController.clear();
                      }
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showCategoryBottomSheet(); // 카테고리를 표시하는 하단 바를 보여주는 메소드 호출
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      _getButtonColorFromString(
                          selectedCategory?.color ?? "GRAY"),
                    ), // 버튼의 배경색 설정
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20), // 모서리의 둥글기 정도를 20으로 설정
                      ),
                    ),
                  ),
                  child: Text(
                    selectedCategory?.title ??
                        '카테고리', // 선택된 카테고리가 없으면 기본 텍스트를 표시합니다.
                    style: TextStyle(
                      color: _getTextColorFromString(
                          selectedCategory?.color ?? "GRAY"),
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              flex: 3,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                        width: 300,
                        height: 300,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 10,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.grey),
                          backgroundColor: Theme.of(context).cardColor,
                        )),
                    Text(
                      format(totalSeconds),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.headlineLarge!.color,
                        fontSize: 80,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Switch(
                        value: switchValue,
                        onChanged: (value) {
                          setState(() {
                            switchValue = value;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.background,
                        activeTrackColor: Theme.of(context).cardColor,
                        inactiveTrackColor: Colors.grey,
                      ),
                      Text(
                        switchValue ? 'hard pomodoro' : 'easy pomodoro',
                        style: TextStyle(
                          // 스위치가 ON일 때는 cardColor, OFF일 때는 기본 텍스트 색상을 사용
                          color: switchValue
                              ? Theme.of(context).cardColor
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  // 스위치가 OFF일 때 (easy pomodoro 상태) 드롭다운 메뉴를 표시
                  if (!switchValue) ...[
                    DropdownButton<String>(
                      value: _selectedItem,
                      dropdownColor: Colors.white, // 드롭다운 메뉴의 배경색 설정
                      items: const [
                        DropdownMenuItem(value: "25m", child: Text("뽀모도로 25m")),
                        DropdownMenuItem(value: "5m", child: Text("짧은 휴식 5m")),
                        DropdownMenuItem(value: "20m", child: Text("긴 휴식 20m")),
                      ],
                      onChanged: onDropdownItemSelected,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(
              height: 120,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  iconSize: 120,
                  color: Theme.of(context).textTheme.headlineLarge!.color,
                  onPressed: onStartPressed, // 항상 onStartPressed 메서드를 호출
                  icon: const Icon(Icons.play_circle_fill),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTextColorFromString(String colorString) {
    switch (colorString) {
      case 'RED':
        return const Color(0xfffd6b56);
      case 'YELLOW':
        return const Color(0xffffa800);
      case 'GREEN':
        return const Color(0xff57b060);
      case 'BLUE':
        return const Color(0xff5c739c);
      case 'GRAY':
      default:
        return const Color(0xff84888F); // 기본값으로 회색을 사용
    }
  }

  Color _getButtonColorFromString(String colorString) {
    switch (colorString) {
      case 'RED':
        return const Color(0xffffe4d9);
      case 'YELLOW':
        return const Color(0xfffff2b1);
      case 'GREEN':
        return const Color(0xffd9fcd1);
      case 'BLUE':
        return const Color(0xffe5f7ff);
      case 'GRAY':
      default:
        return const Color(0xfff2f3f5); // 기본값으로 회색을 사용
    }
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 필요한 만큼의 높이만 사용
            children: [
              const SizedBox(height: 16.0),
              Row(
                // mainAxisAlignment:
                //     MainAxisAlignment.spaceBetween, // 요소들을 양끝으로 배치
                children: [
                  const SizedBox(
                    width: 140,
                  ),
                  const Text(
                    '토마 카테고리',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 70,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit), // 수정 아이콘
                    onPressed: () {
                      // 수정 아이콘 눌렀을 때의 동작 구현
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              GridView.builder(
                shrinkWrap: true, // Column 안에서 GridView 사용 시 필요
                physics: const NeverScrollableScrollPhysics(), // 스크롤 안되게 설정
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 두 개의 아이템을 가로로 배열
                  crossAxisSpacing: 16.0, // 가로 아이템 사이의 공간 설정
                  mainAxisSpacing: 16.0, // 세로 아이템 사이의 공간 설정
                  childAspectRatio: 3, // 아이템의 가로세로 비율 설정
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  var category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                      Navigator.pop(context); // 하단 바를 닫음
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getButtonColorFromString(category.color),
                        borderRadius: BorderRadius.circular(20), // 모서리 둥글게 설정
                      ),
                      child: Center(
                        child: Text(
                          category.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _getTextColorFromString(category.color),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
