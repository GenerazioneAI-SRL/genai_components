# Resizable Nav Header — Design

## Problema

La sidebar espansa mostra in cima la bolla `navHeader` (azienda + voci
"Gestione cliente") come **barra frosted fissa**; le voci nav normali
(`GenNavList`) scrollano sotto. Quando le voci cliente crescono, la barra fissa
si mangia lo spazio verticale e non è regolabile: l'utente non può bilanciare lo
spazio tra voci cliente e voci normali.

## Obiettivo

Dare all'utente una **maniglia di resize sul bordo basso della bolla header**:
trascinando cambia l'altezza dell'header (con le voci cliente che scrollano
dentro); le voci nav normali sotto prendono lo spazio rimanente.

## Approccio

`GenResizablePanelGroup(axis: Axis.vertical)` con due pannelli. La maniglia tra i
due pannelli È, visivamente, il bordo basso dell'header.

- **Panel A** `id: 'nav-header'` — `navHeader` (azienda + voci cliente), reso
  scrollabile. `defaultSize 0.4`, `minSize ~0.15`, `maxSize ~0.85`.
- **Panel B** `id: 'nav-primary'` — `GenNavList(destinations)`. `defaultSize 0.6`,
  `minSize ~0.15`.

Divider = handle Gen default (`showHandle: true`, `dividerColor: borderColor`).

Alternative scartate:
- **Nuovo slot `navSecondary`** separando azienda (fisso) da voci cliente: più
  API, non richiesto — l'header intero può fare da pannello.
- **Flag su `navHeader.extra`**: `extra` è incapsulato nel widget, non estraibile.
- **`navBuilder` full-custom**: butta via `GenNavList`.

## API

Aggiunta a `GenShellConfig`:

```dart
/// Opt-in (solo tier sidebar espanso): la bolla navHeader diventa un pannello
/// ad altezza regolabile con maniglia sul bordo basso; le destinations sotto
/// prendono lo spazio rimanente. Default false → layout odierno (header frosted
/// fisso). Ignorato in rail/mobile/drawer.
final bool resizableNavHeader; // default false
```

Nessun breaking change: default `false` = comportamento attuale. `navHeader` e
`navHeader.extra` restano invariati.

## Rendering (dove)

La modifica vive in `_navPanel` (usato sia dal path classico `_buildSidebar` sia
dal path `bubbleBody` via `_bubbleDesktop`).

Nuovo ramo, attivo **solo** quando:

```
!isCompact && !collapsed && widget.config.resizableNavHeader && headerContent != null
```

In quel ramo, al posto dell'attuale `Stack` (header frosted floating + `GenNavList`
full che scorre sotto):

```
Column / Stack:
  ├─ Positioned.fill: GenResizablePanelGroup(vertical)
  │     ├─ Panel A: SingleChildScrollView(headerContent)   // azienda + cliente
  │     │           top inset ridondante non serve (bolla propria)
  │     └─ Panel B: GenNavList(destinations)
  │                 bottom inset = _menuFooterH (footer frosted floating)
  └─ footer frosted (Positioned bottom) invariato
```

Note layout:
- L'header non è più una barra floating: diventa Panel A, una bolla con la sua
  altezza. `_menuHeaderH` (misura header) non serve più in questo ramo per l'inset
  di Panel B (Panel B parte sotto la maniglia).
- Il **footer** resta barra frosted fissa (Positioned bottom) sopra Panel B; Panel B
  mantiene `bottom inset = _menuFooterH` così l'ultima destination resta raggiungibile.
- Panel A scrollabile: `headerContent` va wrappato in `SingleChildScrollView`
  perché con `minSize` basso le voci cliente devono poter scrollare dentro il pannello.

## Tier non-espansi (fallback, invariati)

- **Rail collassato** (`collapsed`): usa `railHeader`, flag ignorato.
- **Drawer mobile** (`isCompact`): `navHeader` inline in cima allo scroll come oggi,
  niente resize.
- **`resizableNavHeader == false`**: layout odierno per tutti i tier.

## Persistenza

Nessuna. Lo split vive nello stato interno di `GenResizablePanelGroupState` per la
sessione; reset al reload. (Estendibile in futuro con `initialSizes`/`onResize` se
servirà persistenza per-utente.)

## Esempio (`example/lib`)

- `home_shell`: `config: GenShellConfig(bubbleBody: true, resizableNavHeader: true)`.
- `ClientContextMenu` resta in `NavHeader.extra`. Verificare che, dentro Panel A
  scrollabile, il suo `Column` mainAxisSize.min non causi conflitti (il wrapping
  `SingleChildScrollView` lo gestisce a livello `_navPanel`).

## Test manuali

1. Sidebar espansa + molte voci cliente → maniglia visibile sul bordo basso header.
2. Drag giù → header cresce, cliente scrolla dentro, destinations si comprimono.
3. Drag su fino a `minSize` → header minimo, destinations massime.
4. Resize finestra desktop → pannelli mantengono proporzioni, nessun overflow.
5. Restringi a rail → nessuna maniglia, `railHeader` (flag ignorato).
6. Restringi a mobile → drawer con `navHeader` inline, niente resize.
7. `resizableNavHeader: false` → layout identico a oggi (regressione).

## Rischi

- Interazione handle drag vs scroll interno di Panel A: verificare che il drag della
  maniglia non venga catturato dallo scroll del pannello (gesture arena). Il group
  Shad gestisce la maniglia come area dedicata → atteso ok, da validare.
- `bubbleBody` frost: Panel A ora è bolla opaca (`secondaryBackground`), non più vetro
  floating → cambio estetico atteso e voluto (header solido con maniglia).
