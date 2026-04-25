import 'package:flutter/material.dart';

import '../../cl_theme.dart';
import '../../layout/constants/sizes.constant.dart';
import '_dialog_chrome.dart';

/// A generic modal for selecting one or many entities of type [T] from a
/// searchable list.
///
/// Provide [available] entities, the currently [initialSelected] subset and
/// a [labelBuilder] (optionally [subtitleBuilder]) to render each row. The
/// [onConfirm] callback receives the final selection.
///
/// When [multiSelect] is `false`, picking an entity replaces the previous
/// selection.
class AssignEntitiesModal<T> extends StatefulWidget {
  /// Title shown in the dialog header.
  final String title;

  /// Full list of entities the user can pick from.
  final List<T> available;

  /// Entities pre-selected when the dialog opens.
  final List<T> initialSelected;

  /// Builds the primary label for an entity row.
  final String Function(T) labelBuilder;

  /// Optional builder for the secondary label (subtitle) of an entity row.
  final String? Function(T)? subtitleBuilder;

  /// Invoked with the final selection when the user confirms.
  final void Function(List<T>) onConfirm;

  /// Whether multiple entities can be selected simultaneously.
  final bool multiSelect;

  /// Creates an [AssignEntitiesModal].
  const AssignEntitiesModal({
    super.key,
    required this.title,
    required this.available,
    required this.initialSelected,
    required this.labelBuilder,
    required this.onConfirm,
    this.subtitleBuilder,
    this.multiSelect = true,
  });

  @override
  State<AssignEntitiesModal<T>> createState() => _AssignEntitiesModalState<T>();
}

class _AssignEntitiesModalState<T> extends State<AssignEntitiesModal<T>> {
  late Set<T> _selected;
  String _query = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String _initials(String label) {
    final parts = label.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    final filtered = widget.available
        .where((e) => widget
            .labelBuilder(e)
            .toLowerCase()
            .contains(_query.toLowerCase()))
        .toList();

    return DialogShell(
      maxWidth: 540,
      child: SizedBox(
        height: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeader(
              title: widget.title,
              subtitle: widget.multiSelect
                  ? 'Seleziona uno o più elementi'
                  : 'Seleziona un elemento',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selected.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(right: CLSizes.gapSm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: CLSizes.gapMd,
                        vertical: CLSizes.gapXs,
                      ),
                      decoration: BoxDecoration(
                        color: cl.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(CLSizes.radiusPill),
                        border: Border.all(
                          color: cl.primary.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${_selected.length} selezionati',
                        style: cl.smallLabel.copyWith(
                          color: cl.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  DialogCloseButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CLSizes.gap2Xl),
              child: _SearchField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: (v) => setState(() => _query = v),
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                  _searchFocus.requestFocus();
                },
                hasQuery: _query.isNotEmpty,
              ),
            ),
            const SizedBox(height: CLSizes.gapMd),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(query: _query)
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CLSizes.gapLg,
                      ),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: CLSizes.gapXs),
                        itemBuilder: (context, i) {
                          final entity = filtered[i];
                          final selected = _selected.contains(entity);
                          final label = widget.labelBuilder(entity);
                          final sub = widget.subtitleBuilder?.call(entity);
                          return _EntityRow(
                            label: label,
                            subtitle: sub,
                            initials: _initials(label),
                            selected: selected,
                            multiSelect: widget.multiSelect,
                            onTap: () => setState(() {
                              if (selected) {
                                _selected.remove(entity);
                              } else {
                                if (!widget.multiSelect) _selected.clear();
                                _selected.add(entity);
                              }
                            }),
                          );
                        },
                      ),
                    ),
            ),
            DialogFooter(
              actions: [
                CLDialogButton(
                  label: 'Annulla',
                  tone: CLDialogButtonTone.ghost,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CLDialogButton(
                  label: _selected.isEmpty
                      ? 'Assegna'
                      : 'Assegna (${_selected.length})',
                  tone: CLDialogButtonTone.primary,
                  icon: Icons.check_rounded,
                  autofocus: true,
                  onPressed: _selected.isEmpty && widget.multiSelect
                      ? null
                      : () {
                          widget.onConfirm(_selected.toList());
                          Navigator.of(context).pop();
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasQuery;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.hasQuery,
  });

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    return Container(
      height: CLSizes.inputHeight,
      decoration: BoxDecoration(
        color: cl.muted,
        borderRadius: BorderRadius.circular(CLSizes.radiusControl),
        border: Border.all(color: cl.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CLSizes.gapMd),
            child: Icon(
              Icons.search_rounded,
              size: CLSizes.iconSizeDefault,
              color: cl.mutedForeground,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              autofocus: true,
              style: cl.bodyText.copyWith(color: cl.primaryText),
              cursorColor: cl.primary,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Cerca...',
                hintStyle: cl.bodyText.copyWith(color: cl.mutedForeground),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (hasQuery)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: CLSizes.iconSizeCompact,
                color: cl.mutedForeground,
              ),
              splashRadius: 16,
              onPressed: onClear,
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CLSizes.gapMd),
              child: _ShortcutHint(),
            ),
        ],
      ),
    );
  }
}

class _ShortcutHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cl.secondaryBackground,
        borderRadius: BorderRadius.circular(CLSizes.radiusChip),
        border: Border.all(color: cl.borderColor, width: 1),
      ),
      child: Text(
        '⌘K',
        style: cl.smallLabel.copyWith(
          color: cl.mutedForeground,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EntityRow extends StatefulWidget {
  final String label;
  final String? subtitle;
  final String initials;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  const _EntityRow({
    required this.label,
    required this.subtitle,
    required this.initials,
    required this.selected,
    required this.multiSelect,
    required this.onTap,
  });

  @override
  State<_EntityRow> createState() => _EntityRowState();
}

class _EntityRowState extends State<_EntityRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    final tint = cl.generateColorFromText(widget.label);

    final bg = widget.selected
        ? cl.primary.withValues(alpha: 0.08)
        : (_hover ? cl.muted : Colors.transparent);

    final borderColor = widget.selected
        ? cl.primary.withValues(alpha: 0.30)
        : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: CLSizes.gapMd,
            vertical: CLSizes.gapMd,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(CLSizes.radiusControl),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: CLSizes.avatarSizeMedium,
                height: CLSizes.avatarSizeMedium,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tint.withValues(alpha: 0.85),
                      tint.withValues(alpha: 0.55),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.initials,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: CLSizes.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: cl.bodyText.copyWith(
                        color: cl.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: cl.smallLabel.copyWith(color: cl.mutedForeground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: CLSizes.gapMd),
              _SelectionIndicator(
                selected: widget.selected,
                multiSelect: widget.multiSelect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool selected;
  final bool multiSelect;
  const _SelectionIndicator({required this.selected, required this.multiSelect});

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    if (multiSelect) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: selected ? cl.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? cl.primary : cl.borderColor.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: selected
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
            : null,
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? cl.primary : cl.borderColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cl.primary,
              ),
            )
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final cl = CLTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CLSizes.gap2Xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cl.muted,
                border: Border.all(color: cl.borderColor, width: 1),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 28,
                color: cl.mutedForeground,
              ),
            ),
            const SizedBox(height: CLSizes.gapLg),
            Text(
              query.isEmpty ? 'Nessun elemento disponibile' : 'Nessun risultato',
              style: cl.heading5.copyWith(color: cl.primaryText),
            ),
            if (query.isNotEmpty) ...[
              const SizedBox(height: CLSizes.gapXs),
              Text(
                'Nessuna corrispondenza per "$query"',
                style: cl.smallLabel.copyWith(color: cl.mutedForeground),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

