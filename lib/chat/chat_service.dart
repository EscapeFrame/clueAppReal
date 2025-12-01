import 'dart:async';

import 'package:clue/chat/chat_message.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final Map<String, List<ChatMessage>> _rooms = {};
  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  Stream<List<ChatMessage>> messagesStream(
    String roomId, {
    String? titleForSeed,
  }) {
    _rooms.putIfAbsent(roomId, () => <ChatMessage>[]);
    _controllers.putIfAbsent(
      roomId,
      () => StreamController<List<ChatMessage>>.broadcast(
        onListen: () {
          // 시드 메시지 주입 제거: 초기 상태는 빈 목록 유지
          _emit(roomId);
        },
      ),
    );
    return _controllers[roomId]!.stream;
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final now = DateTime.now();
    final msg = ChatMessage(
      id: now.microsecondsSinceEpoch.toString(),
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: now,
    );
    _rooms.putIfAbsent(roomId, () => <ChatMessage>[]).add(msg);
    _emit(roomId);

    // 간단한 가짜 응답(시연용)
    Future.delayed(const Duration(seconds: 1), () {
      final reply = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        roomId: roomId,
        senderId: 'peer',
        senderName: '상대방',
        text: '확인했어요: $text',
        timestamp: DateTime.now(),
      );
      _rooms[roomId]!.add(reply);
      _emit(roomId);
    });
  }

  void _emit(String roomId) {
    final list = List<ChatMessage>.from(_rooms[roomId] ?? []);
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    _controllers[roomId]?.add(list);
  }

  // 스크린샷과 유사한 예시 메시지 시드
  void _seedIfEmpty(String roomId, String title) {
    final list = _rooms[roomId]!;
    if (list.isNotEmpty) return;

    final today = DateTime.now();
    DateTime at(int h, int m) =>
        DateTime(today.year, today.month, today.day, h, m);

    final seed = <ChatMessage>[
      ChatMessage(
        id: 'seed-1',
        roomId: roomId,
        senderId: 'me',
        senderName: '나',
        text: '채팅 저장해보게?',
        timestamp: at(12, 1),
      ),
      ChatMessage(
        id: 'seed-2',
        roomId: roomId,
        senderId: 'peer',
        senderName: title,
        text: '네, 궁금해서 한번 해볼려구요',
        timestamp: at(12, 1),
      ),
      ChatMessage(
        id: 'seed-3',
        roomId: roomId,
        senderId: 'peer',
        senderName: title,
        text: '선생님, 조 1 큰일.. 마감시간 1초 차이로 제출못 했어요..ㅠㅠㅠ',
        timestamp: at(21, 1),
      ),
      ChatMessage(
        id: 'seed-4',
        roomId: roomId,
        senderId: 'peer',
        senderName: title,
        text: '선생님 JAVA 하기싫으면 어떻게 해야하죠ㅠㅠ',
        timestamp: at(21, 3),
      ),
    ];
    list.addAll(seed);
  }
}
