import 'package:flutter/material.dart';
import 'buttons/cl_ghost_button.widget.dart';
import 'cl_dropdown/cl_dropdown.dart';
import 'cl_responsive_grid/flutter_responsive_flex_grid.dart';
import 'textfield_validator.dart';
import '../cl_theme.dart';
import '../layout/constants/sizes.constant.dart';
import 'cl_text_field.widget.dart';

/// Configurazione universale per il repeatable
class RepeatableFieldConfig {
  final bool showQuantity;
  final bool showCustomPrice;
  final String quantityLabel;
  final String priceLabel;
  final double dropdownWidth;
  final bool showOriginalPrice;
  final bool quantityRequired;
  final bool priceRequired;
  final bool showInfoBox;
  final String? infoBoxText;
  final Color? infoBoxColor;
  final IconData? infoBoxIcon;
  final bool showTotalBox;
  final String? totalBoxLabel;

  const RepeatableFieldConfig({
    this.showQuantity = false,
    this.showCustomPrice = false,
    this.quantityLabel = 'Quantità',
    this.priceLabel = 'Prezzo personalizzato (opzionale)',
    this.dropdownWidth = 100,
    this.showOriginalPrice = true,
    this.quantityRequired = true,
    this.priceRequired = false,
    this.showInfoBox = false,
    this.infoBoxText,
    this.infoBoxColor,
    this.infoBoxIcon,
    this.showTotalBox = false,
    this.totalBoxLabel,
  });

  static const onlyDropdown = RepeatableFieldConfig();

  static const withQuantity = RepeatableFieldConfig(
    showQuantity: true,
    dropdownWidth: 70,
  );

  static const withPrice = RepeatableFieldConfig(
    showCustomPrice: true,
    dropdownWidth: 60,
    priceRequired: true,
    showInfoBox: true,
    infoBoxText: 'I prodotti inclusi compongono un PACCHETTO. Il prezzo finale sarà CALCOLATO AUTOMATICAMENTE dalla somma dei loro prezzi. Puoi personalizzare il prezzo di ogni prodotto.',
    infoBoxColor: Color(0xFFFFF3E0),
    infoBoxIcon: Icons.warning_amber_rounded,
    showTotalBox: true,
    totalBoxLabel: 'Prezzo Totale Calcolato:',
  );

  static const withQuantityAndPrice = RepeatableFieldConfig(
    showQuantity: true,
    showCustomPrice: true,
    dropdownWidth: 50,
    priceRequired: false,
    showTotalBox: true,
    totalBoxLabel: 'Totale:',
  );
}

class UniversalRepeatableItem<T extends Object> {
  T? selectedItem;
  TextEditingController? quantityController;
  TextEditingController? priceController;

  UniversalRepeatableItem({
    this.selectedItem,
    int? initialQuantity,
    double? initialPrice,
  }) {
    quantityController = TextEditingController(text: initialQuantity?.toString() ?? '1');
    priceController = TextEditingController(text: initialPrice?.toStringAsFixed(2) ?? '');
  }

  int get quantity => int.tryParse(quantityController?.text ?? '1') ?? 1;

  double? get customPrice {
    final text = priceController?.text ?? '';
    return text.isEmpty ? null : double.tryParse(text);
  }

  void dispose() {
    quantityController?.dispose();
    priceController?.dispose();
  }
}

class CLUniversalRepeatable<T extends Object> extends StatefulWidget {
  final String label;
  final List<UniversalRepeatableItem<T>> items;
  final VoidCallback? onChanged;
  final Future<(List<T>, dynamic)> Function({
  int? page,
  int? perPage,
  Map<String, dynamic>? searchBy,
  Map<String, dynamic>? orderBy,
  }) searchCallback;
  final String searchColumn;
  final String Function(T item) valueToShow;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final String dropdownHint;
  final RepeatableFieldConfig config;
  final double Function(T item)? getOriginalPrice;
  final String? Function(T item)? getDescription;
  final String addButtonText;
  final double Function()? calculateTotal;

