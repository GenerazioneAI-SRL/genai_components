/// Design tokens del DS Skillera.
///
/// Scala derivata per un admin tool professionale (HR / giuridico / presenze):
/// griglia 4, spaziature on-grid, radii leggermente più morbidi di shadcn per
/// bilanciare la densità dei dati con un tono umanista (Inter + Satoshi).
///
/// I nomi canonici (`gap*`, `page*`, `radius*`) sono intent-revealing: scegli
/// il token in base all'uso, non al valore numerico. I nomi storici (sm, small,
/// borderRadius, padding, ...) sono mantenuti come alias puri — stesso valore,
/// nessun warning — per non rompere codice esistente o consumer del package.
class CLSizes {
  // ═══════════════════════════════════════════════════════════
  // SPAZIATURE (griglia 4)
  // ═══════════════════════════════════════════════════════════

  /// 4px — gap atomico.
  /// Usato per: separazione icona↔pallino stato, stack molto serrati dentro chip,
  /// distanza verticale tra label micro e valore in badge.
  static const gapXs = 4.0;

  /// 8px — gap denso.
  /// Usato per: padding interno chip/badge, gap tra colonne di tabella dense,
  /// spaziatura voci in liste compatte, distanza tra avatar e label in row.
  static const gapSm = 8.0;

  /// 12px — gap medio.
  /// Usato per: gap verticale tra campi form vicini, padding interno di card
  /// dense, spaziatura tra sub-voci in un menu.
  static const gapMd = 12.0;

  /// 16px — gap standard.
  /// Usato per: padding interno di card piccole, gap tra widget sulla stessa
  /// sezione, distanza icona↔label nei bottoni, size icone compatte.
  static const gapLg = 16.0;

  /// 20px — gap generoso.
  /// Usato per: padding interno di card/pannelli, spazio tra header di sezione
  /// e contenuto, size icone desktop.
  static const gapXl = 20.0;

  /// 24px — separatore tra blocchi.
  /// Usato per: gap tra sezioni adiacenti di pagina, margine tra gruppi
  /// semanticamente distinti (es. "dati anagrafici" ↔ "dati contrattuali").
  static const gap2Xl = 24.0;

  /// 32px — ritmo di pagina.
  /// Usato per: spazio verticale tra blocchi maggiori di pagina (es. header
  /// + prima card, ultima card + footer).
  static const gap3Xl = 32.0;

  /// 48px — respiro di pagina.
  /// Usato per: margine superiore/inferiore di hero, spazio d'inizio e fine
  /// delle pagine di landing / dashboard principali.
  static const gap4Xl = 48.0;

  // ═══════════════════════════════════════════════════════════
  // PADDING E OFFSET DI PAGINA
  // ═══════════════════════════════════════════════════════════

  /// 20px — padding orizzontale delle pagine.
  /// Usato per: `SliverPadding` delle pagine shell, contenuto principale sotto
  /// il layout desktop/mobile. Valore on-grid (prima 18: fuori-griglia).
  static const pagePadX = 20.0;

  /// 80px — offset top per contenuto scrollabile.
  /// Usato per: distanza dal bordo superiore quando la pagina ha un header
  /// fisso (+ page-name container = ~135px totali).
  static const pageTop = 80.0;

  // ═══════════════════════════════════════════════════════════
  // RADIUS (scala "soft-pro": +2 rispetto a shadcn sui controlli)
  // ═══════════════════════════════════════════════════════════

  /// 4px — chip, badge, tag densi.
  /// Usato per: status badge, tag di filtri, pill di conteggio,
  /// celle di tabella con sfondo tinto.
  static const radiusChip = 4.0;

  /// 8px — controlli interattivi.
  /// Usato per: `CLButton` e varianti (filled/outline/ghost/soft), `CLTextField`,
  /// `CLDropdown`, `CLDatePicker`. Scelta +2 rispetto allo shadcn 6 per smussare
  /// il tono tecnico: l'app è d'uso quotidiano, i controlli devono sembrare
  /// "amichevoli".
  static const radiusControl = 8.0;

  /// 10px — surface secondarie.
  /// Usato per: popover, tooltip, menu contestuali, dropdown flottanti,
  /// container secondari dentro card.
  static const radiusSurface = 10.0;

  /// 14px — card e pannelli.
  /// Usato per: `CLSectionCard`, card del dashboard, pannelli di sezione,
  /// `CLPageHeader`. Abbastanza morbido da dare sensazione di "contenitore"
  /// e non di "finestra tecnica".
  static const radiusCard = 14.0;

  /// 20px — superfici modali.
  /// Usato per: dialog, bottom sheet, drawer su mobile, overlay con azioni
  /// complete. Il raggio più grande sottolinea la natura "flottante".
  static const radiusModal = 20.0;

  /// 9999px — pill.
  /// Usato per: badge con testo (conteggio, status testuale), bottoni pill
  /// dell'header, switch di filtri.
  static const radiusPill = 9999.0;

  // ═══════════════════════════════════════════════════════════
  // ALIAS — naming storico del DS
  // Stesso tipo di uso, nessun warning. Valori riallineati alla nuova scala
  // (es. borderRadius passa da 6 → 8 per coerenza col radiusControl).
  // ═══════════════════════════════════════════════════════════

  static const sm = gapSm; //  8
  static const small = gapLg; // 16
  static const medium = gapXl; // 20
  static const large = gap2Xl; // 24
  static const padding = pagePadX; // 20 (era 18)
  static const headerOffset = pageTop; // 80

  static const radiusSm = radiusChip; //  4
  static const borderRadius = radiusControl; // 8 (era 6)
  static const radiusLg = radiusSurface; // 10 (era 8)

  // Duplicati storici: stesso valore di un altro alias.
  static const md = gapLg; // 16
  static const lg = gap2Xl; // 24
  static const verticalPadding = gapLg; // 16

  // ═══════════════════════════════════════════════════════════
  // Valori esposti dal package ma non usati dai widget interni
  // (retrocompat per consumer esterni).
  // ═══════════════════════════════════════════════════════════

  static const xl = 32.0;
  static const xxl = 40.0;
  static const xxxl = 48.0;

  /// Valore di opacity generico (retaggio: non è una dimensione).
  static const opacity = 0.2;
}

/// Retrocompatibilità: il vecchio nome [Sizes] resta disponibile come alias.
typedef Sizes = CLSizes;
