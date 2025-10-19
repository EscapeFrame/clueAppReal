import 'package:clue/linksave/LinksaveModal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Cluelink extends StatefulWidget {
  const Cluelink({super.key});

  @override
  State<Cluelink> createState() => _CluelinkState();
}

class _CluelinkState extends State<Cluelink> {
  final List<String> categories = ['전체', '인문과목', '전공과목', '방과후'];
  int selectedIndex = 0; //기본선택 : 전체
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showLinkAddDialog(context);
        },
        backgroundColor: const Color(0xff0077FF),
        child: const Icon(Icons.add, color: Color(0xffffffff),),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.062),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/link.svg',
                            width: width * 0.1,
                          ),
                          SvgPicture.asset(
                            'assets/images/cluelinkText.svg',
                            width: width * 0.25,
                          ),
                        ],
                      ),
                    ),

                    Container(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/bars-3.svg',
                            width: width * 0.074,
                          ),
                          SizedBox(width: width * 0.03),
                          SvgPicture.asset(
                            'assets/images/jong.svg',
                            width: width * 0.055,
                          ),
                          SizedBox(width: width * 0.0443),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                Container(
                  decoration: BoxDecoration(
                    // color: Colors.grey.shade200,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "검색할 내용을 입력하세요",
                      hintStyle: TextStyle(color: Colors.grey.shade700),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 17,
                      ),
                      // suffixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.013),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(categories.length, (index) {
                    final bool isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xff0077FF)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: height * 0.012),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,

              decoration: BoxDecoration(color: Colors.grey.shade200),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: width * 0.25,

                    height: width * 0.25,
                    decoration: BoxDecoration(
                      color: Color(0xffB7DAFF),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(
                      Icons.open_in_new,
                      color: Color(0xff0077FF),
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
            ),
          ),
        ],
      ),
    );
  }
}
