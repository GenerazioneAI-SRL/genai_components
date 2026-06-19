import 'package:flutter/widgets.dart';

/// Slot generici che una pagina pubblica verso lo shell. Lo shell li RICOLLOCA
/// per breakpoint (header desktop/tablet, header compatto + bottom mobile) ma
/// NON conosce il dominio: un sort/filtro è solo una [ShellAction] con icona e
/// `onTap` che chiama il controller della pagina. Niente tipi di dominio qui →
/// lo shell resta un layout primitive riusabile in altri progetti.
///
/// Binding sempre per RIFERIMENTO al controller della pagina (closure / oggetti
/// plain), mai widget vivi: così i controlli costruiti dallo shell funzionano
/// pur essendo, nell'albero, sopra la pagina (nessun `context.read` rotto).
@immutable
class ShellAction {
  const ShellAction({
    required this.icon,
    this.label,
    required this.onTap,
    this.tooltip,
    this.isPrimary = false,
    this.enabled = true,
  });

  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final String? tooltip;

  /// Azione primaria (es. "+ Aggiungi") → resa come pulsante con testo.
  final bool isPrimary;
  final bool enabled;
}

/// Voce di breadcrumb. `onTap == null` → voce corrente (non navigabile).
@immutable
class ShellCrumb {
  const ShellCrumb(this.label, {this.onTap});
  final String label;
  final VoidCallback? onTap;
}

/// Intento "indietro": presente solo se la pagina può tornare indietro
/// (es. un dettaglio). `null` negli elenchi root.
@immutable
class ShellBack {
  const ShellBack({required this.onTap, this.tooltip});
  final VoidCallback onTap;
  final String? tooltip;
}

/// Campo ricerca generico. Il controller è POSSEDUTO dalla pagina e passato per
/// riferimento.
@immutable
class ShellSearch {
  const ShellSearch({required this.controller, this.hint, this.onChanged});
  final TextEditingController controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
}

/// Escape hatch per controlli non standard (es. stepper mesi di un calendario).
/// Il builder DEVE catturare i controller per riferimento, NON via
/// `context.read` (verrebbe costruito sotto lo shell, antenato sbagliato).
@immutable
class ShellCustom {
  const ShellCustom(this.builder, {this.id});
  final WidgetBuilder builder;
  final String? id;
}

/// Controllo contestuale legato al controller della pagina. Union GENERICA:
/// bottone / ricerca / custom. Su desktop+tablet la pagina tiene i propri
/// controlli inline; lo shell usa questi solo dove il design li ricolloca
/// (riga alta del bottom mobile).
@immutable
class ShellContextControl {
  const ShellContextControl.action(ShellAction this.action)
      : search = null,
        custom = null;
  const ShellContextControl.search(ShellSearch this.search)
      : action = null,
        custom = null;
  const ShellContextControl.custom(ShellCustom this.custom)
      : action = null,
        search = null;

  final ShellAction? action;
  final ShellSearch? search;
  final ShellCustom? custom;
}

/// Insieme degli slot pubblicati da una pagina.
@immutable
class ShellSlots {
  const ShellSlots({
    this.back,
    this.breadcrumbs = const [],
    this.pageActions = const [],
    this.contextControls = const [],
  });

  final ShellBack? back;
  final List<ShellCrumb> breadcrumbs;
  final List<ShellAction> pageActions;
  final List<ShellContextControl> contextControls;

  bool get isEmpty =>
      back == null &&
      breadcrumbs.isEmpty &&
      pageActions.isEmpty &&
      contextControls.isEmpty;

  static const ShellSlots empty = ShellSlots();
}

/// Stato dei slot. La pagina chiama [setSlots] (in `didChangeDependencies` o
/// post-frame) e [clear] in `dispose`. Lo shell ascolta e ricostruisce header /
/// bottom. È un `ChangeNotifier` puro: zero dipendenza dall'app.
class ShellSlotsController extends ChangeNotifier {
  ShellSlots _slots = ShellSlots.empty;
  ShellSlots get slots => _slots;

  void setSlots(ShellSlots slots) {
    _slots = slots;
    notifyListeners();
  }

  void clear() {
    if (_slots.isEmpty) return;
    _slots = ShellSlots.empty;
    notifyListeners();
  }
}

/// Espone il [ShellSlotsController] alle pagine discendenti. Lookup NON
/// sottoscrivente: la pagina che pubblica non si ricostruisce quando i slot
/// cambiano (è lo shell ad ascoltare il controller).
class CLShellScope extends InheritedNotifier<ShellSlotsController> {
  const CLShellScope({
    super.key,
    required ShellSlotsController controller,
    required super.child,
  }) : super(notifier: controller);

  static ShellSlotsController? maybeOf(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<CLShellScope>();
    return (element?.widget as CLShellScope?)?.notifier;
  }

  static ShellSlotsController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null,
        'CLShellScope non trovato: CLAdaptiveShell non è un antenato di questa pagina.');
    return controller!;
  }
}
