import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:star_rating/star_rating.dart';
import '../../cl_theme.dart';
import '../cl_text_field.widget.dart';

import '../../layout/constants/sizes.constant.dart';
import 'models/option.dart';
import 'models/question.dart';

class AnswerChoiceWidget extends StatefulWidget {
  final void Function(List<Map<String, String>> answers) onChange;
  final Question question;
  final bool isNumeric;

  const AnswerChoiceWidget({
    super.key,
    required this.question,
    required this.onChange,
    required this.isNumeric,
  });

  @override
  State<AnswerChoiceWidget> createState() => _AnswerChoiceWidgetState();
}

class _AnswerChoiceWidgetState extends State<AnswerChoiceWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.question.options.isNotEmpty) {
      if (widget.question.singleChoice) {
        return SingleChoiceAnswer(onChange: widget.onChange, question: widget.question);
      } else {
        return MultipleChoiceAnswer(onChange: widget.onChange, question: widget.question);
      }
    } else {
      if (widget.question.isStarRating) {
        return RatingAnswer(key: ObjectKey(widget.question), onChange: widget.onChange, question: widget.question);
      } else {
        return SentenceAnswer(key: ObjectKey(widget.question), onChange: widget.onChange, question: widget.question, isNumeric: widget.isNumeric);
      }
    }
  }
}

// ============================================================================
// SINGLE CHOICE (Radio)
// ============================================================================

class SingleChoiceAnswer extends StatefulWidget {
  final void Function(List<Map<String, String>> answers) onChange;
  final Question question;

  const SingleChoiceAnswer({super.key, required this.onChange, required this.question});

  @override
  State<SingleChoiceAnswer> createState() => _SingleChoiceAnswerState();
}

class _SingleChoiceAnswerState extends State<SingleChoiceAnswer> {
  String? _selectedAnswer;

  @override
  void initState() {
    if (widget.question.answers.isNotEmpty) {
      _selectedAnswer = widget.question.answers.first.keys.first;
    }
    super.initState();
  }

  void _onSelect(String optionId) {
    setState(() {
      _selectedAnswer = optionId;
    });
    Option selectedOption = widget.question.options.firstWhere((o) => o.id == _selectedAnswer);
    widget.onChange([{selectedOption.id: selectedOption.text}]);
  }

  @override
  Widget build(BuildContext context) {
    // Rating numerico orizzontale
    if (widget.question.isRating && widget.question.isNumeric) {
      return _buildRatingNumeric(context);
    }
    // Opzioni standard
    return _buildStandardOptions(context);
  }

