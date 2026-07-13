import 'package:flutter/widgets.dart';

import '../theme/gen_tokens.dart';

/// Opzione di un [GenSegmented]: valore + etichetta (di solito un `Text`).
@immutable
class GenSegmentedOption<T> {
  const GenSegmentedOption({required this.value, required this.label});

  final T value;
  final Widget label;
}

/// Controllo segmentato (toggle group a selezione singola). shadcn_ui non
/// fornisce un segmented control, quindi è un widget custom Gen: box bordato +
/// riga di opzioni; la selezionata ha sfondo pieno e testo in grassetto. Gli
/// angoli tondi del fill sono SOLO agli estremi (primo/ultimo); i centrali sono
/// squadrati. Stile interamente da token ([GenTokens]).
class GenSegmented<T> extends StatelessWidget {
  const GenSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.height = 36,
  });

  final List<GenSegmentedOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    final outer = BorderRadius.circular(t.radiusControl);
    final r = Radius.circular(t.radiusControl - 2);
    final n = options.length;

    BorderRadius fillRadius(int i) {
      if (n == 1) return BorderRadius.all(r);
      if (i == 0) return BorderRadius.only(topLeft: r, bottomLeft: r);
      if (i == n - 1) return BorderRadius.only(topRight: r, bottomRight: r);
      return BorderRadius.zero;
    }

    return Container(
      decoration: BoxDecoration(border: Border.all(color: t.borderColor), borderRadius: outer),
      child: Row(
        children: [
          for (var i = 0; i < n; i++) ...[
            if (i > 0) SizedBox(width: 1, height: height - 2, child: ColoredBox(color: t.borderColor)),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(options[i].value),
                child: Container(
                  height: height,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: options[i].value == value ? t.muted : null,
                    borderRadius: fillRadius(i),
                  ),
                  child: DefaultTextStyle.merge(
                    style: t.bodyLabel.copyWith(
                      color: t.primaryText,
                      fontWeight: options[i].value == value ? FontWeight.w600 : FontWeight.w400,
                    ),
                    child: options[i].label,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
