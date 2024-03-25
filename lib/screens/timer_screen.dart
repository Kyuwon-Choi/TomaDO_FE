import 'package:flutter/material.dart';
import 'package:tomado/data/colors.dart';
import 'dart:async';

import 'package:tomado/data/preference_manager.dart';
import 'package:tomado/models/category_model.dart';
import 'package:tomado/services/memo_api_service.dart';
import 'package:tomado/services/task_api_service.dart';

class TimerScreen extends StatefulWidget {
  final int timerDuration;
  final String pomodoroType;
  final String sessionType;
  final String todayTask; // 오늘의 할 일
  final CategoryModel? selectedCategory; // 선택된 카테고리
  final int taskId;

  const TimerScreen({
    Key? key,
    required this.timerDuration,
    required this.pomodoroType,
    required this.sessionType,
    required this.todayTask,
    this.selectedCategory,
    required this.taskId,
  }) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const twentyFiveMinutes = 15;
  static const shortRest = 3;
  static const longRest = 12;
  int totalSeconds = twentyFiveMinutes; //타이머 변수, 메소드
  bool isRunning = false; // 재생중/정지중
  int totalPomodoros = 0;
  Timer? timer;
  String emergencyNote = "";
  int? timerDuration;

  void onTick(Timer timer) {
    if (totalSeconds == 0) {
      setState(() {
        totalPomodoros++;
        //알림창 추가
        isRunning = false;
        totalSeconds = twentyFiveMinutes;
      });
      timer.cancel();
    } else {
      setState(() {
        totalSeconds--;
      });
    }
  }

