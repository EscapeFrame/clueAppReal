import 'package:clue/config/app_cheat.dart';
import 'package:clue/chat/chat_message.dart';
import 'package:clue/chat/chat_screen.dart';
import 'package:clue/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SettingsCheat extends StatelessWidget {
  const SettingsCheat({super.key});

  String _ymd(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 바
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'assets/images/realLogo.svg',
                      width: width * 0.25,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back, size: width * 0.07),
                        ),
                        SizedBox(width: width * 0.03),
                        SvgPicture.asset(
                          'assets/images/bars-3.svg',
                          width: width * 0.074,
                        ),
                        SizedBox(width: width * 0.0443),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 본문
            Container(
              color: const Color(0xffffffff),
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.03),
                  Text(
                    '채팅 보관함',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: width * 0.055,
                    ),
                  ),
                  SizedBox(height: height * 0.02),

                  // 채팅 카드 목록
                  ...AppCheat.cheatData.map((item) {
                    final title = (item['name'] ?? '').toString();
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.008),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      ChatScreen(roomId: title, title: title),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE9ECEF)),
                          ),
                          child: StreamBuilder<List<ChatMessage>>(
                            stream: ChatService.instance.messagesStream(title),
                            builder: (context, snapshot) {
                              final list =
                                  snapshot.data ?? const <ChatMessage>[];
                              final ChatMessage? last =
                                  list.isNotEmpty ? list.last : null;
                              final date =
                                  last != null ? _ymd(last.timestamp) : '';
                              final preview = (last?.text ?? '').replaceAll(
                                '\n',
                                ' ',
                              );
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: width * 0.045,
                                          ),
                                        ),
                                      ),
                                      if (date.isNotEmpty)
                                        Text(
                                          date,
                                          style: TextStyle(
                                            fontSize: width * 0.032,
                                            color: const Color(0xFF6C757D),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    preview.isEmpty ? '메시지가 없습니다' : preview,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: width * 0.038,
                                      color: const Color(0xFF6C757D),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
