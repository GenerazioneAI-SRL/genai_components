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
    this.icon,
    this.label,
    this.onTap,
    this.tooltip,
    this.isPrimary = false,
    this.enabled = true,
    this.builder,
  });

  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;
  final String? tooltip;

  /// Azione primaria (es. "+ Aggiungi") → resa come pulsante con testo.
  final bool isPrimary;
  final bool enabled;

  /// Escape hatch: se presente, lo shell rende questo widget invece del bottone
  /// generico. Serve a preservare azioni con logica propria (es.
  /// `PageAction.toWidget` con conferme/colori) senza che lo shell le conosca.
  final WidgetBuilder? builder;
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

/// Controllo che, su mobile, NON apre un overlay esterno ma RIVELA il proprio
/// contenuto inline nell'area contestuale (le righe di controlli collassano e
/// al loro posto compare [panelBuilder]). Toggle: ritap chiude. Lo shell tiene
/// lo stato di apertura (per [id]); il `close` passato chiude il pannello.
@immutable
class ShellRevealControl {
  const ShellRevealControl({
    required this.id,
    required this.icon,
    required this.title,
    required this.panelBuilder,
    this.tooltip,
    this.badgeCount,
  });

  /// Identità stabile del pannello: lo shell la usa per sapere quale è aperto e
  /// per richiuderlo da solo quando la pagina cambia i propri controlli.
  final String id;
  final IconData icon;

  /// Titolo mostrato nell'header del pannello inline.
  final String title;

  /// Contenuto inline. `close` richiude il pannello (es. dopo "Applica").
  final Widget Function(BuildContext context, VoidCallback close) panelBuilder;
  final String? tooltip;

  /// Badge numerico opzionale sul bottone (es. filtri attivi).
  final int? badgeCount;
}

/// Controllo contestuale legato al controller della pagina. Union GENERICA:
/// bottone / ricerca / custom / reveal. Su desktop+tablet la pagina tiene i
/// propri controlli inline; lo shell usa questi solo dove il design li ricolloca
/// (riga alta del bottom mobile).
@immutable
class ShellContextControl {
  const ShellContextControl.action(ShellAction this.action)
      : search = null,
        custom = null,
        reveal = null;
  const ShellContextControl.search(ShellSearch this.search)
      : action = null,
        custom = null,
        reveal = null;
  const ShellContextControl.custom(ShellCustom this.custom)
      : action = null,
        search = null,
        reveal = null;
  const ShellContextControl.reveal(ShellRevealControl this.reveal)
      : action = null,
        search = null,
        custom = null;

  final ShellAction? action;
  final ShellSearch? search;
  final ShellCustom? custom;
  final ShellRevealControl? reveal;
}

/// Insieme degli slot pubblicati da una pagina.
@immutable
class ShellSlots {
  const ShellSlots({
    this.back,
    this.breadcrumbs = const [],
    this.pageActions = const [],
    this.contextControls = const [],
    this.contextOverflow,
  });

  final ShellBack? back;
  final List<ShellCrumb> breadcrumbs;
  final List<ShellAction> pageActions;
  final List<ShellContextControl> contextControls;

  /// "Altre azioni" della pagina/tabella, in coda alla riga bassa del bottom
  /// mobile (a destra, dopo back + pageActions). Reveal: tap → lista inline.
  /// `null` se la pagina non espone un overflow.
  final ShellRevealControl? contextOverflow;

  bool get isEmpty =>
      back == null &&
      breadcrumbs.isEmpty &&
      pageActions.isEmpty &&
      contextControls.isEmpty &&
      contextOverflow == null;

  static const ShellSlots empty = ShellSlots();
}

/// Stato dei slot, su DUE canali indipendenti che lo shell unisce:
///  - canale **nav** (back + breadcrumbs): pubblicato in modo centrale (un
///    bridge che legge lo stato di navigazione), non dalle singole pagine.
///  - canale **page** (pageActions + contextControls): pubblicato dalla pagina
///    corrente in `initState`/post-frame, ripulito in `dispose`.
/// Due canali separati = nessun overwrite tra publisher diversi.
/// `ChangeNotifier` puro: zero dipendenza dall'app.
class ShellSlotsController extends ChangeNotifier {
  ShellBack? _back;
  List<ShellCrumb> _breadcrumbs = const [];
  List<ShellAction> _pageActions = const [];
  List<ShellContextControl> _contextControls = const [];
  ShellRevealControl? _contextOverflow;

  ShellSlots get slots => ShellSlots(
        back: _back,
        breadcrumbs: _breadcrumbs,
        pageActions: _pageActions,
        contextControls: _contextControls,
        contextOverflow: _contextOverflow,
      );

  /// Canale navigazione (centrale). Aggiorna back + breadcrumbs.
  void setNav({ShellBack? back, List<ShellCrumb> breadcrumbs = const []}) {
    _back = back;
    _breadcrumbs = breadcrumbs;
    notifyListeners();
  }

  /// Canale page — azioni primarie della pagina (pubblicate dalla pagina).
  void setPageActions(List<ShellAction> pageActions) {
    _pageActions = pageActions;
    notifyListeners();
  }

  /// Canale page — controlli contestuali (pubblicati da chi li possiede, es. la
  /// tabella). Separato da [setPageActions] così i due publisher non si
  /// sovrascrivono a vicenda.
  void setContextControls(List<ShellContextControl> controls, {ShellRevealControl? overflow}) {
    _contextControls = controls;
    _contextOverflow = overflow;
    notifyListeners();
  }

  /// Azzera l'intero canale page (azioni + controlli). Da chiamare al cambio
  /// rotta / dispose pagina.
  void clearPage() {
    _pageActions = const [];
    _contextControls = const [];
    _contextOverflow = null;
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
