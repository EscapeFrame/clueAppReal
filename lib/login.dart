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
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/clueLogo.svg',
                width: width * 0.3,
              ),
              SizedBox(height: height * 0.08),
              GestureDetector(
                onTap: () => {
                  
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffF3F3F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/googleicon.svg',
                        width: width * 0.06,
                      ),
                      // SizedBox(width: width * 0.01),
                      Text('google 계정으로 로그인하기', style: TextStyle(fontSize: width*0.035, color: Color(0xff111111))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
