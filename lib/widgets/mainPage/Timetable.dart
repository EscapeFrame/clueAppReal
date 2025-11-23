import 'package:clue/api_client.dart';
import 'package:flutter/material.dart';

class HomeTimetableSection extends StatefulWidget {
  const HomeTimetableSection({super.key});

  @override
  State<HomeTimetableSection> createState() => _HomeTimetableSectionState();
}

class _HomeTimetableSectionState extends State<HomeTimetableSection> {
  static const List<String> _weekdayTabs = ['월', '화', '수', '목', '금'];
  static const Map<int, String> _periodTimeRanges = {
    1: '08:40 ~ 09:30',
    2: '09:40 ~ 10:30',
    3: '10:40 ~ 11:30',
    4: '11:40 ~ 12:30',
    5: '13:20 ~ 14:10',
    6: '14:20 ~ 15:10',
    7: '15:20 ~ 16:10',
  };
  static const String _lunchTimeRange = '12:30 ~ 13:20';
  static const Map<int, _PeriodClockRange> _periodClockRanges = {
    1: _PeriodClockRange(8, 40, 9, 30),
    2: _PeriodClockRange(9, 40, 10, 30),
    3: _PeriodClockRange(10, 40, 11, 30),
    4: _PeriodClockRange(11, 40, 12, 30),
    5: _PeriodClockRange(13, 20, 14, 10),
    6: _PeriodClockRange(14, 20, 15, 10),
    7: _PeriodClockRange(15, 20, 16, 10),
  };

