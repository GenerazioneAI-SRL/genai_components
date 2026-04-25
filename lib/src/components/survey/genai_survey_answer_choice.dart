import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:star_rating/star_rating.dart';

import '../../theme/context_extensions.dart';
import '../inputs/genai_text_field.dart';
import '../inputs/genai_textarea.dart';
import 'models/genai_survey_option.dart';
import 'models/genai_survey_question.dart';

/// Internal widget that renders the appropriate answer input for a question.
class GenaiSurveyAnswerChoice extends StatefulWidget {
  final void Function(List<Map<String, String>> answers) onChange;
  final GenaiSurveyQuestion question;
  final bool isNumeric;

  const GenaiSurveyAnswerChoice({
    super.key,
    required this.question,
    required this.onChange,
    required this.isNumeric,
  });

  @override
  State<GenaiSurveyAnswerChoice> createState() =>
      _GenaiSurveyAnswerChoiceState();
}

class _GenaiSurveyAnswerChoiceState extends State<GenaiSurveyAnswerChoice> {
  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    if (q.options.isNotEmpty) {
      return q.singleChoice
          ? _SingleChoice(onChange: widget.onChange, question: q)
          : _MultipleChoice(onChange: widget.onChange, question: q);
    }
    if (q.isStarRating) {
      return _StarRating(
          key: ObjectKey(q), onChange: widget.onChange, question: q);
    }
    return _Sentence(
        key: ObjectKey(q),
        onChange: widget.onChange,
        question: q,
        isNumeric: widget.isNumeric);
  }
}

// ─── single choice ───────────────────────────────────────────────────────────
class _SingleChoice extends StatefulWidget {
  final void Function(List<Map<String, String>>) onChange;
  final GenaiSurveyQuestion question;
  const _SingleChoice({required this.onChange, required this.question});

