import 'package:flutter/material.dart';

class LinkEditPayload {
  const LinkEditPayload({
    required this.title,
    required this.url,
    required this.tags,
    this.description,
    this.restrictByGrade = false,
    this.restrictByClass = false,
  });

  final String title;
  final String url;
  final String? description;
  final List<String> tags;
  final bool restrictByGrade;
  final bool restrictByClass;
}

Future<LinkEditPayload?> showLinkEditDialog(
  BuildContext context, {
  required LinkEditPayload initial,
  List<String>? allTags,
}) {
  final tags =
      <String>{..._defaultTags, ...initial.tags, ...?allTags}.toList()..sort();

  return showDialog<LinkEditPayload>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _LinkEditDialog(initial: initial, allTags: tags),
  );
}

const List<String> _defaultTags = ['인문과목', '전공과목', '방과후'];

class _LinkEditDialog extends StatefulWidget {
  const _LinkEditDialog({required this.initial, required this.allTags});

  final LinkEditPayload initial;
  final List<String> allTags;

  @override
  State<_LinkEditDialog> createState() => _LinkEditDialogState();
}

class _LinkEditDialogState extends State<_LinkEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleC;
  late final TextEditingController _urlC;
  late final TextEditingController _descC;
  late final Set<String> _selected;
  late bool _byGrade;
  late bool _byClass;
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.initial.title);
    _urlC = TextEditingController(text: widget.initial.url);
    _descC = TextEditingController(text: widget.initial.description ?? '');
    _selected = {...widget.initial.tags};
    _byGrade = widget.initial.restrictByGrade;
    _byClass = widget.initial.restrictByClass;

    _listener = () => setState(() {});
    _titleC.addListener(_listener);
    _urlC.addListener(_listener);
  }

  @override
  void dispose() {
    _titleC
      ..removeListener(_listener)
      ..dispose();
    _urlC
      ..removeListener(_listener)
      ..dispose();
    _descC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit = _canSubmit;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width =
              constraints.hasBoundedWidth
                  ? constraints.maxWidth
                  : MediaQuery.of(context).size.width;
          final viewInsets = MediaQuery.of(context).viewInsets;
          final minWidth =
              constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(bottom: viewInsets.bottom),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '링크수정',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: width * 0.05,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              splashRadius: 18,
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildLabeledField(
                          context,
                          label: '제목',
                          requiredMark: true,
                          child: TextFormField(
                            controller: _titleC,
                            decoration: InputDecoration(
                              hintText: '제목을 입력해주세요.',
                              hintStyle: TextStyle(fontSize: width * 0.03 + 3),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '제목은 필수입니다.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          context,
                          label: 'URL',
                          requiredMark: true,
                          child: TextFormField(
                            controller: _urlC,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              hintText: 'URL을 입력해주세요.',
                              hintStyle: TextStyle(fontSize: width * 0.03 + 3),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'URL은 필수입니다.';
                              }
                              final trimmed = value.trim();
                              final hasScheme =
                                  trimmed.startsWith('http://') ||
                                  trimmed.startsWith('https://');
                              if (!hasScheme) {
                                return '올바른 주소를 입력해주세요';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          context,
                          label: '설명',
                          child: TextFormField(
                            controller: _descC,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'URL에 대한 설명을 간단히 적어주세요.',
                              hintStyle: TextStyle(fontSize: width * 0.03 + 3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          context,
                          label: '태그',
                          requiredMark: true,
                          helper: '중복선택이 가능하며 1개 이상 선택해주셔야합니다.',
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: width * 0.003 + 7,
                              runSpacing: width * 0.003 + 7,
                              children:
                                  widget.allTags
                                      .map(
                                        (tag) => _LinkOptionChip(
                                          label: tag,
                                          selected: _selected.contains(tag),
                                          onTap: () {
                                            setState(() {
                                              if (_selected.contains(tag)) {
                                                _selected.remove(tag);
                                              } else {
                                                _selected.add(tag);
                                              }
                                            });
                                          },
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          context,
                          label: '공개범위',
                          requiredMark: true,
                          helper: '중복선택이 가능하며 1개이상 선택해주셔야합니다.',
                          child: Wrap(
                            spacing: 18,
                            children: [
                              _LinkScopeToggle(
                                label: '학년',
                                selected: _byGrade,
                                onChanged:
                                    (value) => setState(() {
                                      _byGrade = value;
                                    }),
                              ),
                              _LinkScopeToggle(
                                label: '반',
                                selected: _byClass,
                                onChanged:
                                    (value) => setState(() {
                                      _byClass = value;
                                    }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xff86C1FF),
                                  ),
                                ),
                                child: const Text('취소', style:TextStyle(color:Colors.black)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: () async {
                                  final valid =
                                      _formKey.currentState?.validate() ??
                                      false;
                                  if (!valid) return;
                                  if (_selected.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('태그를 1개 이상 선택해주세요.'),
                                      ),
                                    );
                                    return;
                                  }
                                  if (!_byGrade && !_byClass) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('공개범위를 1개 이상 선택해주세요.'),
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.pop(
                                    context,
                                    LinkEditPayload(
                                      title: _titleC.text.trim(),
                                      url: _urlC.text.trim(),
                                      description:
                                          _descC.text.trim().isEmpty
                                              ? null
                                              : _descC.text.trim(),
                                      tags: _selected.toList(),
                                      restrictByGrade: _byGrade,
                                      restrictByClass: _byClass,
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      canSubmit
                                          ? const Color(0xFF86C1FF)
                                          : const Color(0xFFE4E4E4),
                                  foregroundColor:
                                       Colors.black87,
                                ),
                                child: const Text('확인'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool get _canSubmit {
    final titleFilled = _titleC.text.trim().isNotEmpty;
    final urlText = _urlC.text.trim();
    final urlValid =
        urlText.isNotEmpty &&
        (urlText.startsWith('http://') || urlText.startsWith('https://'));
    final hasTags = _selected.isNotEmpty;
    final hasScope = _byGrade || _byClass;
    return titleFilled && urlValid && hasTags && hasScope;
  }

  Widget _buildLabeledField(
    BuildContext context, {
    required String label,
    required Widget child,
    bool requiredMark = false,
    String? helper,
  }) {
    final width = MediaQuery.of(context).size.width;

    final base = Theme.of(context);
    final labelStyle = base.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: width * 0.04,
    );
    final decoratedChild = Theme(
      data: base.copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      child: child,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: labelStyle,
            children:
                requiredMark
                    ? [
                      TextSpan(
                        text: ' *',
                        style: labelStyle?.copyWith(color: Colors.blue),
                      ),
                    ]
                    : null,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 4),
          Text(
            helper,
            style: base.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: width * 0.033,
            ),
          ),
        ],
        const SizedBox(height: 8),
        decoratedChild,
      ],
    );
  }
}

class _LinkOptionChip extends StatelessWidget {
  const _LinkOptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Transform.scale(
      scale: width * 0.0015 + 0.3,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0077FF) : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LinkScopeToggle extends StatelessWidget {
  const _LinkScopeToggle({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: TextStyle(fontSize: width * 0.035)),
        const SizedBox(width: 10),
        Transform.scale(
          scale: 0.9,
          child: Switch(
            value: selected,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            trackColor: WidgetStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF0077FF);
                }
                return const Color(0xFFD9D9D9);
              },
            ),
            thumbColor: WidgetStateProperty.all(Colors.white),
            trackOutlineColor:
                WidgetStateProperty.all(Colors.transparent),
          ),
        ),
      ],
    );
  }
}
