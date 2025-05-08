import 'package:flutter/material.dart';

class Haksubsil extends StatelessWidget {
  const Haksubsil({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/logo.png'),
                      Image.asset('assets/images/jongn.png'),
                    ],
                  ),
                  SizedBox(
                    height:15,
                  ),
                  Text(
                    '나의 학습실',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height:4
                  ),
                  Text('학습실을 확인하고 관리해주세요!',style: TextStyle(fontSize: 17),),
                ],
              ),
            ),

        ],
      ),
    );
  }
}