  Widget _buildRatingNumeric(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.question.options.map((option) {
        final isSelected = _selectedAnswer == option.id;
        return Expanded(
          child: GestureDetector(
            onTap: () => _onSelect(option.id),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: Sizes.padding),
              decoration: BoxDecoration(
                color: isSelected ? CLTheme.of(context).primary : CLTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
                border: Border.all(
                  color: isSelected ? CLTheme.of(context).primary : CLTheme.of(context).borderColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  option.text,
                  style: CLTheme.of(context).bodyText.copyWith(
                    color: isSelected ? Colors.white : CLTheme.of(context).primaryText,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStandardOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.question.options.map((option) {
        final isSelected = _selectedAnswer == option.id;
        return _OptionTile(
          isSelected: isSelected,
          isRadio: true,
          text: option.text,
          onTap: () => _onSelect(option.id),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// MULTIPLE CHOICE (Checkbox)
// ============================================================================

class MultipleChoiceAnswer extends StatefulWidget {
  final void Function(List<Map<String, String>> answers) onChange;
  final Question question;

  const MultipleChoiceAnswer({super.key, required this.onChange, required this.question});

  @override
  State<MultipleChoiceAnswer> createState() => _MultipleChoiceAnswerState();
}

class _MultipleChoiceAnswerState extends State<MultipleChoiceAnswer> {
  late List<Map<String, String>> _answers;

  @override
  void initState() {
    _answers = List.from(widget.question.answers);
    super.initState();
  }

  void _onToggle(Option option) {
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
      children: widget.question.options.map((option) {
        final isSelected = _answers.any((e) => e.keys.first == option.id);
        return _OptionTile(
          isSelected: isSelected,
          isRadio: false,
          text: option.text,
          onTap: () => _onToggle(option),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// OPTION TILE - Widget condiviso per Radio e Checkbox
// ============================================================================

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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: Sizes.padding / 2),
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.padding,
            vertical: Sizes.padding * 0.75,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? CLTheme.of(context).primary.withValues(alpha: 0.08)
                : _isHovered
                    ? CLTheme.of(context).primaryBackground
                    : CLTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(Sizes.borderRadius),
            border: Border.all(
              color: widget.isSelected
                  ? CLTheme.of(context).primary
                  : _isHovered
                      ? CLTheme.of(context).primary.withValues(alpha: 0.5)
                      : CLTheme.of(context).borderColor,
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Checkbox/Radio stilizzato come PagedDataTable
              widget.isRadio
                  ? _buildRadio(context)
                  : _buildCheckbox(context),
              const SizedBox(width: Sizes.padding),
              Expanded(
                child: Text(
                  widget.text,
                  style: CLTheme.of(context).bodyText.copyWith(
                    color: widget.isSelected
                        ? CLTheme.of(context).primary
                        : CLTheme.of(context).primaryText,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (widget.isSelected)
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                  size: Sizes.medium,
                  color: CLTheme.of(context).primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadio(BuildContext context) {
    return Radio<bool>(
      value: true,
      groupValue: widget.isSelected,
      activeColor: CLTheme.of(context).primary,
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return CLTheme.of(context).primary;
        }
        return CLTheme.of(context).borderColor;
      }),
      onChanged: (_) => widget.onTap(),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Checkbox(
      value: widget.isSelected,
      hoverColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all<Color>(Colors.transparent),
      activeColor: CLTheme.of(context).primary,
      checkColor: Colors.white,
      side: WidgetStateBorderSide.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.selected)
              ? CLTheme.of(context).primary
              : CLTheme.of(context).borderColor,
          width: 1,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.borderRadius / 2),
      ),
      onChanged: (_) => widget.onTap(),
    );
  }
}

// ============================================================================
// SENTENCE (Text Input)
// ============================================================================

class SentenceAnswer extends StatefulWidget {
  final void Function(List<Map<String, String>> answers) onChange;
  final Question question;
  final bool isNumeric;

  const SentenceAnswer({
    super.key,
    required this.onChange,
    required this.question,
    required this.isNumeric,
  });

  @override
  State<SentenceAnswer> createState() => _SentenceAnswerState();
}

class _SentenceAnswerState extends State<SentenceAnswer> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    if (widget.question.answers.isNotEmpty) {
      _textEditingController.text = widget.question.answers.first.values.first;
    }
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isNumeric
        ? CLTextField.number(
            controller: _textEditingController,
            labelText: "Inserisci un valore",
            onChanged: (value) async {
              widget.onChange([{"text": _textEditingController.text}]);
            },
          )
        : CLTextField(
            controller: _textEditingController,
            labelText: "Inserisci la tua risposta",
            maxLines: 3,
            onChanged: (value) async {
              widget.onChange([{"text": _textEditingController.text}]);
            },
          );
  }
}

// ============================================================================
// STAR RATING
// ============================================================================

class RatingAnswer extends StatefulWidget {
  final void Function(List<Map<String, String>> answers) onChange;
  final Question question;

  const RatingAnswer({super.key, required this.onChange, required this.question});

  @override
  State<RatingAnswer> createState() => _RatingAnswerState();
}

class _RatingAnswerState extends State<RatingAnswer> {
  Map<String, String>? _selectedAnswer;

  @override
  void initState() {
    if (widget.question.answers.isNotEmpty) {
      _selectedAnswer = widget.question.answers.first;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final rating = _selectedAnswer == null
        ? 0.0
        : (double.tryParse(_selectedAnswer!.values.first) ?? 0);

    return Container(
      padding: const EdgeInsets.all(Sizes.padding),
      decoration: BoxDecoration(
        color: CLTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(Sizes.borderRadius),
      ),
      child: Column(
        children: [
          StarRating(
            mainAxisAlignment: MainAxisAlignment.center,
            length: 5,
            rating: rating,
            between: 12,
            starSize: 40,
            color: CLTheme.of(context).primary,
            onRaitingTap: (newRating) {
              setState(() {
                _selectedAnswer = {"": newRating.toString()};
              });
              widget.onChange([_selectedAnswer!]);
            },
          ),
          if (_selectedAnswer != null) ...[
            const SizedBox(height: Sizes.padding),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.padding,
                vertical: Sizes.padding / 2,
              ),
              decoration: BoxDecoration(
                color: CLTheme.of(context).primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Sizes.borderRadius),
              ),
              child: Text(
                "${_selectedAnswer!.values.first}/5 stelle",
                style: CLTheme.of(context).bodyText.copyWith(
                  color: CLTheme.of(context).primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
