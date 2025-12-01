import pathlib
path=pathlib.Path('lib/teacher_page/teacher_check.dart')
lines=path.read_text(encoding='utf-8').splitlines()
lines[678]="                    child: const Text('Download all'),"
lines[685]="                'No attachments submitted.',"
path.write_text('\n'.join(lines)+"\n", encoding='utf-8')
