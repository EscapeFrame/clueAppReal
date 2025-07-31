import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Education extends StatelessWidget {
  const Education({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xffffffff),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.06,
                vertical: height * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/images/clueLogo.svg',
                        width: width * 0.25,
                      ),
                      Container(
                        margin: EdgeInsets.only(right: width * 0.035),
                        child: SvgPicture.asset(
                          'assets/images/jong.svg',
                          width: width * 0.055,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.05),
                  Text(
                    '수강신청',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: width * 0.045,
                    ),
                  ),
                  SizedBox(height: height * 0.007),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffE4F1FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info,
                          size: width * 0.07,
                          color: Color(0xFF5197D5),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '아래 표에서 원하는 요일과 시간대의 활동을 클릭하여 선택하세요. 각 요일과 시간대별로 하나의 활동만 선택할 수 있습니다. 같은 활동을 다시 클릭하면 선택이 취소됩니다. 활동을 선택하지 않으면 자동으로 자습으로 배정됩니다',
                            style: TextStyle(
                              fontSize: width * 0.034,
                              color: Color(0xff578FCA),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // toggleSubmissionStatus(index);
                      },

                      label: Text(
                        "신청하기",
                        style: TextStyle(fontSize: width * 0.035),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF86C1FF),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * 0.025),
                        ),
                        padding: EdgeInsets.symmetric(vertical: height * 0.018),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
