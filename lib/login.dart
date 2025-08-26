import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    void request() async {
      final Dio dio=Dio();
      try {
        var response = await dio.get('');
        print(response.data);
      } catch (e) {
        print('Error: $e');
      }
    }
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
                onTap: () => {
                  
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.05,
                    vertical: height * 0.028,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffF3F3F3),
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
                      Text('google 계정으로 로그인하기', style: TextStyle(fontSize: width*0.04, color: Color(0xff111111))),
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