  @override
  State<_SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<_SingleChoice> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.question.answers.isNotEmpty) {
      _selected = widget.question.answers.first.keys.first;
    }
  }

  void _select(String id) {
    setState(() => _selected = id);
    final opt = widget.question.options.firstWhere((o) => o.id == id);
    widget.onChange([
      {opt.id: opt.text}
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    if (q.isRating && q.isNumeric) {
      return _buildNumericRating(context);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: q.options
          .map((o) => _OptionTile(
                isSelected: _selected == o.id,
                isRadio: true,
                text: o.text,
                onTap: () => _select(o.id),
              ))
          .toList(),
    );
  }

  Widget _buildNumericRating(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final sizing = context.sizing;
    return Semantics(
      container: true,
      label: 'Rating',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.question.options.map((option) {
          final isSelected = _selected == option.id;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isSelected,
              label: option.text,
              child: GestureDetector(
                onTap: () => _select(option.id),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: spacing.s1),
                    padding: EdgeInsets.symmetric(vertical: spacing.s4),
                    decoration: BoxDecoration(
                      color: isSelected ? c.colorPrimary : c.surfaceCard,
                      borderRadius: BorderRadius.circular(radius.md),
                      border: Border.all(
                        color: isSelected ? c.colorPrimary : c.borderDefault,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        option.text,
                        style: ty.bodyMd.copyWith(
                          color: isSelected ? c.textOnPrimary : c.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── multiple choice ─────────────────────────────────────────────────────────
class _MultipleChoice extends StatefulWidget {
  final void Function(List<Map<String, String>>) onChange;
  final GenaiSurveyQuestion question;
  const _MultipleChoice({required this.onChange, required this.question});

  @override
  State<_MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<_MultipleChoice> {
  late List<Map<String, String>> _answers;

  @override
  void initState() {
    super.initState();
    _answers = List.from(widget.question.answers);
  }

  void _toggle(GenaiSurveyOption option) {
    setState(() {
      final exists = _answers.any((e) => e.keys.first == option.id);
      if (exists) {
        _answers.removeWhere((e) => e.keys.first == option.id);
      } else {
        _answers.add({option.id: option.text});
      }
    });
    widget.onChange(_answers);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.question.options.map((o) {
        final isSelected = _answers.any((e) => e.keys.first == o.id);
        return _OptionTile(
          isSelected: isSelected,
          isRadio: false,
          text: o.text,
          onTap: () => _toggle(o),
        );
      }).toList(),
    );
  }
}

// ─── option tile ─────────────────────────────────────────────────────────────
class _OptionTile extends StatefulWidget {
  final bool isSelected;
  final bool isRadio;
  final String text;
  final VoidCallback onTap;

  const _OptionTile({
    required this.isSelected,
    required this.isRadio,
    required this.text,
    required this.onTap,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final sizing = context.sizing;
    final motion = context.motion;
    return Semantics(
      button: true,
      selected: widget.isSelected,
      label: widget.text,
      inMutuallyExclusiveGroup: widget.isRadio,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: motion.hover.duration,
            curve: motion.hover.curve,
            margin: EdgeInsets.only(bottom: spacing.s2),
            padding: EdgeInsets.symmetric(
                horizontal: spacing.s4, vertical: spacing.s2),
            constraints: BoxConstraints(minHeight: sizing.minTouchTarget),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? c.colorPrimarySubtle
                  : _hover
                      ? c.surfaceHover
                      : c.surfaceCard,
              borderRadius: BorderRadius.circular(radius.md),
              border: Border.all(
                color: widget.isSelected
                    ? c.colorPrimary
                    : _hover
                        ? c.colorPrimary.withValues(alpha: 0.5)
                        : c.borderDefault,
                width: widget.isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: widget.isRadio ? _radio(c) : _checkbox(c, radius),
                ),
                SizedBox(width: spacing.s4),
                Expanded(
                  child: Text(
                    widget.text,
                    style: ty.bodyMd.copyWith(
                      color: widget.isSelected ? c.colorPrimary : c.textPrimary,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (widget.isSelected)
                  Icon(LucideIcons.circleCheck,
                      size: 20, color: c.colorPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _radio(c) => RadioGroup<bool>(
        groupValue: widget.isSelected,
        onChanged: (_) => widget.onTap(),
        child: Radio<bool>(
          value: true,
          activeColor: c.colorPrimary,
          fillColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? c.colorPrimary
                  : c.borderDefault),
        ),
      );

  Widget _checkbox(c, radius) => Checkbox(
        value: widget.isSelected,
        hoverColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        activeColor: c.colorPrimary,
        checkColor: c.textOnPrimary,
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? c.colorPrimary
                : c.borderDefault,
            width: 1,
          ),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.sm)),
        onChanged: (_) => widget.onTap(),
      );
}

// ─── sentence (text input) ───────────────────────────────────────────────────
class _Sentence extends StatefulWidget {
  final void Function(List<Map<String, String>>) onChange;
  final GenaiSurveyQuestion question;
  final bool isNumeric;

  const _Sentence({
    super.key,
    required this.onChange,
    required this.question,
    required this.isNumeric,
  });

  @override
  State<_Sentence> createState() => _SentenceState();
}

class _SentenceState extends State<_Sentence> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.question.answers.isNotEmpty
          ? widget.question.answers.first.values.first
          : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNumeric) {
      return GenaiTextField.numeric(
        controller: _ctrl,
        label: 'Inserisci un valore',
        onChanged: (v) => widget.onChange([
          {'text': _ctrl.text}
        ]),
      );
    }
    return GenaiTextarea(
      controller: _ctrl,
      label: 'Inserisci la tua risposta',
      minLines: 3,
      maxLines: 6,
      onChanged: (v) => widget.onChange([
        {'text': _ctrl.text}
      ]),
    );
  }
}

// ─── star rating ─────────────────────────────────────────────────────────────
class _StarRating extends StatefulWidget {
  final void Function(List<Map<String, String>>) onChange;
  final GenaiSurveyQuestion question;
  const _StarRating(
      {super.key, required this.onChange, required this.question});

  @override
  State<_StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<_StarRating> {
  Map<String, String>? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.question.answers.isNotEmpty) {
      _selected = widget.question.answers.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ty = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final rating = _selected == null
        ? 0.0
        : (double.tryParse(_selected!.values.first) ?? 0);

    return Semantics(
      container: true,
      label: 'Valutazione a stelle',
      value: _selected == null
          ? 'Non valutato'
          : '${_selected!.values.first} su 5',
      child: Container(
        padding: EdgeInsets.all(spacing.cardPadding),
        decoration: BoxDecoration(
          color: c.surfacePage,
          borderRadius: BorderRadius.circular(radius.md),
        ),
        child: Column(
          children: [
            StarRating(
              mainAxisAlignment: MainAxisAlignment.center,
              length: 5,
              rating: rating,
              between: spacing.s3,
              starSize: spacing.s10,
              color: c.colorPrimary,
              onRaitingTap: (newRating) {
                setState(() {
                  _selected = {'': newRating.toString()};
                });
                widget.onChange([_selected!]);
              },
            ),
            if (_selected != null) ...[
              SizedBox(height: spacing.s4),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: spacing.s4, vertical: spacing.s2),
                decoration: BoxDecoration(
                  color: c.colorPrimarySubtle,
                  borderRadius: BorderRadius.circular(radius.md),
                ),
                child: Text(
                  '${_selected!.values.first}/5 stelle',
                  style: ty.bodyMd.copyWith(
                    color: c.colorPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
