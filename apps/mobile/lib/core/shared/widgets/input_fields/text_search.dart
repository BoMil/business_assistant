import 'dart:async';
import 'package:flutter/material.dart';
import 'package:business_assistant/core/shared/widgets/input_fields/primary_input_field.dart';
import 'package:business_assistant/theme/get_theme_color.dart';

/// Debounced search input — calls [onTypingComplete] 500ms after the user
/// stops typing, instead of on every keystroke.
class TextSearch extends StatefulWidget {
  final void Function(String text) onTypingComplete;
  final String hintText;

  const TextSearch({super.key, required this.onTypingComplete, this.hintText = 'Search...'});

  @override
  State<TextSearch> createState() => _TextSearchState();
}

class _TextSearchState extends State<TextSearch> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryInputField(
      controller: _controller,
      hintText: widget.hintText,
      showValidationError: false,
      minContainerHeight: 0,
      floatLabelToTop: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      inputBackgroundCollor: context.colors.baseWhite,
      borderColor: context.colors.primaryText.withValues(alpha: 0.09),
      prefixIcon: Icon(Icons.search, color: context.colors.primaryText.withValues(alpha: 0.5)),
      onChanged: (text) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          widget.onTypingComplete(text);
        });
      },
    );
  }
}
