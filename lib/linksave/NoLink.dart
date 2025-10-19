import 'package:flutter/material.dart';

class Nolink extends StatelessWidget {
  const Nolink({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width * 0.25,
            height: width * 0.25,
            decoration: BoxDecoration(
              color: const Color(0xffB7DAFF),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.open_in_new,
              color: const Color(0xff0077FF),
              size: width * 0.13,
            ),
          ),
          SizedBox(height: height * 0.03),
          Text(
            '현재 존재하는 링크가 없습니다.',
            style: TextStyle(
              fontSize: width * 0.055,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: height * 0.004),
          Text(
            '새로운 링크를 추가해 보세요.',
            style: TextStyle(
              fontSize: width * 0.045,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
