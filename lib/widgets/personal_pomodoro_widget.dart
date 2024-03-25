import 'package:flutter/foundation.dart';
import 'package:tomado/data/colors.dart';
import 'package:tomado/data/preference_manager.dart';
import 'package:tomado/models/category_model.dart';
import 'package:tomado/services/category_api_service.dart';
import 'package:tomado/widgets/category_tile_widget.dart';

import 'package:flutter/material.dart';

class PersonalPomodoroGrid extends StatefulWidget {
  const PersonalPomodoroGrid({Key? key}) : super(key: key);

  @override
  State<PersonalPomodoroGrid> createState() => _PersonalPomodoroGridState();
}

class _PersonalPomodoroGridState extends State<PersonalPomodoroGrid> {
  List<CategoryModel> categories = []; // 서버로부터 가져온 카테고리 목록을 저장합니다.
  final CategoryApiService _apiService =
      CategoryApiService(); // API 서비스 인스턴스를 생성합니다.

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // 앱이 시작될 때 카테고리 데이터를 조회합니다.
  }

  Future<void> _fetchCategories() async {
    try {
      // SharedPreferences에서 유저 ID를 비동기적으로 가져옵니다.
      final String? userId = await PreferenceManager.getUserId();
      if (userId != null) {
        // 유저 ID를 사용하여 카테고리 목록을 조회합니다.
        List<CategoryModel> categoryList =
            await _apiService.getCategories(int.parse(userId));
        // 상태를 업데이트합니다.
        setState(() {
          categories = categoryList;
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

  Color? selectedColor; // 선택된 색상을 저장하는 변수
  String? selectedTitle;
  final TextEditingController _textEditingController = TextEditingController();
  // 새 카테고리를 추가하는 하단 시트를 보여주는 함수
  void _showCategoryBottomSheet(BuildContext context,
      {CategoryModel? category}) {
    // 만약 기존 카테고리 정보가 있으면, 해당 정보로 초기화합니다.
    if (category != null) {
      selectedTitle = category.title;
      selectedColor =
          getButtonColorFromString(category.color); // String을 Color로 변환
      _textEditingController.text = category.title;
    } else {
      selectedTitle = null;
      selectedColor = Colors.grey; // 기본 색상
      _textEditingController.clear();
    }
    showModalBottomSheet(
      context: context,
      barrierColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          color: selectedColor ?? Colors.white,
          child: Wrap(
            children: <Widget>[
              TextField(
                controller: _textEditingController,
                maxLength: 8,
                decoration: const InputDecoration(
                  hintText: '제목',
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['RED', 'YELLOW', 'GREEN', 'BLUE'].map((colorString) {
                  return ColorButton(
                    color: getButtonColorFromString(colorString),
                    onTap: () {
                      _changeBottomSheetColor(
                          getButtonColorFromString(colorString));
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    ).then((_) async {
      // 선택된 색상과 제목을 처리합니다.
      if (selectedColor != null && _textEditingController.text.isNotEmpty) {
        print('Color: ${selectedColor!}');
        print('Title: ${_textEditingController.text}');
        final String title = _textEditingController.text;
        final String color = colortoString(selectedColor!);

        // 서버에 카테고리 추가 요청을 보내는 로직을 여기에 추가합니다.
        final String? userId = await PreferenceManager.getUserId();
        if (category == null) {
          // 새 카테고리 생성 로직
          print(color);
          await _apiService.createCategory(int.parse(userId!), title, color);
          await _fetchCategories();
        } else {
          print(category.categoryId);
          // 카테고리 수정 로직
          await _apiService.updateCategory(
              category.categoryId, int.parse(userId!), title, color);
          await _fetchCategories();
        }
      }
    });
  }

  // 하단 시트의 색상을 변경하는 함수
  void _changeBottomSheetColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10, // 가로 방향 항목 사이의 간격
        mainAxisSpacing: 10, // 세로 방향 항목 사이의 간격
        childAspectRatio: 1.5, // 항목의 가로 세로 비율을 1:1.5로 설정
      ),
      itemCount: categories.length + 1, // 카테고리 목록 수 + 추가 버튼
      itemBuilder: (BuildContext context, int index) {
        if (index == categories.length) {
          // '+' 버튼을 생성합니다.
          return GestureDetector(
            onTap: () => _showCategoryBottomSheet(context),
            child: const CategoryTile(
              title: '+',
              color: Colors.grey,
              textColor: Colors.black,
            ),
          );
        } else {
          // 각 카테고리 타일을 생성합니다.
          return GestureDetector(
            onTap: () =>
                _showCategoryBottomSheet(context, category: categories[index]),
            child: CategoryTile(
              title: categories[index].title,
              count: categories[index].tomato, // 'tomato'를 카운트로 사용합니다.
              color: getButtonColorFromString(
                  categories[index].color), // 가정한 프로퍼티 사용
              textColor: getTextColorFromString(categories[index].color),
            ),
          );
        }
      },
    );
  }
}

class ColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const ColorButton({Key? key, required this.color, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: color,
        radius: 25,
      ),
    );
  }
}
