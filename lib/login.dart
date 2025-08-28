import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'api_client.dart';
import 'auth_storage.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  Future<void> _requestDevToken() async {
    final dio = ApiClient.instance.dio;

    final res = await dio.post(
      'test',
      queryParameters: {'userId': 1, 'username': 'user1', 'role': 'TEACHER'},
    );

    final token = res.headers.value('Authorization'); 
    if (token == null || token.isEmpty) {
      debugPrint('⚠️ 토큰 없음');
      return;
    }

    await AuthStorage.instance.saveAccessToken(token);
    debugPrint('token: $token');

    final realSavedToken =
        await AuthStorage.instance.readAccessToken(); 
    debugPrint('realSavedToken: $realSavedToken');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width * 0.045),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/clueLogo.svg',
                width: width * 0.4,
              ),
              SizedBox(height: height * 0.056),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _requestDevToken,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.028,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffF3F3F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/800px-Google_%22G%22_logo.svg.png',
                        width: width * 0.07,
                      ),
                      SizedBox(width: width * 0.045),
                      Text(
                        'google 계정으로 로그인하기',
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: const Color(0xff111111),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.15),
            ],
          ),
        ),
      ),
    );
  }
}
