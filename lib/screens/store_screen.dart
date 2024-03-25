import 'package:flutter/material.dart';
import 'package:tomado/models/tomado_model.dart';

import 'package:tomado/services/shop_api_service.dart';
import 'package:tomado/data/preference_manager.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  List<TomadoModel>? haveTomados;
  List<TomadoModel>? notHaveTomados;
  final ShopApiService _shopApiService = ShopApiService();

  @override
  void initState() {
    super.initState();
    _fetchTomatoes();
  }

  // 토마토 세부정보를 표시하는 팝업을 보여주는 함수
  void _showTomatoPopup(TomadoModel tomatoDetail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                children: [
                  Image.network(tomatoDetail.url, height: 150),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Text('${tomatoDetail.tomato}'),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      tomatoDetail.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(tomatoDetail.content),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final String? userId =
                              await PreferenceManager.getUserId();
                          if (userId != null) {
                            // tomatoDetail.tomatoModel.id는 토마토 ID를 가정합니다. 실제 모델에 맞게 조정해야 합니다.
                            await _shopApiService.buyTomato(
                                int.parse(userId), tomatoDetail.tomadoId);

                            Navigator.of(context).pop(); // 팝업을 닫습니다.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('${tomatoDetail.name} 구매 성공!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('유저 ID를 찾을 수 없습니다.')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40), // 버튼 크기
                      ),
                      child: const Text('구매하기'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _fetchTomatoes() async {
    final String? userId = await PreferenceManager.getUserId();
    if (userId != null) {
      final results = await _shopApiService.fetchTomatoData(int.parse(userId));
      setState(() {
        haveTomados = results['have'];
        notHaveTomados = results['notHave'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유저 ID를 찾을 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '토마 상점',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: haveTomados == null || notHaveTomados == null
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: haveTomados!.length + notHaveTomados!.length,
              itemBuilder: (context, index) {
                // 여기서 구매 가능 여부를 확인합니다.
                final isHave = index < haveTomados!.length;
                final detail = isHave
                    ? haveTomados![index]
                    : notHaveTomados![index - haveTomados!.length];

                return GestureDetector(
                  onTap: !isHave
                      ? () => _showTomatoPopup(detail)
                      : null, // 수정: 구매 불가능한 항목이 클릭되지 않도록 변경
                  child: Opacity(
                    opacity: !isHave
                        ? 1.0
                        : 0.5, // 수정: 구매 가능한 항목은 불투명, 구매 불가능한 항목은 반투명으로 표시
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.network(detail.url, height: 100), // 이미지 표시
                        Text(detail.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        // 구매 가능 여부에 따라 다른 텍스트 표시
                        Text(
                            isHave
                                ? '구매불가'
                                : '${detail.tomato} 토마코인', // 수정: 구매 불가능한 항목에는 '구매불가' 표시
                            style: TextStyle(
                              color: isHave
                                  ? Colors.black
                                  : Colors.red, // 구매 불가능한 항목의 텍스트는 빨간색으로 표시
                            )),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
