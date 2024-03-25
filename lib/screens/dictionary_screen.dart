// import 'package:flutter/material.dart';
// import 'package:tomado/models/tomado_model.dart';

// import 'package:tomado/services/tomado_api_service.dart';

// import 'package:tomado/data/preference_manager.dart';

// class DictionaryScreen extends StatefulWidget {
//   const DictionaryScreen({Key? key}) : super(key: key);

//   @override
//   _DictionaryScreenState createState() => _DictionaryScreenState();
// }

// class _DictionaryScreenState extends State<DictionaryScreen> {
//   final TomatoApiService _apiService = TomatoApiService();

//   Future<List<TomatoModel>> _fetchMyTomatoes() async {
//     final userId = await PreferenceManager.getUserId();
//     if (userId == null) {
//       // userId가 null인 경우의 처리 로직
//       throw Exception('사용자 ID를 찾을 수 없습니다.');
//     }
// // 이후 로직에서는 userId가 null이 아님을 보장할 수 있습니다.
//     return await _apiService.fetchTomatoModels(int.parse(userId));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('토마 도감'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             Text('나의 토마두', style: Theme.of(context).textTheme.titleLarge),
//             FutureBuilder<List<TomatoModel>>(
//               future: _fetchMyTomatoes(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Text('에러가 발생했습니다: ${snapshot.error}');
//                 } else if (snapshot.hasData) {
//                   final myTomados = snapshot.data!;
//                   return GridView.builder(
//                     physics: const NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3,
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                       childAspectRatio: 0.8,
//                     ),
//                     itemCount: myTomados.length,
//                     itemBuilder: (context, index) {
//                       final tomato = myTomados[index];
//                       return Card(
//                         margin: const EdgeInsets.all(8),
//                         child: Center(child: Text(tomato.name)),
//                       );
//                     },
//                   );
//                 } else {
//                   return const Text('데이터가 없습니다.');
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:tomado/models/tomado_model.dart';
import 'package:tomado/services/tomado_api_service.dart';
import 'package:tomado/data/preference_manager.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TomatoApiService _apiService = TomatoApiService();

  Future<List<TomatoModel>> _fetchMyTomatoes() async {
    final userId = await PreferenceManager.getUserId();
    if (userId == null) {
      throw Exception('사용자 ID를 찾을 수 없습니다.');
    }
    return await _apiService.fetchTomatoModels(int.parse(userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '토마 도감',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('나의 토마두',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            FutureBuilder<List<TomatoModel>>(
              future: _fetchMyTomatoes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('에러가 발생했습니다: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final myTomatoes = snapshot.data!;
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: myTomatoes.length,
                    itemBuilder: (context, index) {
                      final tomato = myTomatoes[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child:
                                  Image.network(tomato.url, fit: BoxFit.cover),
                            ),
                            Text(tomato.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Text('데이터가 없습니다.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