  final Map<String, List<_TimetableEntry>> _weeklyTimetable = {
    for (final day in _weekdayTabs) day: <_TimetableEntry>[],
  };
  bool _isLoadingTimetable = false;
  String? _timetableError;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyTimetable();
  }

  Future<void> _fetchWeeklyTimetable() async {
    setState(() {
      _isLoadingTimetable = true;
      _timetableError = null;
    });
    try {
      final response = await ApiClient.instance.dio.get(
        '/api/timetable/weekly',
        queryParameters: {'grade': '2', 'classNumber': '2'},
      );
      final normalized = _composeWeeklyTimetable(response.data);
      if (!mounted) return;
      setState(() {
        for (final day in _weekdayTabs) {
          _weeklyTimetable[day] = List<_TimetableEntry>.from(
            normalized[day] ?? const <_TimetableEntry>[],
          );
        }
        _isLoadingTimetable = false;
      });
    } catch (e) {
      debugPrint('주간 시간표 불러오기 실패: $e');
      if (!mounted) return;
      setState(() {
        _timetableError = '시간표를 불러오지 못했어요.';
        _isLoadingTimetable = false;
      });
    }
  }

  Map<String, List<_TimetableEntry>> _composeWeeklyTimetable(dynamic raw) {
    final Map<String, List<_TimetableEntry>> grouped = {
      for (final day in _weekdayTabs) day: <_TimetableEntry>[],
    };
    if (raw is! List) return grouped;
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final dayLabel = _normalizeDay(map['dayOfWeek']);
      final period = _parsePeriod(map['period']);
      if (dayLabel == null || period == null) continue;
      final entry = _TimetableEntry(
        period: period,
        subject: _sanitizeSubject(map['subject']),
        location:
            (map['location'] ??
                    map['room'] ??
                    map['place'] ??
                    map['description'])
                ?.toString(),
        teacher: map['teacher']?.toString(),
        date: _parseYmd(map['date']),
      );
      grouped[dayLabel]!
        ..removeWhere((existing) => existing.period == period)
        ..add(entry);
    }
    final Map<String, List<_TimetableEntry>> normalized = {
      for (final day in _weekdayTabs) day: <_TimetableEntry>[],
    };
    for (final day in _weekdayTabs) {
      final existing = List<_TimetableEntry>.from(grouped[day]!);
      existing.sort((a, b) => a.period.compareTo(b.period));
      final periods = _periodTimeRanges.keys.where(
        (p) => !(day == '금' && p == 7),
      );
      for (final period in periods) {
        final match = existing.firstWhere(
          (entry) => entry.period == period,
          orElse: () => _TimetableEntry.selfStudy(period),
        );
        normalized[day]!.add(match);
      }
    }
    return normalized;
  }

  String? _currentDayLabel() {
    final weekday = DateTime.now().weekday;
    if (weekday < DateTime.monday || weekday > DateTime.friday) {
      return null;
    }
    final index = weekday - DateTime.monday;
    if (index < 0 || index >= _weekdayTabs.length) return null;
    return _weekdayTabs[index];
  }

  bool _isCurrentPeriod(String dayLabel, int period) {
    final currentDayLabel = _currentDayLabel();
    if (currentDayLabel == null || currentDayLabel != dayLabel) return false;
    final range = _periodClockRanges[period];
    if (range == null) return false;
    final now = DateTime.now();
    final start = range.startOn(now);
    final end = range.endOn(now);
    return !now.isBefore(start) && now.isBefore(end);
  }

  String? _normalizeDay(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;
    final upper = raw.toUpperCase();
    switch (upper) {
      case '월':
      case '월요일':
      case 'MON':
      case 'MONDAY':
        return '월';
      case '화':
      case '화요일':
      case 'TUE':
      case 'TUESDAY':
        return '화';
      case '수':
      case '수요일':
      case 'WED':
      case 'WEDNESDAY':
        return '수';
      case '목':
      case '목요일':
      case 'THU':
      case 'THURSDAY':
        return '목';
      case '금':
      case '금요일':
      case 'FRI':
      case 'FRIDAY':
        return '금';
      default:
        return null;
    }
  }

  int? _parsePeriod(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  DateTime? _parseYmd(dynamic value) {
    if (value == null) return null;
    final raw = value.toString();
    if (raw.isEmpty) return null;
    try {
      if (raw.contains('-')) return DateTime.parse(raw);
      if (raw.length == 8) {
        final year = int.parse(raw.substring(0, 4));
        final month = int.parse(raw.substring(4, 6));
        final day = int.parse(raw.substring(6, 8));
        return DateTime(year, month, day);
      }
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }


  String _sanitizeSubject(dynamic value) {
    const fallback = '??';
    if (value == null) return fallback;
    final raw = value.toString().trim();
    if (raw.isEmpty) return fallback;
    final cleaned = raw.replaceFirst(RegExp(r'^\*+\s*'), '');
    return cleaned.isEmpty ? fallback : cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final timetableHeight = height * 0.33;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset.zero,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.055,
        vertical: width * 0.055,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '나의 일과 보기',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: width * 0.042,
            ),
          ),
          SizedBox(height: height * 0.0000008),
          Text(
            '빠르게 나의 수업을 확인해보세요!',
            style: TextStyle(fontSize: width * 0.035, color: Colors.grey[600]),
          ),
          SizedBox(height: height * 0.014),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_weekdayTabs.length, (index) {
              final bool isSelected = _selectedDayIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: width * 0.1,
                  height: width * 0.1,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF0077FF)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _weekdayTabs[index],
                    style: TextStyle(
                      color:
                          isSelected ? Colors.white : const Color(0xFF7A7A7A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: height * 0.015),
          SizedBox(
            height: timetableHeight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(
                  'timetable-$_selectedDayIndex-${_timetableError ?? 'ok'}-$_isLoadingTimetable',
                ),
                child: ClipRect(child: _buildTimetableContent(width, height)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableContent(double width, double height) {
    if (_isLoadingTimetable) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.04),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_timetableError != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.03),
        child: Column(
          children: [
            Text(
              _timetableError!,
              style: TextStyle(
                fontSize: width * 0.035,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.012),
            TextButton(
              onPressed: _fetchWeeklyTimetable,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    final selectedDay = _weekdayTabs[_selectedDayIndex];
    final entries = _weeklyTimetable[selectedDay] ?? const <_TimetableEntry>[];
    if (entries.isEmpty) {
      return Center(
        child: Text(
          '등록된 수업이 없어요.',
          style: TextStyle(fontSize: width * 0.038, color: Colors.grey[600]),
        ),
      );
    }

    final children = <Widget>[];
    var addedLunch = false;
    for (final entry in entries) {
      children.add(_buildPeriodCard(entry, width, height, selectedDay));
      if (entry.period == 4 && !addedLunch) {
        addedLunch = true;
        children.add(_buildLunchCard(width, height));
      }
    }
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(bottom: height * 0.01),
      children: children,
    );
  }

  Widget _buildPeriodCard(
    _TimetableEntry entry,
    double width,
    double height,
    String dayLabel,
  ) {
    final timeText = _periodTimeRanges[entry.period] ?? '시간 정보 없음';
    final detail = _getEntryDetail(entry);
    final bool isCurrent = _isCurrentPeriod(dayLabel, entry.period);
    final Color backgroundColor =
        isCurrent ? const Color(0xFFEBF6FF) : Colors.white;
    final Color borderColor =
        isCurrent ? const Color(0xFF86C1FF) : const Color(0xFFE6E6E6);

    return Container(
      margin: EdgeInsets.only(bottom: height * 0.012),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.016,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: width * 0.11,
            child: Text(
              entry.period.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: width * 0.042,
                color: const Color(0xFF0077FF),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.subject,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: width * 0.04,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (detail != null)
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.003),
                    child: Text(
                      detail,
                      style: TextStyle(
                        fontSize: width * 0.033,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: width * 0.02),
          Text(
            timeText,
            style: TextStyle(
              fontSize: width * 0.033,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildLunchCard(double width, double height) {
    return Container(
      margin: EdgeInsets.only(bottom: height * 0.012),
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.015,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Row(
        children: [
          Text(
            '점심시간',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: width * 0.038,
              color: const Color(0xFF8C5300),
            ),
          ),
          const Spacer(),
          Text(
            _lunchTimeRange,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: width * 0.034,
              color: const Color(0xFF8C5300),
            ),
          ),
        ],
      ),
    );
  }

  String? _getEntryDetail(_TimetableEntry entry) {
    final candidates = [entry.location, entry.teacher];
    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return null;
  }
}

class _TimetableEntry {
  final int period;
  final String subject;
  final String? location;
  final String? teacher;
  final DateTime? date;
  final bool isSelfStudy;

  const _TimetableEntry({
    required this.period,
    required this.subject,
    this.location,
    this.teacher,
    this.date,
    this.isSelfStudy = false,
  });

  factory _TimetableEntry.selfStudy(int period) {
    return _TimetableEntry(period: period, subject: '자습', isSelfStudy: true);
  }
}

class _PeriodClockRange {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const _PeriodClockRange(
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
  );

  DateTime startOn(DateTime reference) => DateTime(
    reference.year,
    reference.month,
    reference.day,
    startHour,
    startMinute,
  );

  DateTime endOn(DateTime reference) => DateTime(
    reference.year,
    reference.month,
    reference.day,
    endHour,
    endMinute,
  );
}
