import pathlib
path=pathlib.Path('lib/teacher_page/teacher_check.dart')
lines=path.read_text(encoding='utf-8').splitlines()
lines[678] = "                    child: const Text('Download all'),"
# remove extra child line 679
lines[679] = "              ],"
lines[680] = "            ),"
lines[681] = "            const SizedBox(height: 8),"
lines[682] = "            if (attachments.isEmpty)"
lines[683] = "              const Text("
lines[684] = "                'No attachments submitted.',"
lines[685] = "                style: TextStyle(color: textSecondary),"
lines[686] = "              )"
path.write_text('\n'.join(lines)+"\n", encoding='utf-8')
