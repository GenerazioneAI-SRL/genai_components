import 'package:flutter/scheduler.dart';
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
    this.mobileOnly = false,
  });

  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;
  final String? tooltip;

  /// Azione primaria (es. "+ Aggiungi") → resa come pulsante con testo.
  final bool isPrimary;
  final bool enabled;

  /// Se `true`, l'azione è resa SOLO nell'area contestuale mobile (riga bassa,
  /// full-width) e MAI nell'header desktop/rail. Per pagine che su desktop hanno
  /// già un proprio controllo inline (es. la toolbar del calendario) e vogliono
  /// solo l'hoisting su mobile — evita il doppione e l'overflow dell'header.
  final bool mobileOnly;

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
    this.selectionBar,
  });

  final ShellBack? back;
  final List<ShellCrumb> breadcrumbs;
  final List<ShellAction> pageActions;
  final List<ShellContextControl> contextControls;

  /// "Altre azioni" della pagina/tabella, in coda alla riga bassa del bottom
  /// mobile (a destra, dopo back + pageActions). Reveal: tap → lista inline.
  /// `null` se la pagina non espone un overflow.
  final ShellRevealControl? contextOverflow;

  /// Barra azioni bulk (selezione tabella) pubblicata dalla tabella su mobile.
  /// Quando NON null, il bottom contestuale mostra SOLO questa (sostituisce
  /// controlli + pageActions): le azioni sulla selezione hanno priorità.
  final Widget? selectionBar;

  bool get isEmpty => back == null && breadcrumbs.isEmpty && pageActions.isEmpty && contextControls.isEmpty && contextOverflow == null && selectionBar == null;

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
  Widget? _selectionBar;

  ShellSlots get slots => ShellSlots(
        back: _back,
        breadcrumbs: _breadcrumbs,
        pageActions: _pageActions,
        contextControls: _contextControls,
        contextOverflow: _contextOverflow,
        selectionBar: _selectionBar,
      );

  // ── Azioni shell (drawer / AI) ──────────────────────────────────────────
  // Bound dallo shell (ha il GlobalKey dello Scaffold). Permettono all'app di
  // pilotare apertura menu/AI da widget costruiti SOPRA lo shell (es. le voci
  // custom della bottom bar) senza accedere al contesto interno dello shell.
  VoidCallback? _openMenu;
  VoidCallback? _openAi;

  /// Chiamato dallo shell in build per collegare le azioni allo Scaffold interno.
  void bindShellActions({VoidCallback? openMenu, VoidCallback? openAi}) {
    _openMenu = openMenu;
    _openAi = openAi;
  }

  /// Apre il drawer menu (no-op se nessuno Scaffold con drawer è montato).
  void openMenu() => _openMenu?.call();

  /// Apre l'endDrawer AI (no-op se non disponibile).
  void openAi() => _openAi?.call();

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

  /// Canale page — barra azioni bulk (selezione tabella). `null` = nessuna
  /// selezione attiva. Quando settata, il bottom mostra solo questa (priorità).
  void setSelectionBar(Widget? bar) {
    if (identical(_selectionBar, bar)) return;
    _selectionBar = bar;
    _notifySafely();
  }

  /// Azzera l'intero canale page (azioni + controlli). Da chiamare al cambio
  /// rotta / dispose pagina.
  void clearPage() {
    _pageActions = const [];
    _contextControls = const [];
    _contextOverflow = null;
    _selectionBar = null;
    _notifySafely();
  }

  /// Notifica i listener in modo sicuro rispetto alla fase del frame. Quando
  /// `clearPage()` viene chiamato dal `dispose()` di una pagina, il framework è
  /// in fase di build/unmount (tree locked): notificare in sincrono fa esplodere
  /// l'`AnimatedBuilder` dello shell con "setState() called when widget tree was
  /// locked". In quel caso si difende il notify al post-frame.
  void _notifySafely() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks || phase == SchedulerPhase.midFrameMicrotasks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Espone il [ShellSlotsController] alle pagine discendenti. Lookup NON
/// sottoscrivente: la pagina che pubblica non si ricostruisce quando i slot
/// cambiano (è lo shell ad ascoltare il controller).
class GenShellScope extends InheritedNotifier<ShellSlotsController> {
  const GenShellScope({
    super.key,
    required ShellSlotsController controller,
    required super.child,
  }) : super(notifier: controller);

  static ShellSlotsController? maybeOf(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<GenShellScope>();
    return (element?.widget as GenShellScope?)?.notifier;
  }

  static ShellSlotsController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'GenShellScope non trovato: GenAdaptiveShell non è un antenato di questa pagina.');
    return controller!;
  }
}

/// Pubblica [actions] sul canale page dello shell ([GenShellScope]) per tutta la
/// vita del widget: lo shell le ricolloca da sé (header su desktop/tablet, area
/// contestuale sopra la bottom bar su mobile). Incapsula il lifecycle che le
/// pagine altrimenti ricablano a mano — lookup dello scope, publish post-frame,
/// gate sulla rotta corrente, clear in dispose — così una pagina passa da ~15
/// righe sparse (campo + didChangeDependencies + post-frame + dispose) a un solo
/// widget nel tree:
///
/// ```dart
/// return GenShellPageActions(
///   actions: _shellActions(context, vm),
///   child: _buildLayout(context, vm),
/// );
/// ```
///
/// Trasparente al layout: ritorna [child] invariato (è solo un publisher). Le
/// [actions] vengono ri-pubblicate a ogni rebuild del parent, quindi è corretto
/// passare una lista ricostruita dal viewmodel.
///
/// [gateOnCurrentRoute] (default true): pubblica solo se il [ModalRoute] della
/// pagina è quello corrente — evita che una lista, mentre una rotta figlia è in
/// cima ma resta montata e ribuilda, sovrascriva le azioni della figlia. Mettere
/// a `false` nelle rotte foglia con GoRouter nidificato, dove [ModalRoute] di
/// questo context risolve il route del parent ([ModalRoute.isCurrent] sarebbe
/// sempre false): lì il cleanup è comunque garantito dal dispose → [clearPage].
class GenShellPageActions extends StatefulWidget {
  const GenShellPageActions({
    super.key,
    required this.actions,
    required this.child,
    this.gateOnCurrentRoute = true,
  });

  final List<ShellAction> actions;
  final Widget child;
  final bool gateOnCurrentRoute;

  @override
  State<GenShellPageActions> createState() => _GenShellPageActionsState();
}

class _GenShellPageActionsState extends State<GenShellPageActions> {
  ShellSlotsController? _shell;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lookup non sottoscrivente: pubblicare non ricostruisce questa pagina.
    _shell = GenShellScope.maybeOf(context);
    _publish();
  }

  @override
  void didUpdateWidget(covariant GenShellPageActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Il parent ribuilda con una lista ricostruita ogni volta → ri-pubblica.
    _publish();
  }

  @override
  void dispose() {
    // Cleanup centralizzato: la pagina che si smonta azzera il canale page.
    _shell?.clearPage();
    super.dispose();
  }

  void _publish() {
    final shell = _shell;
    if (shell == null) return;
    // Post-frame: setPageActions notifica in sincrono → fuori dal build lock.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.gateOnCurrentRoute && !(ModalRoute.of(context)?.isCurrent ?? true)) {
        return;
      }
      shell.setPageActions(widget.actions);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
