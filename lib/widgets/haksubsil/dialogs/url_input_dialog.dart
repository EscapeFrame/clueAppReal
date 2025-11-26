import 'package:flutter/material.dart';

bool _isValidUrl(String input) {
  final uri = Uri.tryParse(input.trim());
  if (uri == null) return false;
  final scheme = uri.scheme.toLowerCase();
  final hasValidScheme = scheme == 'http' || scheme == 'https';
  return hasValidScheme && uri.host.isNotEmpty;
}

/// URL 링크 입력 모달. 입력된 링크를 onUrlAdded 콜백으로 전달한다.
Future<void> showUrlInputDialog(
  BuildContext context,
  void Function(String) onUrlAdded,
) async {
  final controller = TextEditingController();
  const brand = Color(0xff3B82F6);
  String? errorText;
  await showDialog(
    context: context,
    builder: (ctx) {
      final width = MediaQuery.of(ctx).size.width;
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'URL 링크 업로드',
                        style: TextStyle(
                          fontSize: width * 0.042,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '공유할 URL을 입력하세요.',
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: const Color(0xff4B5563),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: '예) https://example.com',
                      errorText: errorText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: brand, width: 1.6),
                      ),
                    ),
                    keyboardType: TextInputType.url,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.028,
                            ),
                            side: const BorderSide(color: Color(0xffCBD5F5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final url = controller.text.trim();
                            if (url.isEmpty || !_isValidUrl(url)) {
                              setState(() {
                                errorText = '유효한 URL을 입력해주세요.';
                              });
                              return;
                            }
                            onUrlAdded(url);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: width * 0.028,
                            ),
                            backgroundColor: brand,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('등록'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
