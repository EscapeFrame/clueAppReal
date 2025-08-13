import 'package:flutter/material.dart';

class EightNineClass extends StatelessWidget {
  const EightNineClass({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    
    return Container(
          color: const Color(0xffffffff),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.06,
            vertical: height * 0.015,
      ),
      child: Column(
        children: [
          Text('8~9교시'),
        ],
      ),
    );
  }
}