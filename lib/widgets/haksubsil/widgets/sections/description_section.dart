// 과제 상세설명 텍스트를 보여줍니다.
import 'package:flutter/material.dart';

class DescriptionSection extends StatelessWidget {
  final String description;

  const DescriptionSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('상세설명', style: TextStyle(fontWeight: FontWeight.bold, fontSize: width * 0.045)),
        SizedBox(height: height * 0.01),
        Text(description, style: TextStyle(fontSize: width * 0.04, height: 1.6)),
      ],
    );
  }
}
