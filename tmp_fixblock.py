import pathlib
path=pathlib.Path('lib/teacher_page/teacher_check.dart')
lines=path.read_text(encoding='utf-8').splitlines()
start=664
end=701
replacement=[
"                if (attachments.isNotEmpty)",
"                  TextButton(",
"                    onPressed:",
"                        onDownloadAll != null",\
"                            ? () => onDownloadAll!(attachments)",
"                            : null,",
"                    style: TextButton.styleFrom(",
"                      foregroundColor: primaryColor,",
"                      padding: const EdgeInsets.symmetric(",
"                        horizontal: 12,",
"                        vertical: 10,",
"                      ),",
"                    ),",
"                    child: const Text('전체 다운로드'),",
"                  ),",
"              ],",
"            ),",
"            const SizedBox(height: 8),",
"            if (attachments.isEmpty)",
"              const Text(",
"                '제출된 파일이 없습니다.',",
"                style: TextStyle(color: textSecondary),",
"              )",
"            else",
"              ConstrainedBox(",
"                constraints: BoxConstraints(",
"                  maxHeight: attachments.length > 3 ? 320 : double.infinity,",
"                ),",
"                child: ListView.separated(",
"                  shrinkWrap: true,",
"                  physics:",
"                      attachments.length > 3",
"                          ? const BouncingScrollPhysics()",
"                          : const NeverScrollableScrollPhysics(),",
"                  itemCount: attachments.length,",
"                  separatorBuilder: (_, __) => const SizedBox(height: 10),",
"                  itemBuilder: (context, index) {",
"                    final attachment = attachments[index];",
]
lines[start:end+1]=replacement
path.write_text('\n'.join(lines)+"\n", encoding='utf-8')
