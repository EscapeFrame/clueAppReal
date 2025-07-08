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
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(vertical: 5),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              // headers: const {
                // "User-Agent":
                    // "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
              // },
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              color: Color(0xffF3F3F3),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 1),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    neyong,
                    style: TextStyle(fontSize: 18)
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
