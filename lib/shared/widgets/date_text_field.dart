import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Text field that accepts a date typed as DD/MM/AAAA with auto-inserted slashes.
/// Calls [onChanged] with a valid [DateTime] when the full date is entered,
/// or null while the input is incomplete or invalid.
class DateTextField extends StatefulWidget {
  final DateTime? initialValue;
  final ValueChanged<DateTime?> onChanged;
  final DateStateBuilder? stateBuilder;

  const DateTextField({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.stateBuilder,
  });

  @override
  State<DateTextField> createState() => _DateTextFieldState();
}

class _DateTextFieldState extends State<DateTextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final d = widget.initialValue;
    _ctrl = TextEditingController(
      text: d == null
          ? ''
          : '${d.day.toString().padLeft(2, '0')}/'
              '${d.month.toString().padLeft(2, '0')}/'
              '${d.year}',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (value.length < 10) {
      widget.onChanged(null);
      return;
    }
    final parts = value.split('/');
    if (parts.length != 3) {
      widget.onChanged(null);
      return;
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null || year < 1900) {
      widget.onChanged(null);
      return;
    }
    // DateTime normalizes invalid dates (e.g. Feb 30 → Mar 2).
    // Comparing back ensures it is a real calendar date.
    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month || date.year != year) {
      widget.onChanged(null);
      return;
    }
    final state = widget.stateBuilder?.call(date) ?? DateState.enabled;
    widget.onChanged(state == DateState.enabled ? date : null);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: TextField(
        controller: _ctrl,
        keyboardType: TextInputType.number,
        placeholder: const Text('DD/MM/AAAA'),
        inputFormatters: [_DateFormatter()],
        onChanged: _onChanged,
      ),
    );
  }
}

/// Formats digit input as DD/MM/AAAA with smart single-digit auto-padding:
/// - Day first digit > 3  → auto-pads to "0D/" (e.g. "7" → "07/")
/// - Month first digit > 1 → auto-pads to "0M/" (e.g. "7" → "07/")
/// This ensures "1272003" → "12/07/2003" instead of "12/72/003".
class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // On deletion: strip trailing slash so backspace feels natural.
    if (newValue.text.length < oldValue.text.length) {
      var text = newValue.text;
      while (text.endsWith('/')) {
        text = text.substring(0, text.length - 1);
      }
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final text = _build(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _build(String digits) {
    if (digits.isEmpty) return '';
    final buf = StringBuffer();
    int di = 0;

    // ── Day ──────────────────────────────────────────────
    final d0 = int.parse(digits[di++]);
    if (d0 > 3) {
      // Single-digit day: auto-pad and advance.
      buf.write('0$d0/');
    } else if (di < digits.length) {
      buf.write('$d0${digits[di++]}/');
    } else {
      // Still typing the first day digit.
      buf.write('$d0');
      return buf.toString();
    }

    // ── Month ─────────────────────────────────────────────
    if (di >= digits.length) return buf.toString();
    final m0 = int.parse(digits[di++]);
    if (m0 > 1) {
      // Single-digit month: auto-pad and advance.
      buf.write('0$m0/');
    } else if (di < digits.length) {
      buf.write('$m0${digits[di++]}/');
    } else {
      buf.write('$m0');
      return buf.toString();
    }

    // ── Year (up to 4 digits) ─────────────────────────────
    int yearCount = 0;
    while (di < digits.length && yearCount < 4) {
      buf.write(digits[di++]);
      yearCount++;
    }

    return buf.toString();
  }
}
