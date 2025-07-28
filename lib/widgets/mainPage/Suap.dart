import 'package:clue/config/app_color.dart';
import 'package:clue/config/app_text_styles.dart';
import 'package:flutter/material.dart';

class Suap extends StatelessWidget {
  final String title;
  final String neyong;
  final String url;
  const Suap({
    super.key,
    required this.title,
    required this.neyong,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    // 반응형 크기 계산
    final cardWidth = width * 0.85; // 화면 너비의 85%
    final imageHeight = height * 0.12; // 화면 높이의 12%
    final cardPadding = width * 0.05;
    final fontSize = width * 0.045;
    final borderRadius = width * 0.03;
    final shadowBlur = width * 0.025;
    final shadowOffset = width * 0.01;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.symmetric(vertical: height * 0.006),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: shadowBlur,
            offset: Offset(0, shadowOffset),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: imageHeight,
            child: Center(
              child: SizedBox(
                width: imageHeight * (width < 400 ? 0.7 : 0.8), // 작은 화면에서는 더 작게
                height: imageHeight * (width < 400 ? 0.7 : 0.8),
                child: Image.network(
                  url,
                  fit: BoxFit.contain, // 이미지가 컨테이너 안에 온전히 들어가도록
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.02),

          Container(
            padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: height * 0.012),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
              color: Color(0xffF3F3F3),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
                  ),
                ),

                SizedBox(height: height * 0.001),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    neyong,
                    style: TextStyle(fontSize: fontSize * 0.9, color: Colors.grey[600])
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
