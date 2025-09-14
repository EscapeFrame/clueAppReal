// 사용자가 업로드한 링크 목록을 표시하고 외부로 엽니다.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadedLinksSection extends StatelessWidget {
  final List<String> urls;
  final void Function(int index) onRemove;

  const UploadedLinksSection({super.key, required this.urls, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (urls.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: height * 0.015),
        Text('업로드된 링크', style: TextStyle(fontWeight: FontWeight.bold, fontSize: width * 0.045)),
        SizedBox(height: height * 0.009),
        ...List.generate(urls.length, (index) {
          final url = urls[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: EdgeInsets.all(width * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(width * 0.025),
            ),
            child: Row(children: [
              const Icon(Icons.link),
              SizedBox(width: width * 0.025),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final u = Uri.tryParse(url);
                    if (u != null) {
                      await launchUrl(u, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    url,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: width * 0.03, color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              ),
              SizedBox(width: width * 0.02),
              GestureDetector(onTap: () => onRemove(index), child: Icon(Icons.close, size: width * 0.045)),
            ]),
          );
        }),
      ],
    );
  }
}
