// import 'package:flutter/material.dart';

// class CategoryTile extends StatelessWidget {
//   final String title;
//   final int? count; // Nullable 타입으로 변경
//   final Color color;
//   final Color textColor;

//   const CategoryTile({
//     Key? key,
//     required this.title,
//     this.count, // Nullable 타입으로 변경
//     required this.color,
//     required this.textColor,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 40,
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: textColor,
//             ),
//           ),
//           // count가 null이 아닐 때만 Text 위젯을 표시
//           if (count != null) ...[
//             const SizedBox(height: 8),
//             Text(
//               '$count',
//               style: TextStyle(
//                 fontSize: 32,
//                 color: textColor,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String title;
  final int? count; // Nullable 타입으로 변경
  final Color color;
  final Color textColor;

  const CategoryTile({
    Key? key,
    required this.title,
    this.count, // Nullable 타입으로 변경
    required this.color,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // 높이 조정
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 패딩 조정
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
          // count가 null이 아닐 때만 숫자를 표시
          if (count != null)
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 30, // 크기 조정
                    color: textColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
