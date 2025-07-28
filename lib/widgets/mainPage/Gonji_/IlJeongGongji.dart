import 'package:flutter/material.dart';
import 'package:clue/config/app_data_.dart';

class Iljeonggongji extends StatelessWidget {
  const Iljeonggongji({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final noticeList = AppData.getIljeongNoticeList();
    
    // 반응형 폰트 크기 계산
    final titleFontSize = (width * 0.05).clamp(8.0, 16.0); // 최소 16, 최대 28
    final contentFontSize = (width * 0.032).clamp(6.0, 12.0);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   color: Colors.white,
      //   boxShadow: const [
      //     BoxShadow(
      //       color: Colors.black12,
      //       blurRadius: 10,
      //       offset: Offset(0, 4),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '일정안내',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: titleFontSize),
          ),
          const SizedBox(height: 10),

          ...noticeList.map(
            (notice) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(notice['title']!, style: TextStyle(fontSize: contentFontSize)),
                  Text(notice['date']!, style: TextStyle(fontSize: contentFontSize)),
                ],
              ),
            ),
          ),
          SizedBox(height:10),
           const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              
              Image.asset('assets/images/jagunbar.png'),
              SizedBox(width:7),
              Image.asset('assets/images/jagunbar.png'),
              SizedBox(width:7),
              Image.asset('assets/images/ginbar.png'),
              
            ],
          ),
        ],
      ),
    );
  }
}
