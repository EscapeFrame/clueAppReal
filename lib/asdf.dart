import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:clue/widgets/common/app_snackbar.dart';

class Asdf extends StatefulWidget {
  const Asdf({super.key});

  @override
  State<Asdf> createState() => _AsdfState();
}

class _AsdfState extends State<Asdf> {
  // 백엔드: GET /skim?fuck={value} → 302 realclue://fuck
  final TextEditingController _baseUrlController = TextEditingController(
    text: 'http://10.150.149.88:8090',
  );
  final TextEditingController _fuckController = TextEditingController(
    text: 'hello',
  );
  bool _busy = false;

  Uri? _buildSkimUri() {
    final baseText = _baseUrlController.text.trim();
    if (baseText.isEmpty) return null;
    final base = Uri.tryParse(baseText);
    if (base == null || (!base.hasScheme || base.host.isEmpty)) return null;

    final path =
        (base.path.isEmpty || base.path == '/')
            ? '/skim'
            : (base.path.endsWith('/')
                ? '${base.path}skim'
                : '${base.path}/skim');
    return base.replace(
      path: path,
      queryParameters: {'fuck': _fuckController.text.trim()},
    );
  }

  Future<void> _openSkimInBrowser() async {
    final uri = _buildSkimUri();
    if (uri == null) {
      _showSnack('유효하지 않은 기본 URL');
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) _showSnack('브라우저 열기 실패');
  }

  Future<void> _requestSkimThenLaunchScheme() async {
    final uri = _buildSkimUri();
    if (uri == null) {
      _showSnack('유효하지 않은 기본 URL');
      return;
    }

    setState(() => _busy = true);
    try {
      final req = http.Request('GET', uri);
      req.followRedirects = false; // 302 Location 직접 확인
      final res = await req.send();

      final code = res.statusCode;
      final location = res.headers['location'];

      if (code >= 300 && code < 400 && location != null) {
        final target = Uri.tryParse(location);
        if (target == null) {
          _showSnack('리다이렉트 Location 파싱 실패: $location');
        } else {
          final ok = await launchUrl(
            target,
            mode: LaunchMode.externalApplication,
          );
          if (!ok) _showSnack('스킴 실행 실패: $target');
        }
      } else {
        _showSnack('리다이렉트가 아님 (code: $code)');
      }
    } catch (e, st) {
      debugPrint('로그 컨텍스트: $e');
      debugPrint('$st');
      _showSnack('요청을 처리하는 중 문제가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String msg) {
    showAppSnackBar(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheme Test (/skim?fuck=)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('기본 URL (백엔드 베이스)'),
            const SizedBox(height: 8),
            TextField(
              controller: _baseUrlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: '예: http://10.150.149.88:8090',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text("쿼리 파라미터 'fuck' 값"),
            const SizedBox(height: 8),
            TextField(
              controller: _fuckController,
              decoration: const InputDecoration(
                hintText: '예: hello',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _busy ? null : _openSkimInBrowser,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('브라우저로 /skim?fuck= 열기 (리다이렉트 따라감)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _busy ? null : _requestSkimThenLaunchScheme,
              icon:
                  _busy
                      ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.link),
              label: const Text('앱 내에서 /skim 요청 → 스킴 실행'),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (_) {
                final built = _buildSkimUri();
                return Text('요청 미리보기: ' + (built?.toString() ?? 'URL 오류'));
              },
            ),
            const SizedBox(height: 8),
            const Text('리다이렉트 대상은 realclue://auth/callback 로 예상합니다.'),
          ],
        ),
      ),
    );
  }
}
