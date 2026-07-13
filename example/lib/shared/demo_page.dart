import 'package:flutter/widgets.dart';
import 'package:genai_components/gen/gen.dart';

/// Scaffold di una pagina demo scrollabile. Legge il [MediaQuery.paddingOf] alla
/// posizione MONTATA (sotto l'inset iniettato dallo shell) via [Builder] — così
/// il contenuto sta sotto l'header senza magic value.
class DemoPage extends StatelessWidget {
  const DemoPage({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Builder(
        builder: (context) => SingleChildScrollView(
          // Inset iniettato dallo shell: clearance header (top) + gutter (horizontal),
          // bottom 0. Nessun respiro verticale da parte dello shell.
          padding: MediaQuery.paddingOf(context),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      );
}

/// Gruppo etichettato di widget demo (titolo + descrizione opzionale + wrap).
class DemoGroup extends StatelessWidget {
  const DemoGroup({super.key, required this.title, required this.items, this.description, this.spacing = 16, this.runSpacing = 16});

  final String title;
  final String? description;
  final List<Widget> items;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: t.heading4),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(description!, style: t.smallText.copyWith(color: t.secondaryText)),
        ],
        const SizedBox(height: 14),
        Wrap(spacing: spacing, runSpacing: runSpacing, crossAxisAlignment: WrapCrossAlignment.start, children: items),
        const SizedBox(height: 32),
      ],
    );
  }
}

/// Singolo esempio annotato: caption piccola + widget sotto. Usato dentro
/// [DemoGroup.items] per mostrare una specifica opzione/variante di un widget.
class DemoTile extends StatelessWidget {
  const DemoTile({super.key, required this.label, required this.child, this.width});

  final String label;
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final t = GenTokens.of(context);
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.smallLabel.copyWith(color: t.secondaryText)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