  void showTomatoEarnedDialog(int toma) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 다이얼로그 바깥을 탭해도 닫히지 않도록 설정
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0), // 다이얼로그 모서리의 둥근 정도
          ),
          elevation: 0,
          backgroundColor: Colors.transparent, // 배경을 투명하게 설정
          child: Stack(
            clipBehavior: Clip.none, // 자식이 부모 밖으로 나와도 보이게 설정
            alignment: Alignment.topCenter, // 자식을 상단 중앙에 정렬
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(
                    20, 70, 20, 20), // 상단에 이미지 공간 확보를 위해 패딩 조정
                margin: const EdgeInsets.only(top: 45), // 이미지와 겹치지 않도록 상단 마진 설정
                decoration: BoxDecoration(
                  color: Colors.white, // 다이얼로그 배경색 하얀색으로 설정
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 10)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 필요한 만큼의 크기만 차지
                  children: <Widget>[
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '$toma 토마',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                        children: const <TextSpan>[
                          TextSpan(
                            text: '가 \n만들어졌어요',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.grey),
                          child: const Text(
                            '그만하기',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                            Navigator.of(context).popUntil(
                                (route) => route.isFirst); // HomeScreen으로 돌아가기
                          },
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).cardColor),
                          child: const Text(
                            '계속하기',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            // 여기에 계속하기 로직 추가
                            Navigator.of(context).pop();
                            onStartPressed();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Positioned(
                top: -20, // 이미지를 다이얼로그 위로 더 올려 이미지가 가려지지 않도록 조정
                child: CircleAvatar(
                  backgroundColor:
                      Colors.transparent, // CircleAvatar 배경을 투명하게 설정
                  radius: 60, // 이미지 크기 조정
                  child: ClipOval(
                    child: Image.asset(
                      'images/popup.jpg', // 이미지 경로를 정확히 설정해야 합니다.
                      fit: BoxFit.cover, // 이미지 비율 유지
                      width: 120, // 이미지 너비
                      height: 120, // 이미지 높이
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void onStartPressed() {
    if (!isRunning) {
      startTimer();
    }
  }

  void startTimer() {
    timer?.cancel(); // 기존 타이머가 있으면 취소
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (totalSeconds > 0) {
          totalSeconds--;
        } else {
          timer.cancel();
          isRunning = false;
          // 이지 모드에서 집중 시간 또는 휴식 시간이 끝났을 경우
          if (widget.pomodoroType != "Hard") {
            if (widget.timerDuration == twentyFiveMinutes) {
              // 집중 시간이 끝난 경우
              showTomatoEarnedDialog(1); // 1토마 적립 알림 표시
            } else {
              // 휴식 시간이 끝난 경우, 바로 HomeScreen으로 이동
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }
          // 하드 모드에서 집중 시간 또는 휴식 시간이 끝났을 경우의 처리는 그대로 유지
          if (widget.pomodoroType == "Hard" && totalPomodoros % 2 == 1) {
            showTomatoEarnedDialog(1); // 집중 시간이 끝나면 3토마 적립 알림 표시
            setHardPomodoroTimer(); // 다음 세션으로 진행
          } else if (widget.pomodoroType == "Hard") {
            setHardPomodoroTimer(); // 다음 세션으로 진행
          }
        }
      });
    });
    setState(() => isRunning = true);
  }

  void addHardToma() async {
    try {
      final userId = await PreferenceManager.getUserId();
      if (userId != null) {
        // 하드 포모도로 모드의 모든 사이클 완료 시 3토마 적립
        await TaskApiService().addHardToma(int.parse(userId), widget.taskId);
        showTomatoEarnedDialog(3);
        print('하드 포모도로 완료! 추가 3토마가 적립되었습니다.');
      } else {
        throw Exception('사용자 ID를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('하드 포모도로 토마 적립 실패: $e');
    }
  }

  void onPausePressed() {
    timer?.cancel(); // timer가 null이 아닐 때만 cancel 호출
    setState(() {
      isRunning = false;
    });
  }

  void onResetPressed() {
    timer?.cancel(); // timer가 null이 아닐 때만 cancel 호출
    setState(() {
      totalPomodoros = 0;
      totalSeconds = twentyFiveMinutes;
      isRunning = false;
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // 화면이 종료될 때 timer를 취소
    super.dispose();
  }

  double getCircularProgressIndicatorValue() {
    return totalSeconds / timerDuration!.toDouble();
  }

  String format(int seconds) {
    var duration = Duration(seconds: seconds);

    return duration.toString().split(".").first.substring(2, 7);
  }

  Future<void> showEmergencyNotePopup() async {
    TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white, // 다이얼로그 배경색을 하얀색으로 설정
          child: Column(
            mainAxisSize: MainAxisSize.min, // 컨텐츠 크기만큼 높이 조정
            children: [
              // AppBar 스타일의 바
              AppBar(
                leading: Container(), // AppBar의 기본 leading을 비활성화
                backgroundColor: Colors.grey, // AppBar 배경색을 하얀색으로 설정
                elevation: 0, // AppBar의 그림자 제거
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black), // X 버튼
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                    },
                  ),
                ],
              ),
              // TextField
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  minLines: 5, // 최소 라인 수
                  maxLines: 15, // 최대 라인 수
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: "긴급 메모 작성...",
                    filled: true, // 배경색을 채우기 위해 필요합니다.
                    fillColor: Colors.white, // TextField의 배경색을 하얀색으로 설정합니다.
                    // 텍스트필드에 경계선 추가
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    String memoContent = controller.text;

    if (memoContent.isNotEmpty) {
      // 메모 내용이 비어 있지 않다면 서버에 메모를 생성합니다.
      try {
        String? userId = await PreferenceManager.getUserId();
        if (userId != null) {
          await MemoApiService().createMemo(int.parse(userId), memoContent);
          print('메모가 성공적으로 생성되었습니다.');
        } else {
          print('사용자 ID를 찾을 수 없습니다.');
        }
      } catch (e) {
        print('메모 생성 중 오류 발생: $e');
      }
    }
  }

  void setHardPomodoroTimer() {
    // 하드 뽀모도로 타이머 설정
    int focusTime = twentyFiveMinutes;
    int shortBreakTime = shortRest;
    int longBreakTime = longRest; // 긴 휴식 시간
    int sets = 3; // 4세트 집중-휴식 반복

    totalPomodoros++;

    if (totalPomodoros <= sets * 2) {
      if (totalPomodoros % 2 == 1) {
        timerDuration = focusTime; // 집중 시간을 설정합니다.
        totalSeconds = focusTime;
      } else {
        timerDuration = shortBreakTime; // 짧은 휴식 시간을 설정합니다.
        totalSeconds = shortBreakTime;
      }
      startTimer();
    } else if (totalPomodoros == sets * 2 + 1) {
      addHardToma();
      timerDuration = longBreakTime; // 긴 휴식 시간을 설정합니다.
      totalSeconds = longBreakTime;
      startTimer();
    } else {
      // 모든 세트 완료 후 타이머 정지
      if (totalPomodoros == 8) {
        setState(() {
          isRunning = false;
          totalPomodoros = 0;
          // 전체 사이클 완료 후 HomeScreen으로 이동합니다.
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    timerDuration = widget.timerDuration;
    if (widget.pomodoroType == "Hard") {
      // 하드 뽀모도로 모드일 경우 고정된 타이머 설정
      setHardPomodoroTimer();
    } else {
      // 이지 뽀모도로 모드에서 전달받은 시간으로 타이머 시작
      totalSeconds = widget.timerDuration;
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Theme.of(context).cardColor], // 원하는 색상으로 조정
      ),
    );

    const double buttonHeight = 48.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: AnimatedContainer(
        duration: const Duration(seconds: 10),
        decoration: isRunning ? null : backgroundDecoration,
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    widget.todayTask,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // 선택된 카테고리 표시
                  if (widget.selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: getButtonColorFromString(
                                widget.selectedCategory!.color)),
                        child: Text(widget.selectedCategory!.title,
                            style: TextStyle(
                                color: getTextColorFromString(
                                    widget.selectedCategory!.color))),
                      ),
                    ),
                ],
              ),
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
                          value: getCircularProgressIndicatorValue(),
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
            const SizedBox(
              height: 50,
            ),
            if (isRunning)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton.icon(
                  icon: Image.asset('images/memo.jpg'),
                  label: const Text(
                    '긴급 메모',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  onPressed: showEmergencyNotePopup,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor:
                        Colors.transparent, // 텍스트 색상을 설정합니다. 원하는 색상으로 변경하세요.
                    shadowColor: Colors.transparent, // 그림자 색상을 투명하게 설정합니다.
                    elevation: 0, // 버튼의 높이(그림자)를 0으로 설정하여 플랫한 디자인을 만듭니다.
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          30), // 원하는 경우 모서리의 둥근 정도를 설정할 수 있습니다.
                      side: const BorderSide(
                          color: Colors.transparent), // 테두리 색상을 투명하게 설정합니다.
                    ),
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  '토마토를 완성하고 싶다면 1분 내로 시작해주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            const SizedBox(
              height: 50,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onResetPressed,
                  iconSize: 40,
                  color: Theme.of(context).textTheme.headlineLarge!.color,
                  icon: const Icon(Icons.restore_rounded),
                ),
                IconButton(
                  iconSize: 120,
                  color: Theme.of(context).textTheme.headlineLarge!.color,
                  onPressed: isRunning ? onPausePressed : onStartPressed,
                  icon: Icon(isRunning
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
