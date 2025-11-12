import 'package:clue/chat/chat_message.dart';
import 'package:clue/chat/chat_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String title;
  const ChatScreen({super.key, required this.roomId, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _meId = 'me';
  final _meName = '나';
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _hhmm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  String _ymd(DateTime t) => '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await ChatService.instance.sendMessage(
      roomId: widget.roomId,
      senderId: _meId,
      senderName: _meName,
      text: text,
    );
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final pos = _scroll.position.maxScrollExtent;
      _scroll.animateTo(
        pos,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            Container(width: 4, height: 18, color: const Color(0xFFFF8A00)),
            const SizedBox(width: 8),
            const Icon(Icons.bookmark_border, color: Color(0xFF0D6EFD)),
            const SizedBox(width: 8),
            Text(widget.title, style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
      body: Column(
        children: [
          // 날짜 라벨
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _ymd(DateTime.now()),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: ChatService.instance.messagesStream(widget.roomId, titleForSeed: widget.title),
              builder: (context, snap) {
                final items = snap.data ?? const <ChatMessage>[];
                // 데이터가 바뀔 때마다 하단으로 스크롤
                _scrollToBottom();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  controller: _scroll,
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final m = items[i];
                    final mine = m.senderId == _meId;
                    final time = Text(
                      _hhmm(m.timestamp),
                      style: const TextStyle(fontSize: 11, color: Colors.black45),
                    );

                    final bubble = Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: mine ? const Color(0xFF0D6EFD) : const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        m.text,
                        style: TextStyle(
                          color: mine ? Colors.white : Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    );

                    if (mine) {
                      // 내 메시지: 시간(작게) 뒤에 파란 말풍선, 오른쪽 정렬
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            time,
                            const SizedBox(width: 6),
                            bubble,
                          ],
                        ),
                      );
                    } else {
                      // 상대방: 왼쪽 동그라미 아바타 + 회색 말풍선 + 시간
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFE0E0E0),
                            ),
                            const SizedBox(width: 8),
                            bubble,
                            const SizedBox(width: 6),
                            time,
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    color: const Color(0xFF0D6EFD),
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
