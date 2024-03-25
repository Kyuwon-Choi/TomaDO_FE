// colors.dart 파일
import 'package:flutter/material.dart';

Color getTextColorFromString(String colorString) {
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

Color getButtonColorFromString(String colorString) {
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

String colortoString(Color color) {
  if (color == const Color(0xffffe4d9)) {
    return 'RED';
  } else if (color == const Color(0xfffff2b1)) {
    return 'YELLOW';
  } else if (color == const Color(0xffd9fcd1)) {
    return 'GREEN';
  } else if (color == const Color(0xffe5f7ff)) {
    return 'BLUE';
  } else {
    return 'GRAY'; // 기본값으로 회색을 사용
  }
}
