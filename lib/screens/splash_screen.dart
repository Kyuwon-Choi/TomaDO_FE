import 'package:flutter/material.dart';
import 'package:tomado/screens/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 페이지가 렌더링된 후에 한 번 호출되도록 함
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 3));
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Center 위젯을 사용하여 이미지를 중앙에 배치
        child: Image.asset(
          'images/tomadoIcon.png',
          height: 200,
          width: 200,
        ),
      ),
    );
  }
}