  const CLUniversalRepeatable({
    super.key,
    required this.label,
    required this.items,
    required this.searchCallback,
    required this.searchColumn,
    required this.valueToShow,
    this.onChanged,
    this.itemBuilder,
    this.dropdownHint = 'Seleziona',
    this.config = RepeatableFieldConfig.onlyDropdown,
    this.getOriginalPrice,
    this.getDescription,
    this.addButtonText = 'Aggiungi',
    this.calculateTotal,
  });

  @override
  State<CLUniversalRepeatable<T>> createState() => _CLUniversalRepeatableState<T>();
}

class _CLUniversalRepeatableState<T extends Object> extends State<CLUniversalRepeatable<T>> {
  void _addItem() {
    setState(() {
      widget.items.add(UniversalRepeatableItem<T>());
      widget.onChanged?.call();
    });
  }

  void _removeItem(int index) {
    final itemToDispose = widget.items[index];
    setState(() {
      widget.items.removeAt(index);
      widget.onChanged?.call();
    });
    // Dispose dopo il rebuild per evitare "controller used after dispose"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemToDispose.dispose();
    });
  }

  double _getFieldWidth() {
    int fieldsCount = 0;
    if (widget.config.showQuantity) fieldsCount++;
    if (widget.config.showCustomPrice) fieldsCount++;
    if (fieldsCount == 0) return 0;
    return (100 - widget.config.dropdownWidth) / fieldsCount;
  }

  double _calculateDefaultTotal() {
    double total = 0.0;
    for (var item in widget.items) {
      if (item.selectedItem == null || widget.getOriginalPrice == null) continue;
      final price = widget.config.showCustomPrice
          ? (item.customPrice ?? widget.getOriginalPrice!(item.selectedItem as T))
          : widget.getOriginalPrice!(item.selectedItem as T);
      final qty = widget.config.showQuantity ? item.quantity : 1;
      total += price * qty;
    }
    return total;
  }

  bool _shouldShowTotalBox() {
    return widget.config.showTotalBox && widget.items.any((item) => item.selectedItem != null);
  }

  Widget _buildDefaultDropdownItem(BuildContext context, T item) {
    List<Widget> children = [
      Text(widget.valueToShow(item), style: const TextStyle(fontWeight: FontWeight.w600)),
    ];

    if (widget.getOriginalPrice != null) {
      final price = widget.getOriginalPrice!(item);
      children.add(
        Text(
          'Prezzo: €${price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.bodySmall?.merge(
            TextStyle(color: CLTheme.of(context).secondaryText),
          ),
        ),
      );
    }

    if (widget.getDescription != null) {
      final desc = widget.getDescription!(item);
      if (desc != null && desc.isNotEmpty) {
        children.add(
          Text(
            desc,
            style: Theme.of(context).textTheme.bodySmall?.merge(
              TextStyle(color: CLTheme.of(context).secondaryText),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.config.showInfoBox && widget.config.infoBoxText != null)
          Container(
            padding: const EdgeInsets.all(Sizes.padding),
            margin: const EdgeInsets.only(
              left: Sizes.padding,
              right: Sizes.padding,
              bottom: Sizes.padding,
            ),
            decoration: BoxDecoration(
              color: widget.config.infoBoxColor ?? CLTheme.of(context).info.withValues(alpha: CLTheme.of(context).opacitySoft),
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
              border: Border.all(
                color: widget.config.infoBoxIcon == Icons.warning_amber_rounded
                    ? CLTheme.of(context).warning.withValues(alpha: CLTheme.of(context).opacityMuted)
                    : CLTheme.of(context).info.withValues(alpha: CLTheme.of(context).opacityMuted),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.config.infoBoxIcon ?? Icons.info_outline,
                  color: widget.config.infoBoxIcon == Icons.warning_amber_rounded
                      ? CLTheme.of(context).warning
                      : CLTheme.of(context).info,
                  size: Sizes.iconSizeDefault,
                ),
                const SizedBox(width: Sizes.gapSm),
                Expanded(
                  child: Text(
                    widget.config.infoBoxText!,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.config.infoBoxIcon == Icons.warning_amber_rounded
                          ? Colors.orange.shade900
                          : Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Sizes.padding, Sizes.padding, 0, 0),
          child: Text(widget.label, style: CLTheme.of(context).bodyLabel),
        ),
        ListView.builder(
          itemCount: widget.items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final fieldWidth = _getFieldWidth();

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.padding,
                vertical: Sizes.padding / 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ResponsiveGrid(
                      gridSpacing: Sizes.padding,
                      children: [
                        ResponsiveGridItem(
                          lg: widget.config.dropdownWidth,
                          xs: 100,
                          child: CLDropdown<T>.singleAsync(
                            searchCallback: widget.searchCallback,
                            searchColumn: widget.searchColumn,
                            valueToShow: widget.valueToShow,
                            selectedValues: item.selectedItem,
                            validators: [Validators.required],
                            onSelectItem: (selectedItem) {
                              item.selectedItem = selectedItem;
                              if (widget.config.showCustomPrice &&
                                  selectedItem != null &&
                                  widget.getOriginalPrice != null) {
                                item.priceController!.text =
                                    widget.getOriginalPrice!(selectedItem).toStringAsFixed(2);
                              }
                              widget.onChanged?.call();
                            },
                            hint: widget.dropdownHint,
                            itemBuilder: widget.itemBuilder ??
                                    (ctx, dropdownItem) => _buildDefaultDropdownItem(ctx, dropdownItem),
                          ),
                        ),
                        if (widget.config.showQuantity)
                          ResponsiveGridItem(
                            lg: fieldWidth,
                            xs: 100,
                            child: CLTextField(
                              controller: item.quantityController!,
                              labelText: widget.config.quantityLabel,
                              inputType: TextInputType.number,
                              onChanged: (_) async => widget.onChanged?.call(),
                              validators: widget.config.quantityRequired
                                  ? [
                                Validators.required,
                                    (value) {
                                  final intValue = int.tryParse(value ?? '');
                                  if (intValue == null || intValue < 1) {
                                    return 'Min 1';
                                  }
                                  return null;
                                },
                              ]
                                  : null,
                            ),
                          ),
                        if (widget.config.showCustomPrice)
                          ResponsiveGridItem(
                            lg: fieldWidth,
                            xs: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CLTextField.currency(
                                  controller: item.priceController!,
                                  labelText: widget.config.priceLabel,
                                  onChanged: (_) async => widget.onChanged?.call(),
                                  validators: widget.config.priceRequired
                                      ? [Validators.required]
                                      : null,
                                ),
                                if (widget.config.showOriginalPrice &&
                                    item.selectedItem != null &&
                                    widget.getOriginalPrice != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Prezzo originale: €${widget.getOriginalPrice!(item.selectedItem as T).toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.bodySmall?.merge(
                                        TextStyle(color: CLTheme.of(context).secondaryText),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Sizes.padding / 2),
                  CLGhostButton.danger(
                    onTap: () => _removeItem(index),
                    text: '',
                    context: context,
                    icon: Icons.remove_circle,
                  ),
                ],
              ),
            );
          },
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Sizes.padding / 2),
            child: CLGhostButton.info(
              onTap: _addItem,
              text: widget.addButtonText,
              context: context,
              icon: Icons.add,
            ),
          ),
        ),
        if (_shouldShowTotalBox())
          Container(
            margin: const EdgeInsets.only(
              left: Sizes.padding,
              right: Sizes.padding,
              top: Sizes.padding,
            ),
            padding: const EdgeInsets.all(Sizes.padding),
            decoration: BoxDecoration(
              color: CLTheme.of(context).success.withValues(alpha: CLTheme.of(context).opacitySoft),
              borderRadius: BorderRadius.circular(Sizes.borderRadius),
              border: Border.all(
                color: CLTheme.of(context).success.withValues(alpha: CLTheme.of(context).opacityMuted),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.config.totalBoxLabel ?? 'Totale:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                Text(
                  '€${(widget.calculateTotal?.call() ?? _calculateDefaultTotal()).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
