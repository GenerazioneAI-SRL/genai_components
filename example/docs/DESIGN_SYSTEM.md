# CL Design System — Bibbia di Riferimento

> Documento di specifica completa per la libreria `genai_components` di GenerazioneAI SRL.
> Tutti i widget della libreria usano il prefisso **`CL`** (es. `CLButton`, `CLTextField`).

---

## 📖 Preambolo per l'AI Agent

Questo documento è la **fonte di verità unica** per lo sviluppo dei componenti UI della libreria `genai_components`. Se stai scrivendo codice per questa libreria, le regole qui descritte **non sono suggerimenti ma requisiti**.

### Come leggere questo documento

- **Ogni sezione è normativa**: se dice "il valore è X", il valore deve essere X.
- **Non inventare**: se un dettaglio non è coperto qui, chiedi prima di implementare. Non dedurre da Material Design o altri sistemi.
- **Non modificare i token**: i valori numerici (colori, size, spacing) sono definiti centralmente e non si cambiano per un singolo componente.
- **Coerenza prima di creatività**: è preferibile un componente "banale" ma coerente rispetto a uno "bello" ma isolato.

### Regole d'oro

1. **Pensa per window size, non per device**: layout adattivo in base alla larghezza effettiva, mai basato su `Platform.isIOS/isAndroid`.
2. **Usa design token, mai valori hardcoded**: niente `Color(0xFF...)` o `fontSize: 14` diretti nei componenti.
3. **Default sobri**: animazioni rapide, effetti minimali, niente splash Material di default.
4. **Accessibilità non negoziabile**: ogni elemento interattivo ha `semanticLabel`, focus visibile, touch target adeguato.
5. **API consistenti**: tutti i componenti accettano `size`, `variant`, `isDisabled`, callback `on*`.

---

## 📚 Indice

1. [Principi Fondamentali](#1-principi-fondamentali)
2. [Design Tokens](#2-design-tokens)
3. [Foundations](#3-foundations)
4. [Architettura e Convenzioni](#4-architettura-e-convenzioni)
5. [Layout Shell e Navigazione](#5-layout-shell-e-navigazione)
6. [Componenti — Catalogo Completo](#6-componenti--catalogo-completo)
7. [Pattern UX Trasversali](#7-pattern-ux-trasversali)
8. [Tema e Personalizzazione](#8-tema-e-personalizzazione)
9. [Accessibilità](#9-accessibilità)
10. [Responsive e Window Size](#10-responsive-e-window-size)
11. [Copy, Microcopy e Tono di Voce](#11-copy-microcopy-e-tono-di-voce)
12. [Do's and Don'ts](#12-dos-and-donts)
13. [Appendici](#13-appendici)

---

## 1. Principi Fondamentali

### 1.1 Filosofia del design system

Il design system CL è costruito per **SaaS dashboard professionali** destinate a utenti business. I principi guida sono:

- **Professionalità sobria**: l'aspetto è enterprise-grade, non consumer/playful.
- **Densità informativa**: le dashboard mostrano molti dati, lo spazio va usato con intelligenza.
- **Coerenza assoluta**: identici stati producono identiche apparenze ovunque.
- **Performance percepita**: ogni attesa è comunicata (skeleton, progress, loading).
- **Adattività**: il layout si adatta alla dimensione della finestra, non al dispositivo.

### 1.2 Target utente

Utenti professionali che usano la dashboard **ore al giorno**. Questo implica:

- Velocità di interazione prioritaria sull'estetica decorativa.
- Shortcut da tastiera pervasivi.
- Densità regolabile (comfortable / normal / compact).
- Preferenze persistenti (ogni scelta dell'utente va ricordata).

### 1.3 Contesti d'uso primari

| Contesto | Caratteristiche |
|----------|-----------------|
| Desktop largo (>1280px) | Uso primario, layout completo con sidebar espansa |
| Laptop (900-1280px) | Uso secondario, sidebar collassata automatica |
| Tablet (600-900px) | Uso occasionale, layout ibrido |
| Mobile (<600px) | Uso di consultazione, BottomNav, layout semplificato |

### 1.4 Anti-pattern di filosofia

❌ **Non fare**:
- Design "giocoso" con animazioni decorative (bounce, parallax, confetti).
- Gradient vivaci come elementi primari.
- Skeuomorfismi (ombre esagerate, texture).
- Icone cartoon o emoji come elementi UI.
- Errori con illustrazioni "friendly" su contesti professionali.

✅ **Fare**:
- Design pulito, sobrio, basato su tipografia e spacing.
- Colori saturi solo per accenti funzionali.
- Ombre leggere e funzionali (dare gerarchia, non decorare).
- Icone lineari coerenti (Lucide Icons).

---

## 2. Design Tokens

I design token sono i valori primitivi del design system. **Nessun componente deve hardcodare valori** — tutti i valori derivano dai token.

### 2.1 Colori

#### 2.1.1 Palette primitiva

Ogni colore primario ha una scala 50-900. I componenti **non devono** usare direttamente i primitivi, ma solo i **token semantici** (sezione 2.1.2).

Scale da definire per: `primary`, `neutral`, `success`, `warning`, `error`, `info`.

```dart
class CLColorsPrimitive {
  // Primary (brand)
  static const primary50  = Color(0xFFEFF6FF);
  static const primary100 = Color(0xFFDBEAFE);
  static const primary200 = Color(0xFFBFDBFE);
  static const primary300 = Color(0xFF93C5FD);
  static const primary400 = Color(0xFF60A5FA);
  static const primary500 = Color(0xFF2563EB); // base
  static const primary600 = Color(0xFF1D4ED8);
  static const primary700 = Color(0xFF1E40AF);
  static const primary800 = Color(0xFF1E3A8A);
  static const primary900 = Color(0xFF172554);

  // Neutral
  static const neutral50  = Color(0xFFF9FAFB);
  static const neutral100 = Color(0xFFF3F4F6);
  static const neutral200 = Color(0xFFE5E7EB);
  static const neutral300 = Color(0xFFD1D5DB);
  static const neutral400 = Color(0xFF9CA3AF);
  static const neutral500 = Color(0xFF6B7280);
  static const neutral600 = Color(0xFF4B5563);
  static const neutral700 = Color(0xFF374151);
  static const neutral800 = Color(0xFF1F2937);
  static const neutral900 = Color(0xFF111827);
  static const neutral950 = Color(0xFF030712);

  // Success
  static const success50  = Color(0xFFECFDF5);
  static const success500 = Color(0xFF10B981);
  static const success600 = Color(0xFF059669);
  // ... completare scala

  // Warning
  static const warning50  = Color(0xFFFFFBEB);
  static const warning500 = Color(0xFFF59E0B);
  static const warning600 = Color(0xFFD97706);
  // ... completare scala

  // Error
  static const error50  = Color(0xFFFEF2F2);
  static const error500 = Color(0xFFEF4444);
  static const error600 = Color(0xFFDC2626);
  // ... completare scala

  // Info
  static const info50  = Color(0xFFEFF6FF);
  static const info500 = Color(0xFF3B82F6);
  static const info600 = Color(0xFF2563EB);
  // ... completare scala
}
```

> **Nota**: i valori esatti della palette sono un'impostazione del brand e possono essere personalizzati via tema. I valori sopra sono il default.

#### 2.1.2 Token semantici (da usare nei componenti)

Questi sono gli **unici colori** che i componenti possono riferire:

| Token | Light | Dark | Uso |
|-------|-------|------|-----|
| **Brand** | | | |
| `colorPrimary` | primary500 | primary400 | Elementi primari, CTA |
| `colorPrimaryHover` | primary600 | primary300 | Hover state primary |
| `colorPrimaryPressed` | primary700 | primary200 | Pressed state primary |
| `colorPrimarySubtle` | primary50 | primary900 | Bg subtle per stati selected |
| **Superfici** | | | |
| `surfacePage` | neutral50 | neutral950 | Background pagina |
| `surfaceCard` | white | neutral900 | Background card, panel |
| `surfaceInput` | white | neutral800 | Background input field |
| `surfaceOverlay` | white | neutral850 | Background modal, dropdown |
| `surfaceSidebar` | white | neutral900 | Background sidebar |
| `surfaceHover` | neutral100 | neutral800 | Bg hover generico |
| `surfacePressed` | neutral200 | neutral700 | Bg pressed generico |
| **Bordi** | | | |
| `borderDefault` | neutral200 | neutral700 | Bordo standard |
| `borderStrong` | neutral300 | neutral600 | Bordo più visibile |
| `borderFocus` | primary500 | primary400 | Focus ring |
| `borderError` | error500 | error400 | Border campo in errore |
| `borderSuccess` | success500 | success400 | Border campo valido |
| **Testo** | | | |
| `textPrimary` | neutral900 | neutral50 | Testo principale |
| `textSecondary` | neutral500 | neutral400 | Testo secondario, hint |
| `textDisabled` | neutral300 | neutral600 | Testo disabilitato |
| `textOnPrimary` | white | white | Testo su bg colorPrimary |
| `textLink` | primary600 | primary400 | Link inline |
| `textError` | error600 | error400 | Messaggio errore |
| `textSuccess` | success600 | success400 | Messaggio successo |
| `textWarning` | warning600 | warning400 | Messaggio warning |
| **Stato semantico** | | | |
| `colorSuccess` | success500 | success400 | Icona/bg success |
| `colorWarning` | warning500 | warning400 | Icona/bg warning |
| `colorError` | error500 | error400 | Icona/bg error |
| `colorInfo` | info500 | info400 | Icona/bg info |
| `colorSuccessSubtle` | success50 | success900 | Bg subtle success |
| `colorWarningSubtle` | warning50 | warning900 | Bg subtle warning |
| `colorErrorSubtle` | error50 | error900 | Bg subtle error |
| `colorInfoSubtle` | info50 | info900 | Bg subtle info |

#### 2.1.3 Stati interattivi — tabella di riferimento

| Stato | Metodo di applicazione |
|-------|-----------------------|
| Default | Token base |
| Hover | `surfaceHover` come background, o tinta -100 della scala primitiva |
| Pressed | `surfacePressed` come background, o tinta -200 |
| Focus | Outline 2px `borderFocus`, offset 2px, nessun fill |
| Disabled | Opacity 0.38 sull'intero componente |
| Selected | Bg `colorPrimarySubtle`, testo `colorPrimary` |
| Loading | Opacity 0.7 + non interagibile |
| Read-only | Bg subtle diverso, bordo tratteggiato |

#### 2.1.4 Dark mode — regole specifiche

- **Non invertire**: i grigi non sono semplicemente inverti; `neutral900` non diventa `neutral100`.
- **Scala dedicata**: i token dark hanno valori propri nella tabella 2.1.2.
- **Saturazione ridotta**: i colori semantici su dark usano tinte -400 invece di -500.
- **Elevation via overlay**: su dark si usa overlay bianco semi-trasparente (vedi 2.5.2), non ombre scure.
- **Contrasti morbidi**: `primary400` invece di `primary500` per evitare contrasti abbaglianti.


### 2.2 Spacing

Scala basata su **multipli di 4px**. Ogni spaziatura del sistema deve usare uno di questi token.

```dart
class CLSpacing {
  static const double s0   = 0.0;
  static const double s1   = 4.0;
  static const double s2   = 8.0;
  static const double s3   = 12.0;
  static const double s4   = 16.0;
  static const double s5   = 20.0;
  static const double s6   = 24.0;
  static const double s8   = 32.0;
  static const double s10  = 40.0;
  static const double s12  = 48.0;
  static const double s16  = 64.0;
  static const double s20  = 80.0;
  static const double s24  = 96.0;
}
```

#### 2.2.1 Guida d'uso per contesto

| Contesto | Desktop | Mobile |
|----------|---------|--------|
| Gap icona → testo | s2 (8) | s2 (8) |
| Padding H interno componente | s4 (16) | s4 (16) |
| Padding V interno componente | varia per size | varia per size |
| Gap tra elementi form | s4 (16) | s3 (12) |
| Gap tra sezioni dentro card | s6 (24) | s4 (16) |
| Padding card | s6 (24) | s4 (16) |
| Padding pagina H | s8 (32) | s4 (16) |
| Padding pagina V | s6 (24) | s4 (16) |
| Gap tra card in griglia | s6 (24) | s3 (12) |
| Gap tra sezioni pagina | s10 (40) | s8 (32) |
| Gap tra blocchi macro pagina | s12 (48) | s8 (32) |

#### 2.2.2 Grid di pagina

| Breakpoint | Colonne | Gutter | Margini laterali |
|-----------|---------|--------|------------------|
| `> 1280px` | 12 | s6 (24) | s8 (32) |
| `900-1280px` | 8 | s4 (16) | s6 (24) |
| `600-900px` | 4 | s3 (12) | s4 (16) |
| `< 600px` | 4 | s3 (12) | s4 (16) |

### 2.3 Tipografia

#### 2.3.1 Scale tipografica

```dart
class CLTypography {
  static const displayLg = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w700, height: 1.25,
  );
  static const displaySm = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700, height: 1.33,
  );
  static const headingLg = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600, height: 1.4,
  );
  static const headingSm = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, height: 1.5,
  );
  static const bodyLg = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.5,
  );
  static const bodyMd = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.43,
  );
  static const bodySm = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.33,
  );
  static const label = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500, height: 1.43,
  );
  static const labelSm = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, height: 1.33,
  );
  static const caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400, height: 1.45,
  );
  static const code = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400, height: 1.54,
    fontFamily: 'JetBrainsMono',
  );
}
```

#### 2.3.2 Adattamento mobile

Su schermi `< 600px`, alcuni token vengono leggermente aumentati per leggibilità:

| Token | Desktop | Mobile |
|-------|---------|--------|
| displayLg | 32 | 28 |
| displaySm | 24 | 22 |
| headingLg | 20 | 18 |
| headingSm | 16 | 16 |
| bodyLg | 16 | 16 |
| bodyMd | 14 | 15 |
| bodySm | 12 | 13 |
| label | 14 | 15 |
| labelSm | 12 | 13 |
| caption | 11 | 12 |

> **Non scendere mai sotto 13sp su mobile** per testi leggibili.

#### 2.3.3 Mappatura tipografia → componenti

| Componente | Token |
|------------|-------|
| TextField input value (md) | bodyMd |
| TextField label | label |
| TextField hint/error | caption |
| Button label (md) | label |
| Button label (sm) | labelSm |
| Sidebar item | bodyMd |
| AppBar title | headingSm |
| Tabs label | label |
| Breadcrumb | bodySm |
| Table header | labelSm UPPERCASE |
| Table cell | bodyMd |
| KPI value | displaySm (bold) |
| KPI label | bodySm |
| List item title | bodyMd |
| List item subtitle | bodySm |
| Toast | bodyMd |
| Modal title | headingSm |
| Tooltip | bodySm |
| Badge/Chip | labelSm |
| Empty state title | headingSm |
| Empty state body | bodyMd |

#### 2.3.4 Regole d'uso

- **Gerarchia via size + weight**, non solo colore.
- **Mai font weight 700** fuori da display/heading (appesantisce).
- **Uppercase** solo per `labelSm` in contesti di classificazione (header tabella, label gruppo).
- **Label forms** usano weight 500 (`label`), non 400 (`bodyMd`).
- **Testi disabilitati**: stessa size, `opacity 0.38`.
- **Line-height rispettato**: non comprimere il line-height per far stare più testo.

### 2.4 Sizing dei componenti

I componenti interattivi seguono una scala di 5 size:

```dart
enum CLSize {
  xs(height: 32, iconSize: 16, paddingH: 8,  paddingV: 6,  gap: 4,
     borderRadius: 4,  borderWidth: 1.0, fontSize: 12),
  sm(height: 40, iconSize: 18, paddingH: 12, paddingV: 8,  gap: 6,
     borderRadius: 6,  borderWidth: 1.0, fontSize: 14),
  md(height: 48, iconSize: 20, paddingH: 16, paddingV: 12, gap: 8,
     borderRadius: 8,  borderWidth: 1.5, fontSize: 16),
  lg(height: 56, iconSize: 24, paddingH: 20, paddingV: 14, gap: 8,
     borderRadius: 10, borderWidth: 1.5, fontSize: 18),
  xl(height: 64, iconSize: 28, paddingH: 24, paddingV: 16, gap: 10,
     borderRadius: 12, borderWidth: 2.0, fontSize: 20);

  final double height;
  final double iconSize;
  final double paddingH;
  final double paddingV;
  final double gap;
  final double borderRadius;
  final double borderWidth;
  final double fontSize;

  const CLSize({
    required this.height,
    required this.iconSize,
    required this.paddingH,
    required this.paddingV,
    required this.gap,
    required this.borderRadius,
    required this.borderWidth,
    required this.fontSize,
  });
}
```

#### 2.4.1 Adattamento mobile

Su mobile (`< 600px`), il size aumenta leggermente per touch target:

| Token | Desktop | Mobile |
|-------|---------|--------|
| xs | 32 | 36 |
| sm | 40 | 44 |
| md | 48 | 52 |
| lg | 56 | 56 |
| xl | 64 | 64 |

> **Su mobile il size minimo raccomandato è `md`** per elementi interattivi (touch target 48px minimo).

#### 2.4.2 Quale size usare per componente + contesto

| Contesto | Size consigliato |
|----------|------------------|
| Dashboard desktop standard | md |
| Toolbar / AppBar | sm |
| Tabelle e liste dense | sm o xs |
| Form standalone (pagina intera) | md o lg |
| Mobile / BottomSheet | lg |
| Componenti secondari / inline | xs o sm |
| CTA hero landing | lg o xl |

| Componente | Size contesto tipico |
|------------|---------------------|
| TextField form | md |
| TextField search in toolbar | sm |
| TextField filtro in tabella | sm |
| Button CTA pagina | md |
| Button in toolbar | sm |
| Button inline in tabella | xs |
| Button in modal | md |
| FAB | lg |
| Checkbox / Radio | sm (sempre) |
| Toggle | sm (sempre) |
| Sidebar item | sm |
| AppBar | sm (altezza 56) |
| Tabs | sm |
| Pagination | sm |
| Stepper | md |
| Tooltip | — (solo bodySm) |
| ContextMenu item | sm |
| Toast | sm |
| Badge | xs |
| Tag/Chip | xs o sm |

### 2.5 Elevation

#### 2.5.1 Livelli

| Livello | Uso | Light shadow | Dark overlay |
|---------|-----|--------------|--------------|
| 0 | Superficie base, input | Nessuna | Nessuno |
| 1 | Card standard | `0 1px 3px rgba(0,0,0,0.08)` | bianco 4% |
| 2 | Card hover, dropdown | `0 4px 8px rgba(0,0,0,0.10)` | bianco 6% |
| 3 | Sidebar, sticky header | `0 4px 12px rgba(0,0,0,0.12)` | bianco 8% |
| 4 | Modal, drawer | `0 8px 24px rgba(0,0,0,0.16)` | bianco 10% |
| 5 | Toast, tooltip | `0 12px 32px rgba(0,0,0,0.20)` | bianco 12% |

#### 2.5.2 Dark mode — elevation via overlay

Su dark mode le ombre scure non si vedono. Si usa invece un **overlay bianco semi-trasparente**:

```dart
Color surfaceWithElevation(int level, Color baseSurface) {
  final overlayOpacities = [0.0, 0.04, 0.06, 0.08, 0.10, 0.12];
  return Color.alphaBlend(
    Colors.white.withOpacity(overlayOpacities[level]),
    baseSurface,
  );
}
```

### 2.6 Z-index (layering)

Gerarchia globale dei layer per evitare conflitti tra overlay.

| Z-index | Uso |
|---------|-----|
| 0 | Contenuto base |
| 10 | Elementi sticky (header tabella, filtri) |
| 100 | Sidebar, AppBar |
| 200 | Dropdown, popover, tooltip |
| 300 | Drawer laterale |
| 400 | Modal backdrop |
| 401 | Modal content |
| 500 | Toast / Snackbar |
| 600 | Command palette |
| 700 | Loader globale / blocking overlay |
| 999 | Debug overlay (solo dev mode) |

> **Regola**: un dropdown dentro un modal deve avere z-index relativo maggiore del modal, gestito automaticamente dal sistema di overlay.


---

## 3. Foundations

### 3.1 Iconografia

#### 3.1.1 Libreria di riferimento

**Lucide Icons** è la libreria di riferimento. Nessun'altra libreria di icone deve essere usata nei componenti core.

- Package: `lucide_icons` su pub.dev
- Stile: outline, stroke 1.5px, angoli arrotondati
- ViewBox: 24×24

#### 3.1.2 Mai mischiare librerie

❌ Non usare Material Icons, FontAwesome, Cupertino Icons insieme a Lucide.  
✅ Se serve un'icona non presente in Lucide, creare un'icona custom nello stesso stile (SVG outline, stroke 1.5px).

#### 3.1.3 Size icone per contesto

| Contesto | Size |
|----------|------|
| Inline nel testo | stessa font size del contesto |
| Button xs | 16 |
| Button sm | 18 |
| Button md | 20 |
| Button lg | 24 |
| Button xl | 28 |
| Sidebar item | 20 |
| AppBar action | 22 |
| Empty state | 48 |
| Illustration (onboarding) | 80-120 |

#### 3.1.4 Icone con badge

```
Posizione badge   →  top-right, sovrapposto di -4px / -4px
Badge dot         →  8px, solo colore
Badge numerico    →  min 16px, font 10px, bg color, testo bianco
Overflow numerico →  "9+" se > 9, "99+" se > 99
```

#### 3.1.5 Icone custom

Icone personalizzate del brand vanno in:
```
assets/icons/custom/
```

Wrapper Flutter per integrare icone custom come IconData:
```dart
class CLCustomIcons {
  static const IconData logo = IconData(0xe000, fontFamily: 'CLCustomIcons');
  // ...
}
```

### 3.2 Animazioni

#### 3.2.1 Reset effetti Material di default

**Obbligatorio nel tema globale**:

```dart
ThemeData(
  splashFactory: NoSplash.splashFactory,
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  hoverColor: Colors.transparent,
  // ...
)
```

#### 3.2.2 Effetti di interazione

##### Hover
```
Metodo: cambio di background, NON overlay
Colore: surfaceHover (primary-50 per primary button, neutral-100 per ghost)
Durata: 150ms ease
```

##### Press / Tap
```
Scale down: 0.97 o 0.98 (mai inferiore a 0.95)
Opacity:   0.85-0.9
Durata:    100ms in, 150ms out
```

##### Focus (accessibilità)
```
Outline:  2px, colore borderFocus
Offset:   2px dal bordo del componente
Mai nasconderlo - è obbligatorio per accessibilità
```

##### Disabled
```
Opacity: 0.38 sull'intero componente
Cursor: not-allowed su web, default su mobile
```

#### 3.2.3 Tabella hover/press per componente

| Componente | Hover | Press | Focus |
|------------|-------|-------|-------|
| Button primary | bg colorPrimaryHover | scale 0.97 | outline |
| Button ghost | bg surfaceHover | scale 0.97 | outline |
| IconButton | bg surfaceHover | scale 0.95 | outline |
| Sidebar item | bg surfaceHover | bg surfacePressed | outline |
| Table row | bg surfaceHover | bg surfacePressed | — |
| Card cliccabile | elevation +1 | scale 0.99 | outline |
| ListItem | bg surfaceHover | bg surfacePressed | outline |
| Chip selezionabile | bg colorPrimarySubtle | scale 0.97 | outline |
| Dropdown option | bg surfaceHover | bg surfacePressed | bg surfaceHover |

#### 3.2.4 Animazioni UI

| Evento | Tipo | Durata |
|--------|------|--------|
| Apertura Modal | fade + scale 0.95→1 | 200ms |
| Chiusura Modal | fade + scale 1→0.95 | 150ms |
| Apertura Drawer desktop | slide da lato | 250ms |
| Apertura Drawer mobile | slide + fade | 300ms |
| Toast in | slide dal basso + fade | 200ms |
| Toast out | fade | 150ms |
| Dropdown apre | fade + slide giù 4px | 150ms |
| Dropdown chiude | fade | 100ms |
| Tooltip apre | fade | 100ms (dopo delay 400ms) |
| Skeleton shimmer | gradient animato | loop 1.5s |
| Accordion apre | expand verticale | 200ms easeOut |
| Accordion chiude | collapse verticale | 150ms easeIn |
| Tab switch | fade cross | 150ms |
| Page transition (desktop) | fade | 200ms |
| Page transition (mobile) | slide orizzontale | 300ms |
| Sort colonna | rotazione freccia 180° | 180ms |
| Checkbox check | scale + draw | 150ms |
| Toggle slide | slide thumb | 200ms easeInOut |

#### 3.2.5 Curve

```dart
// Evitare Curves.easeInOut per tutto - troppo morbido
Curves.easeOut       // aperture, espansioni
Curves.easeIn        // chiusure, contrazioni
Curves.easeInOutCubic // transizioni di pagina
// Mai bounce/elastic fuori da contesti ludici
```

#### 3.2.6 Reduced motion

Rispettare la preferenza utente `MediaQuery.disableAnimations`:

```dart
if (MediaQuery.of(context).disableAnimations) {
  // - Disabilita scale/slide, tieni solo fade
  // - Durata ridotta del 50% o istantanee
  // - Niente shimmer skeleton, usa pulse leggero
  // - Niente parallax o effetti decorativi
}
```

### 3.3 Responsive System — overview

> Dettaglio completo nella [Sezione 10](#10-responsive-e-window-size).

#### 3.3.1 Window Size (non device)

```dart
enum CLWindowSize { compact, medium, expanded, large, extraLarge }
```

| Enum | Range | Comportamento tipico |
|------|-------|---------------------|
| `compact` | < 600px | Mono-colonna, BottomNav |
| `medium` | 600-900 | Layout ibrido, sidebar collassata/rail |
| `expanded` | 900-1280 | Sidebar espansa opzionale, 2-3 colonne |
| `large` | 1280-1536 | Layout desktop completo |
| `extraLarge` | > 1536 | Max-width content per evitare dispersione |

#### 3.3.2 Regola fondamentale

❌ `if (Platform.isIOS) ...` — **mai** basarsi sul device  
✅ `if (context.windowSize == CLWindowSize.compact) ...` — **sempre** basarsi sulla dimensione effettiva

Questo garantisce che anche un desktop con finestra rimpicciolita abbia l'UX adatta.


---

## 4. Architettura e Convenzioni

### 4.1 Struttura del progetto

```
genai_components/
├── lib/
│   ├── genai_components.dart          ← barrel file principale (API pubblica)
│   ├── src/
│   │   ├── tokens/
│   │   │   ├── colors.dart
│   │   │   ├── spacing.dart
│   │   │   ├── typography.dart
│   │   │   ├── sizing.dart
│   │   │   ├── elevation.dart
│   │   │   └── tokens.dart            ← barrel tokens
│   │   ├── theme/
│   │   │   ├── theme_extension.dart
│   │   │   ├── theme_builder.dart
│   │   │   └── context_extensions.dart
│   │   ├── foundations/
│   │   │   ├── icons.dart
│   │   │   ├── animations.dart
│   │   │   └── responsive.dart
│   │   ├── components/
│   │   │   ├── inputs/
│   │   │   │   ├── cl_text_field.dart
│   │   │   │   ├── cl_select.dart
│   │   │   │   ├── cl_date_picker.dart
│   │   │   │   └── ...
│   │   │   ├── actions/
│   │   │   │   ├── cl_button.dart
│   │   │   │   ├── cl_icon_button.dart
│   │   │   │   └── ...
│   │   │   ├── display/
│   │   │   ├── navigation/
│   │   │   ├── feedback/
│   │   │   ├── overlay/
│   │   │   ├── indicators/
│   │   │   └── layout/
│   │   └── utils/
│   │       ├── formatters.dart
│   │       └── validators.dart
├── example/                           ← app demo (showcase componenti)
├── test/
│   ├── unit/
│   ├── widget/
│   └── golden/
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
└── LICENSE
```

### 4.2 Naming convention

| Regola | Esempio |
|--------|---------|
| Widget pubblico | `CLButton`, `CLTextField`, `CLTable` |
| Widget privato helper | `_CLButtonSpinner` (underscore, stesso file) |
| File name | `cl_button.dart` (snake_case, matching widget) |
| Enum varianti | `CLButtonVariant.primary` |
| Parametri booleani | `isLoading`, `isDisabled`, `hasError` (prefisso `is`/`has`) |
| Callback | `onPressed`, `onChanged`, `onTap`, `onSubmit` (prefisso `on`) |
| Controller | `CLTextFieldController`, `CLTableController` |

### 4.3 API consistency — regole dei componenti

**Ogni componente pubblico accetta** (dove applicabile):

```dart
class CLComponent extends StatelessWidget {
  final CLSize size;              // default: CLSize.md
  final CLComponentVariant variant; // default: .primary (o equivalente)
  final bool isDisabled;          // default: false
  final bool isLoading;           // default: false (per componenti async)
  final VoidCallback? onPressed;  // null = disabled
  final String? semanticLabel;    // per accessibilità
  // parametri specifici del componente
}
```

**Non mischiare stili diversi**:

```dart
// ❌ NO
CLButton(disabled: true)
CLTextField(enabled: false)

// ✅ SÌ (coerente)
CLButton(isDisabled: true)
CLTextField(isDisabled: true)
```

### 4.4 Pattern di costruzione — quando usare cosa

#### 4.4.1 Named constructors (varianti semantiche)

Usare per **stessa struttura visiva, comportamento diverso**:

```dart
class CLTextField extends StatelessWidget {
  const CLTextField({
    this.label,
    this.size = CLSize.md,
    this.onChanged,
    // ...
  });

  const CLTextField.password({
    this.label,
    this.size = CLSize.md,
    this.onChanged,
  }) : obscureText = true,
       suffix = const _PasswordToggle();

  const CLTextField.search({
    this.hint = 'Cerca...',
    this.size = CLSize.sm,
    this.onChanged,
  }) : prefix = const Icon(LucideIcons.search);

  const CLTextField.numeric({
    this.label,
    this.size = CLSize.md,
    this.onChanged,
  }) : keyboardType = TextInputType.number;
}
```

#### 4.4.2 Widget separati

Usare per **struttura visiva diversa o composizione di più componenti**:

```dart
// Questi sono concettualmente diversi, non varianti
class CLDatePicker extends StatelessWidget { ... }
class CLTagInput extends StatelessWidget { ... }
class CLRichTextEditor extends StatelessWidget { ... }
class CLTable extends StatelessWidget { ... }
```

#### 4.4.3 Regola per decidere

```
Stessa struttura visiva, comportamento diverso  →  named constructor
Struttura visiva diversa                         →  widget separato
Composizione di più componenti                   →  widget separato
```

### 4.5 Mapping componenti → pattern

| Componente | Approccio |
|------------|-----------|
| `CLTextField` | Named constructors (default, password, search, numeric, multiline) |
| `CLButton` | Named constructors (primary, secondary, ghost, destructive) + variant enum |
| `CLSelect` | Named constructors (single, multi, searchable, creatable) |
| `CLDatePicker` | Widget separato |
| `CLDateRangePicker` | Widget separato |
| `CLTable` | Widget separato |
| `CLTagInput` | Widget separato |
| `CLRichTextEditor` | Widget separato |
| `CLModal` | Function `showCLModal<T>()` |
| `CLToast` | Function `showCLToast()` |
| `CLCard` | Named constructors (default, clickable, collapsible) |
| `CLKPICard` | Widget separato |
| `CLAvatar` | Named constructors (image, initials, placeholder) |
| `CLBadge` | Named constructors (dot, count, text) |
| `CLChip` | Named constructors (readonly, removable, selectable) |
| `CLSkeleton` | Named constructors (text, rect, circle, table) |
| `CLSidebar` | Widget separato |
| `CLAppBar` | Widget separato |
| `CLCommandPalette` | Widget separato (function `showCLCommandPalette`) |

### 4.6 Controller pattern

Per componenti che necessitano stato esterno:

- **TextField**: `TextEditingController` esterno opzionale (standard Flutter).
- **Dropdown/Select**: pattern controlled `value + onChanged`.
- **Form**: `CLFormController` custom per validation centralizzata.
- **Table**: `CLTableController` per selezione/sort/filter/pagination.
- **Modal**: `showCLModal<T>()` ritorna `Future<T?>` con il dato di chiusura.

### 4.7 Modal / Dialog API

**Preferire function, non widget**:

```dart
// ✅ SÌ
final result = await showCLModal<bool>(
  context: context,
  title: 'Conferma eliminazione',
  child: const Text('Sei sicuro?'),
  actions: [
    CLButton.ghost(label: 'Annulla', onPressed: () => Navigator.pop(context, false)),
    CLButton(label: 'Elimina', variant: CLButtonVariant.destructive,
             onPressed: () => Navigator.pop(context, true)),
  ],
);

// ❌ NO
showDialog(context: context, builder: (_) => CLModal(...))
```

### 4.8 Accesso ai token in qualsiasi widget

Tramite extension su `BuildContext`:

```dart
extension CLThemeContext on BuildContext {
  CLColorTokens get colors => Theme.of(this).extension<CLThemeExtension>()!.colors;
  CLSpacingTokens get spacing => Theme.of(this).extension<CLThemeExtension>()!.spacing;
  CLTypographyTokens get typography => Theme.of(this).extension<CLThemeExtension>()!.typography;
  CLWindowSize get windowSize => CLResponsive.sizeOf(this);
  bool get isCompact => windowSize == CLWindowSize.compact;
  bool get isExpanded => windowSize.index >= CLWindowSize.expanded.index;
}

// Uso
Container(
  color: context.colors.surfaceCard,
  padding: EdgeInsets.all(context.spacing.s4),
  child: Text('Hello', style: context.typography.bodyMd),
)
```

### 4.9 Barrel file (export pubblico)

```dart
// lib/genai_components.dart
library genai_components;

// Tokens
export 'src/tokens/tokens.dart';

// Theme
export 'src/theme/theme_builder.dart';
export 'src/theme/theme_extension.dart';
export 'src/theme/context_extensions.dart';

// Foundations
export 'src/foundations/responsive.dart';

// Components - Inputs
export 'src/components/inputs/cl_text_field.dart';
export 'src/components/inputs/cl_select.dart';
export 'src/components/inputs/cl_date_picker.dart';
// ... tutti i componenti pubblici
```

### 4.10 Documentazione DartDoc

Ogni widget pubblico **deve** avere:

```dart
/// Un campo di testo del design system CL.
///
/// Supporta diverse varianti tramite costruttori nominati:
/// - [CLTextField.password] per input password con toggle visibilità
/// - [CLTextField.search] per barra di ricerca con icona
/// - [CLTextField.numeric] per input numerici
/// - [CLTextField.multiline] per textarea
///
/// Esempio:
/// ```dart
/// CLTextField(
///   label: 'Email',
///   size: CLSize.md,
///   onChanged: (value) => print(value),
/// )
/// ```
///
/// Vedi anche:
/// - [CLSelect] per input con scelta tra opzioni
/// - [CLDatePicker] per selezione data
class CLTextField extends StatelessWidget {
  // ...
}
```

### 4.11 Versioning

Semantic versioning per pub.dev:

```
0.x.y    →  pre-release, breaking changes permessi
1.0.0    →  API stabile, prima major
1.x.0    →  nuove feature, backward compatible
1.x.y    →  bug fix only
2.0.0    →  breaking changes (evitare se possibile)

Deprecation:
  @Deprecated('Use CLNewButton instead. Will be removed in v2.0.0')
  sempre almeno una minor di preavviso prima della rimozione
```


---

## 5. Layout Shell e Navigazione

### 5.1 Approccio visivo — "Content Card"

Il layout shell adotta l'approccio **"content card"**: sidebar e header ai bordi dello schermo, il content area ha un background leggermente diverso così da far emergere le card.

```
┌─────────────────────────────────────┐  bg: surfacePage (neutral-50)
│▓▓▓▓│▒▒▒▒▒▒│ Header           [azioni]
│▓▓▓▓│▒▒▒▒▒▒│━━━━━━━━━━━━━━━━━━━━━━━━│
│▓▓▓▓│▒▒▒▒▒▒│                        │
│▓▓▓▓│▒▒▒▒▒▒│  ┌──────────────────┐  │
│▓▓▓▓│▒▒▒▒▒▒│  │ Page content     │  │
│▓▓▓▓│▒▒▒▒▒▒│  │                  │  │
│▓▓▓▓│▒▒▒▒▒▒│  └──────────────────┘  │
└─────────────────────────────────────┘
```

#### 5.1.1 Regole visive

| Elemento | Specifica |
|----------|-----------|
| `surfacePage` | `neutral-50` (light) / `neutral-950` (dark) |
| Sidebar | `surfaceSidebar`, border-right 1px borderDefault, no shadow |
| AppBar/Header | `surfaceCard`, border-bottom 1px borderDefault, no shadow |
| Content area | Eredita `surfacePage`, nessun bg proprio |
| Card dentro content | `surfaceCard`, shadow elevation 1, border-radius 8-12px |

### 5.2 Struttura gerarchica della navigazione

La libreria supporta **fino a 3 livelli** di navigazione:

```
Livello 1 (L1)   →  Moduli principali        es. CRM, Fatturazione, HR
Livello 2 (L2)   →  Sezioni del modulo       es. Clienti, Opportunità, Report
Livello 3 (L3)   →  Sotto-sezioni / viste    es. Lista, Kanban, Analisi
```

### 5.3 Pattern desktop — Sidebar a due colonne

Su window size `expanded` e maggiori:

```
┌──────┬─────────────────┬─────────────────────────────┐
│      │                 │                             │
│  L1  │       L2        │         Contenuto           │
│      │                 │                             │
│ icon │  voci modulo    │                             │
│ icon │  con L3 inline  │                             │
│ icon │                 │                             │
│      │                 │                             │
└──────┴─────────────────┴─────────────────────────────┘
```

- **Colonna L1**: 56-64px, solo icone, sempre visibile
- **Colonna L2+L3**: 220-260px, si apre cliccando un modulo L1
- **L3**: accordion inline dentro L2 (non un terzo pannello)

### 5.4 Comportamento dei livelli

#### 5.4.1 Livello 1 (moduli)

| Evento | Comportamento |
|--------|---------------|
| Click icona modulo | Apre colonna L2, evidenzia icona attiva |
| Hover icona (sidebar collassata) | Tooltip con nome modulo |
| Stato attivo | bg `colorPrimarySubtle`, icona `colorPrimary` |

#### 5.4.2 Livello 2 (sezioni)

| Evento | Comportamento |
|--------|---------------|
| Voce senza figli + click | Navigazione diretta |
| Voce con figli + click | Accordion espande/collassa L3 inline |
| Stato attivo | Testo `colorPrimary` + indicatore laterale 3-4px `colorPrimary` |
| Hover | bg `surfaceHover` |

#### 5.4.3 Livello 3 (sotto-sezioni)

```
Indentazione: 12-16px rispetto a L2
Tipografia:   bodySm (12sp) invece di bodyMd (14sp)
Stato attivo: testo colorPrimary, font weight 500
```

Esempio visivo:

```
┌─────────────────┐
│ Clienti      ▾  │  ← L2 con figli, accordion aperto
│   Lista         │  ← L3
│   Kanban        │  ← L3
│   Analisi    ●  │  ← L3 attivo
│                 │
│ Opportunità  ▸  │  ← L2 con figli, accordion chiuso
│                 │
│ Report          │  ← L2 senza figli
└─────────────────┘
```

### 5.5 Collasso della sidebar

Opzioni per dare più spazio al content:

| Stato | Larghezza totale | Visualizzazione |
|-------|------------------|-----------------|
| Espansa | 280-320px | L1 icone + L2 testo visibile |
| Collassata | 56-64px | Solo L1 icone; hover mostra tooltip |
| Collassata + flyout | 56-64px + overlay | Click icona apre flyout temporaneo L2+L3 |

### 5.6 Responsività della navigazione

#### 5.6.1 Adattamento per window size

| Window size | Comportamento |
|-------------|---------------|
| `extraLarge` (>1536) | Sidebar espansa di default, content con max-width |
| `large` (1280-1536) | Sidebar espansa di default |
| `expanded` (900-1280) | Sidebar collassata di default (solo L1) |
| `medium` (600-900) | NavigationRail (sidebar stretta) + bottom nav opzionale |
| `compact` (<600) | BottomNavigationBar + Drawer per L1/L2 |

#### 5.6.2 Pattern compact (mobile)

```
L1  →  BottomNavigationBar (max 5 voci)
L2  →  Drawer laterale OPPURE push a nuova schermata
L3  →  Push navigation (nuova pagina con back button)
```

Esempio mobile:
```
┌─────────────────────┐
│ ← CRM    Clienti    │  ← AppBar con back button
├─────────────────────┤
│  Lista           ›  │  ← L3 come ListTile
│  Kanban          ›  │
│  Analisi         ›  │
├─────────────────────┤
│ 🏠   👥   💰   📊  │  ← BottomNav (L1)
└─────────────────────┘
```

### 5.7 BottomNavigationBar (compact)

```
Max 5 voci         →  oltre si usa drawer o menu "Altro"
Icona + label      →  sempre visibili, mai solo icona
Badge numerico     →  opzionale per voce
Voce "Altro"       →  se >5 moduli, l'ultima apre drawer con il resto
```

### 5.8 AppBar (tutti i breakpoint)

#### 5.8.1 Struttura desktop

```
┌─────────────────────────────────────────────────────┐
│ Breadcrumb: CRM / Clienti / Analisi    [search][⋮] │
└─────────────────────────────────────────────────────┘
```

- Altezza fissa: **56px** (sm)
- Breadcrumb sempre visibile a 3 livelli
- Max 3-4 azioni a destra, oltre → menu ⋮

#### 5.8.2 Struttura mobile (compact)

```
┌─────────────────────┐
│ ← Titolo pagina [⋮] │
└─────────────────────┘
```

- Back button sempre presente tranne su root
- Titolo della pagina corrente
- Max 2-3 azioni a destra
- Overflow ⋮ se azioni >3

### 5.9 Breadcrumb

**A 3 livelli di navigazione, il breadcrumb non è opzionale**.

```
CRM  /  Clienti  /  Analisi
```

| Elemento | Specifica |
|----------|-----------|
| Separatore | `/` con spazi o chevron `›` |
| L1 (modulo) | Cliccabile, stesso colore `textSecondary` |
| L2 (sezione) | Cliccabile, `textSecondary` |
| L3 (pagina attuale) | Non cliccabile, `textPrimary` weight 500 |
| Troncamento | Su overflow: `Home / ... / Pagina attuale` |
| Click su `...` | Mostra dropdown con i livelli nascosti |

### 5.10 Animazioni navigazione

| Evento | Effetto | Durata |
|--------|---------|--------|
| Click modulo L1 | Slide-in da sinistra pannello L2 | 200ms easeOut |
| Cambio modulo L1 | Cross-fade pannello L2 | 150ms |
| Accordion L3 apre | Expand verticale | 200ms easeOut |
| Accordion L3 chiude | Collapse verticale | 150ms easeIn |
| Hover voce | bg transition | 100ms |
| Attivazione voce | Indicatore laterale slide-in | 150ms easeOut |
| Collassa sidebar L2 | Slide out, L1 rimane | 250ms easeInOut |

### 5.11 Stato persistito

Da salvare in preferenze locali (SharedPreferences o simile):

- Quale modulo L1 è attivo
- Quali accordion L3 sono aperti
- Se la sidebar è espansa o collassata
- Ultima pagina visitata per ogni modulo

### 5.12 Anti-pattern navigazione

- ❌ Tre colonne sempre visibili (troppo spazio occupato)
- ❌ Dropdown a cascata su hover (difficile da usare)
- ❌ L3 in un secondo drawer (disorientante)
- ❌ Icone L1 senza tooltip
- ❌ Tutti gli accordion L3 aperti di default
- ❌ Breadcrumb assente
- ❌ Sidebar che si nasconde casualmente al cambio pagina


---

## 6. Componenti — Catalogo Completo

### 6.1 Input & Form

#### 6.1.1 `CLTextField`

Campo di testo con named constructors per le varianti comuni.

##### Varianti (named constructors)

| Costruttore | Descrizione |
|-------------|-------------|
| `CLTextField()` | Testo libero standard |
| `CLTextField.password()` | Password con toggle visibilità |
| `CLTextField.search()` | Search con icona lucide.search e clear button |
| `CLTextField.numeric()` | Input numerico con frecce opzionali |
| `CLTextField.multiline()` | Textarea con altezza espandibile |

##### Stati

```
defaultEmpty     →  border borderDefault, placeholder visibile
defaultFilled    →  border borderDefault, testo visibile
focused          →  border borderFocus 2px, label animata verso l'alto
error            →  border borderError, messaggio errore sotto
success          →  border borderSuccess, icona check nel suffix
disabled         →  opacity 0.38, bg neutral-100
readOnly         →  bg neutral-50 subtle, bordo tratteggiato opzionale
loading          →  spinner nel suffix, non editabile
```

##### Anatomia

```
┌─────────────────────────────────────┐
│ Label                                │  ← label sopra il campo
│ ┌─────────────────────────────────┐ │
│ │ [🔍] testo input        [×] [↵] │ │  ← prefix + input + suffix + action
│ └─────────────────────────────────┘ │
│ ⚠ Messaggio di errore               │  ← error/helper sotto
│                          24 / 100   │  ← character counter
└─────────────────────────────────────┘
```

##### Proprietà principali

```dart
class CLTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefix;            // widget o icona
  final Widget? suffix;            // widget o icona
  final String? prefixText;        // es. "€"
  final String? suffixText;        // es. "kg"
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isDisabled;
  final bool isReadOnly;
  final bool isLoading;
  final int? maxLength;
  final bool showCounter;          // mostra "24/100"
  final bool clearable;            // mostra X per svuotare
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final CLSize size;               // default .md
  final String? semanticLabel;
}
```

##### Regole specifiche

- **Label sopra il campo** (non placeholder come label).
- **Floating animation** della label: 200ms easeOut, translate Y + scale quando si entra in focus o si inizia a digitare.
- **Prefix/suffix icon**: size coerente con il size del field (16/18/20/24/28).
- **Character counter**: posizione bottom-right sotto il campo. Colore `textSecondary`, diventa `warning` quando <10% rimanente, `error` oltre il limite.
- **Clearable**: il button X è un `CLIconButton` size xs, appare solo quando il campo ha valore.
- **Disabled**: non mostrare placeholder, solo bg subtle.
- **Autofocus**: solo nel primo campo di un form modal. Mai nella pagina principale.

##### Validation timing

```
On blur        →  default, valida al momento di uscire dal campo
On submit      →  fallback finale, tutti gli errori insieme
On type        →  solo per validazioni utili real-time:
                    - password strength
                    - username disponibile
                    - format check (email, numero)
Mai on focus   →  non mostrare errori entrando nel campo
```

#### 6.1.2 `CLSelect` (Dropdown)

##### Varianti

| Costruttore | Descrizione |
|-------------|-------------|
| `CLSelect()` | Single select standard |
| `CLSelect.multi()` | Multi-select con checkbox |
| `CLSelect.searchable()` | Single con search field |
| `CLSelect.multiSearchable()` | Multi con search field |
| `CLSelect.creatable()` | Permette di creare nuove opzioni |
| `CLSelect.async()` | Opzioni caricate da API |

##### Anatomia del trigger

```
Vuoto:
┌─────────────────────────────────────┐
│ Seleziona...                     ▾  │
└─────────────────────────────────────┘

Singolo selezionato:
┌─────────────────────────────────────┐
│ Opzione selezionata              ▾  │
└─────────────────────────────────────┘

Multi selezionato:
┌─────────────────────────────────────┐
│ 🔵 Opzione 1  🔵 Opzione 2  +3  ▾  │
└─────────────────────────────────────┘
```

##### Chip nel trigger (multi-select)

```
Max chip visibili      →  calcolo dinamico in base alla larghezza disponibile
Chip overflow          →  "+N" come ultimo elemento
Click su "+N"          →  apre il dropdown
Chip removibile        →  X sul chip (size xs), non apre il dropdown
Chip styling           →  labelSm, bg colorPrimarySubtle, border colore primary
Chip max-width         →  ~120px con truncate ellipsis
```

##### Overlay lista opzioni

| Proprietà | Valore |
|-----------|--------|
| Max height | 320px, poi scroll interno |
| Min width | Uguale al trigger (mai più stretta) |
| Posizione | Sotto di default, sopra se non c'è spazio |
| Offset dal trigger | 4px |
| Border radius | `surfaceCard` radius (8px) |
| Shadow | elevation livello 3 |
| Animation apertura | fade + slide 4px verso il basso, 150ms |
| Animation chiusura | fade, 100ms |

##### Voce singola

```
Height        →  CLSize.sm (40px)
Padding H     →  12px
Icona left    →  20px, gap 8px dal testo (opzionale)
Check right   →  20px, solo se selezionata (single)
Subtitle      →  bodySm textSecondary, riga sotto il titolo
Disabilitata  →  opacity 0.38
Hover         →  bg surfaceHover
Selezionata   →  bg colorPrimarySubtle, testo colorPrimary, check visibile
Selected+hover→  bg surfaceHover mixato
```

##### Multi-select: voce con checkbox

```
┌──────────────────────────────────┐
│  ☑  Opzione selezionata          │  ← bg colorPrimarySubtle
│  ☐  Opzione normale              │  ← bg trasparente
│  ☑  Altra selezionata            │  ← bg colorPrimarySubtle
└──────────────────────────────────┘

Checkbox      →  16px, stessa palette di CLCheckbox
Gap           →  8px tra checkbox e testo
Selezione     →  NON chiude il dropdown (contrariamente al singolo)
```

##### Grouped

```
┌──────────────────────────────────┐
│  GRUPPO A                        │  ← label gruppo: labelSm UPPERCASE
│  ──────────────────────────────  │     textSecondary, non cliccabile
│    Opzione 1                     │  ← indent 8px
│    Opzione 2                     │
│                                  │
│  GRUPPO B                        │
│  ──────────────────────────────  │
│    Opzione 3                     │
└──────────────────────────────────┘
```

##### Searchable

```
Search field        →  sticky in cima, auto-focus all'apertura
                       placeholder "Cerca..."
                       border-bottom, no border-radius
Highlight match     →  parte cercata in BOLD nel testo voce
Nessun risultato    →  "Nessun risultato per 'xxx'" centrato, bodySm
Loading async       →  skeleton 3 voci o spinner centrato
Debounce ricerca    →  300ms prima di chiamare API
```

##### Creatable

```
Nessun match trovato    →  mostra "Crea 'xxx'" come prima voce
                           icona [+] a sinistra, testo colorPrimary
Voce creata             →  aggiunta in cima alla lista, selezionata
```

##### Proprietà principali

```dart
class CLSelect<T> extends StatelessWidget {
  final T? value;                     // per single
  final List<T> values;               // per multi
  final List<CLSelectOption<T>> options;
  final List<CLSelectGroup<T>>? groups; // per grouped
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<List<T>>? onMultiChanged;
  final bool isSearchable;
  final bool isCreatable;
  final Future<List<CLSelectOption<T>>> Function(String query)? asyncLoader;
  final bool isDisabled;
  final bool isLoading;
  final CLSize size;
}
```

#### 6.1.3 `CLDatePicker`

##### Varianti

| Costruttore | Descrizione |
|-------------|-------------|
| `CLDatePicker()` | Date picker singola data |
| `CLDatePicker.range()` | Range picker (da/a) |
| `CLDatePicker.month()` | Solo mese/anno |

Componente separato da `CLTextField` perché ha una UI composita (field + calendario).

##### Anatomia

```
┌─────────────────────────────────────┐
│ Data inizio                          │
│ ┌─────────────────────────────────┐ │
│ │ 📅  12/03/2026               ▾ │ │  ← field con icona cal. e chevron
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘

Click sul field apre:
┌─────────────────────┐
│  ← Marzo 2026 →     │  ← header mese, frecce navigazione
│ L M M G V S D       │  ← header giorni
│ ─────────────────── │
│       1  2  3  4  5 │  ← griglia giorni
│  6  7  8  9 10 11 12│
│ 13 14[15]16 17 18 19│  ← oggi evidenziato
│ 20 21 22 23 24 25 26│
│ 27 28 29 30 31      │
│ ─────────────────── │
│ [Oggi]       [OK]   │  ← footer con shortcut
└─────────────────────┘
```

##### Comportamento

```
Input manuale        →  formato it: dd/mm/yyyy con mask automatica
                        formato en: mm/dd/yyyy
                        validazione on blur
Trigger calendario   →  icona a destra, click apre overlay
Chiusura             →  click su data, click fuori, Esc
Range picker         →  2 mesi affiancati (desktop), scroll (mobile)
Shortcut rapidi      →  Oggi, Ieri, Ultimi 7gg, Ultimi 30gg (opzionali)
Disabled dates       →  opacity 0.38, non cliccabili
Min/max date         →  range permesso
```

##### Responsive

| Window size | UI |
|-------------|-----|
| `expanded+` | Overlay con calendario inline |
| `medium` | Overlay con calendario inline |
| `compact` | BottomSheet fullscreen con calendario |

#### 6.1.4 `CLCheckbox`

##### Stati

```
unchecked, checked, indeterminate, disabled
```

##### Animazione

```
unchecked → checked:
  Durata: 150ms
  Scale da 0.8 a 1 + draw del check (stroke animation)
  
indeterminate:
  Linea orizzontale centrata invece del check
  Transizione da checked: fade cross
  
Colore fill  →  colorPrimary di default
               colorError se in form con errore
```

##### Proprietà

```dart
class CLCheckbox extends StatelessWidget {
  final bool? value;                   // null = indeterminate
  final ValueChanged<bool?>? onChanged;
  final String? label;                 // label inline a destra
  final String? description;           // testo secondario sotto la label
  final bool isDisabled;
  final bool hasError;                 // per validation
  final CLSize size;                   // default .sm
}
```

#### 6.1.5 `CLRadio` e `CLRadioGroup`

```dart
class CLRadioGroup<T> extends StatelessWidget {
  final T? value;
  final List<CLRadioOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final Axis direction;                // vertical (default) o horizontal
  final bool isDisabled;
  final CLSize size;
}
```

Visual: cerchio 16px, punto interno 8px quando selezionato.

#### 6.1.6 `CLToggle` (Switch)

```dart
class CLToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? description;
  final bool isDisabled;
  final CLSize size;
}
```

Animazione:
```
Thumb slide    →  200ms easeInOut
Thumb scale    →  1.1x durante drag (opzionale)
Colore track   →  neutral → colorPrimary (on)
                  transizione colore 200ms
Haptic         →  mobile, light impact
```

#### 6.1.7 `CLSlider` e `CLRangeSlider`

```dart
class CLSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final String Function(double)? tooltipBuilder;
  final bool showLabels;               // min/max sotto
  final bool isDisabled;
}
```

Anatomia:
```
Track         →  4px height, bg borderDefault, fill colorPrimary
Thumb         →  20px circle, bg white, shadow elevation 2
                 border 2px colorPrimary
Hover thumb   →  scale 1.2, shadow elevation 3
Active thumb  →  scale 1.1
Tooltip valore→  durante drag, sopra il thumb
                 bg neutral-900, testo white, arrow verso il basso
Step markers  →  dot 4px sulla track (se divisions)
Label min/max →  caption textSecondary, sotto la track agli estremi
```

#### 6.1.8 `CLFileUpload`

##### Varianti

```dart
class CLFileUpload extends StatelessWidget { ... }       // singolo file
class CLMultiFileUpload extends StatelessWidget { ... }  // multipli
```

##### Stati

```
Default:
  Bordo dashed       →  2px, neutral-300, border-radius 8px
  Icona upload       →  24px, textSecondary
  Testo              →  "Trascina qui o clicca per selezionare"
  Subtext            →  caption, "PNG, JPG, PDF fino a 10MB"

Drag over:
  Bordo dashed       →  colorPrimary
  Bg                 →  colorPrimarySubtle
  Icona              →  colorPrimary
  Testo              →  "Rilascia per caricare"

File in lista:
  ┌────────────────────────────────────┐
  │ 📄 documento.pdf    2.4 MB    [×] │
  │ ████████████░░░░   67%            │  ← progress upload
  └────────────────────────────────────┘
  
  Completato:    →  check verde, rimuovi progress bar
  Errore:        →  icona error, testo errore, retry button
  Tipo invalido  →  errore immediato, non entra in lista
  Size eccesso   →  errore immediato
```

##### Mobile

Su `compact` usa sempre il file picker nativo, non drag & drop.

#### 6.1.9 `CLTagInput`

```
Aggiunta tag       →  Enter, virgola, o Tab (configurabile)
Chip styling       →  come CLChip removibile
Duplicato          →  shake animation sul chip esistente + toast errore
Tag invalido       →  chip in stato error, si può rimuovere
Max tag            →  oltre il limite nasconde input o mostra messaggio
Riordinamento      →  drag opzionale
```

```dart
class CLTagInput extends StatelessWidget {
  final List<String> tags;
  final ValueChanged<List<String>>? onChanged;
  final String? Function(String)? validator;
  final int? maxTags;
  final List<String> separators;      // default [',', 'Enter']
  final bool allowDuplicates;
  final String? hint;
  final bool isDisabled;
  final CLSize size;
}
```

#### 6.1.10 `CLOTPInput`

```
Layout          →  N campi separati (tipicamente 4 o 6)
Width singolo   →  48px desktop, 44px mobile
Focus auto      →  si sposta al prossimo campo
Backspace       →  cancella e torna al campo precedente
Paste           →  distribuisce caratteri nei campi automaticamente
Stato error     →  tutti i campi rossi + messaggio sotto
Shake animation →  se codice errato
Auto-submit     →  opzionale, invia quando tutti i campi sono pieni
```

```dart
class CLOTPInput extends StatelessWidget {
  final int length;                    // 4 o 6
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool hasError;
  final bool isDisabled;
  final bool obscureText;              // per PIN code
}
```

#### 6.1.11 `CLRichTextEditor`

##### Toolbar elementi base

```
Formattazione:  Bold, Italic, Underline, Strikethrough
Heading:        H1, H2, H3 (dropdown)
Liste:          Bullet, Numbered
Blocchi:        Quote, Code inline, Code block
Link:           Inserisci / modifica / rimuovi
Media:          Immagine, Video embed
Allineamento:   Sinistra, Centro, Destra
Altro:          Divider, Tabella
```

##### Toolbar styling

```
Altezza     →  40-48px
Bottoni     →  CLIconButton xs con tooltip
Gruppi      →  separati da divider verticali
Sticky      →  sì se editor alto
```

##### Stati formattazione

```
Attivo          →  bg colorPrimarySubtle, icona colorPrimary
Non disponibile →  disabled (es. code dentro code)
```

##### Mobile

```
Toolbar               →  scroll orizzontale
Formattazione selezione →  popup con 3-4 azioni principali
```

##### Markdown shortcuts

```
# space        →  H1
## space       →  H2
### space      →  H3
** testo **    →  bold
* testo *      →  italic
- space        →  bullet
1. space       →  numbered
` codice `     →  inline code
``` code ```   →  code block
> space        →  quote
```

#### 6.1.12 `CLColorPicker`

```
Preset palette      →  12-16 colori predefiniti (griglia 4x4 o 8x2)
                       click per selezionare, check su attivo
Custom picker       →  accordion "Personalizza" espande HSL/RGB
Recent colors       →  ultimi 5-8 colori usati, persistenti
Input valore        →  hex, RGB, HSL
```

Su mobile: BottomSheet.


### 6.2 Actions

#### 6.2.1 `CLButton`

##### Varianti (via enum o named constructor)

| Variante | Uso |
|----------|-----|
| `primary` | CTA principale della pagina/sezione |
| `secondary` | Azione alternativa, enfasi ridotta |
| `ghost` | Azione terziaria, no fill, solo hover |
| `outline` | Azione con bordo, no fill |
| `destructive` | Elimina, reset, revoca (colorError) |

##### Visual per variante (default md)

| Variante | bg default | bg hover | Testo | Border |
|----------|-----------|----------|-------|--------|
| primary | colorPrimary | colorPrimaryHover | textOnPrimary | nessuno |
| secondary | surfaceCard | surfaceHover | textPrimary | borderDefault 1px |
| ghost | transparent | surfaceHover | textPrimary | nessuno |
| outline | transparent | surfaceHover | textPrimary | borderStrong 1px |
| destructive | colorError | colorErrorHover | white | nessuno |

##### Proprietà

```dart
class CLButton extends StatelessWidget {
  final String? label;
  final Widget? icon;                  // icona sinistra
  final Widget? trailingIcon;          // icona destra
  final VoidCallback? onPressed;       // null = disabled
  final CLButtonVariant variant;       // default .primary
  final CLSize size;                   // default .md
  final bool isLoading;
  final bool isFullWidth;              // true per mobile nei form
  final Widget? badge;                 // notifica sovrapposta
  final String? semanticLabel;
  final String? tooltip;               // se disabled, spiega perché
}
```

##### Stato loading

```
Spinner sostituisce il testo  →  NON affianca (evita cambio larghezza)
Spinner size                   →  stessa size dell'icona del button
Width                          →  fixed durante loading
Non interagibile               →  durante loading
Icona                          →  nascosta durante loading
```

##### Button con icona

```
Icon left + label   →  icona a sinistra del testo, gap = size.gap
Label + icon right  →  es. "Salva →" con freccia
Solo icona          →  usare CLIconButton invece
```

##### Button + badge

```
Badge posizionato  →  top-right, offset -4px / -4px (sovrapposto)
Size badge         →  xs, 16-18px
Colore             →  colorError per notifiche, neutral per count generico
```

##### Full width

```
Mobile (compact)   →  button principale nei form è isFullWidth: true
Desktop            →  width auto, mai full width nei form
```

#### 6.2.2 `CLIconButton`

```dart
class CLIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final CLSize size;                   // default .md
  final CLButtonVariant variant;       // default .ghost
  final String? tooltip;               // OBBLIGATORIO per accessibilità
  final Widget? badge;
  final bool isLoading;
  final String semanticLabel;          // OBBLIGATORIO
}
```

> **Regola**: `CLIconButton` **deve** avere `semanticLabel` e dovrebbe avere `tooltip` su desktop.

#### 6.2.3 `CLButtonGroup` / `CLToggleButtonGroup`

```
┌──────────┬──────────┬──────────┐
│  Lista   │  Kanban  │ Tabella  │
└──────────┴──────────┴──────────┘

Bordi:
  Tra i button      →  condivisi, 1px borderDefault
  Primo button      →  border-radius sinistra
  Ultimo button     →  border-radius destra
Stato attivo:
  bg colorPrimary, testo textOnPrimary
Spacing:
  Nessuno tra i button (sembra un unico elemento)
```

```dart
class CLToggleButtonGroup<T> extends StatelessWidget {
  final T? value;                      // selezione singola
  final List<CLToggleOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final CLSize size;
  final bool isDisabled;
}

class CLMultiToggleButtonGroup<T> extends StatelessWidget {
  final List<T> values;                // selezione multipla
  final List<CLToggleOption<T>> options;
  final ValueChanged<List<T>>? onChanged;
  // ...
}
```

#### 6.2.4 `CLSplitButton`

```
┌─────────────┬────┐
│   Azione    │ ▾  │  ← azione principale + dropdown freccia
└─────────────┴────┘

Click label  →  esegue azione principale
Click ▾      →  apre dropdown con azioni alternative
```

#### 6.2.5 `CLFAB` (Floating Action Button)

```dart
class CLFAB extends StatelessWidget {
  final IconData icon;
  final String? label;                 // FAB espanso
  final VoidCallback? onPressed;
  final CLSize size;                   // default .lg
  final String? tooltip;
  final String semanticLabel;
}
```

Comportamento su scroll mobile:

```
Scroll verso il basso  →  FAB si nasconde (translate + fade 200ms)
Scroll verso l'alto    →  FAB riappare
Posizione              →  bottom-right, offset 16px dai bordi + safe area
                          sopra la BottomNav se presente
```

#### 6.2.6 `CLLinkButton`

Testo cliccabile inline.

```dart
class CLLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;                  // es. external link icon
  final bool isExternal;               // apre in nuova tab
  final CLSize? size;                  // null = eredita contesto
}
```

Visual:
```
Testo             →  colore textLink
Underline         →  on hover
Icona external    →  16px, gap 4px, solo se isExternal
```

#### 6.2.7 `CLCopyButton`

```dart
class CLCopyButton extends StatelessWidget {
  final String valueToCopy;
  final CLSize size;                   // default .xs
}
```

Feedback:
```
Click     →  copia negli appunti
            icona cambia da copy a check per 1.5s
            toast "Copiato negli appunti" (opzionale)
```

### 6.3 Data Display

#### 6.3.1 `CLTable` / `CLDataGrid`

Componente più complesso della libreria. Vedi sottosezioni.

##### Anatomia

```
┌──────────────────────────────────────────────────────────┐
│  [Toolbar: ricerca, filtri attivi, azioni bulk, colonne]  │
├──────────────────────────────────────────────────────────┤
│  ┌────┬──────────┬────────┬──────────┐                    │
│  │ ✓  │ Nome ↑  │ Stato  │ Azioni   │  ← Header           │
│  ├────┼──────────┼────────┼──────────┤                    │
│  │ ☐  │ Mario R. │ Active │ [⋯]     │  ← Riga             │
│  │ ☐  │ Luca B.  │ Pending│ [⋯]     │                     │
│  └────┴──────────┴────────┴──────────┘                    │
├──────────────────────────────────────────────────────────┤
│  Totali: €12.450       Pagina 1/5    [<] [>]              │  ← Footer
└──────────────────────────────────────────────────────────┘
```

##### Density

| Density | Row height | Padding V | Font size |
|---------|-----------|-----------|-----------|
| compact | 36px | 8px | bodySm |
| normal | 48px | 12px | bodyMd (default) |
| comfortable | 56px | 16px | bodyMd |

Toggle density nell'overflow menu sopra la tabella. Persistente per utente. Su `< 900px` non usare `compact`.

##### Header colonna

```
NomeColonna  ↑  🔽

↑ / ↓        →  ordinamento attivo, click per invertire
↕            →  ordinamento non attivo (on hover)
🔽 (filter)  →  dot colorato se filtro attivo
Click header →  attiva ordinamento
Click 🔽     →  apre popover filtro
```

##### Filtri per tipo dato

###### Testo
```
Operatori:
  Contiene          (default)
  Non contiene
  Inizia con
  Finisce con
  È uguale a
  È vuoto
  Non è vuoto

UI: Dropdown operatore + TextField valore
    Applicato con Enter o blur
```

###### Numerico
```
Operatori:
  È uguale a
  È diverso da
  Maggiore di / Maggiore o uguale a
  Minore di / Minore o uguale a
  È compreso tra  →  due input min/max
  È vuoto / Non è vuoto
```

###### Data
```
Operatori:
  È uguale a              →  DatePicker
  Prima di / Dopo di      →  DatePicker
  È compreso tra          →  DateRangePicker
  Oggi / Ieri
  Ultimi 7 giorni
  Ultimi 30 giorni
  Questo mese / Mese scorso
  Quest'anno
```

###### Enum / stato
```
UI: Checkbox list nell'overlay
    Ricerca se opzioni >7
    "Seleziona tutto / Deseleziona tutto"
    Badge con count su ogni opzione (es. "Attivo (24)")
```

###### Boolean
```
UI: ToggleButtonGroup orizzontale: Tutti / Sì / No
```

###### Relazione
```
UI: Searchable dropdown con async load
```

##### Filtri attivi — chip bar

```
┌────────────────────────────────────────────────────┐
│ Stato: Attivo ×  Data: ultimi 30gg ×  +Aggiungi  Cancella tutti │
└────────────────────────────────────────────────────┘

Chip filtro attivo:
  Label         →  "NomeColonna: Valore"
  X button      →  rimuove il filtro
  Click chip    →  riapre popover filtro per editarlo
  Styling       →  CLChip removibile neutrale
  
+Aggiungi filtro  →  CLButton ghost sm, apre dropdown colonne filtrabili
Cancella tutti    →  CLLinkButton, solo se filtri attivi
```

##### Selezione righe

```
Nessuna selezione:
  Checkbox header   →  unchecked
  Checkbox riga     →  visibile on hover, nascosto altrimenti
                      su touch: sempre visibili

Selezione parziale:
  Checkbox header   →  indeterminate

Tutta la pagina:
  Checkbox header   →  checked
  Banner sopra      →  "Selezionate 25 righe di questa pagina.
                        Seleziona tutti i 243 risultati"

Tutto il dataset:
  Banner            →  "Selezionati tutti i 243 risultati.
                        Annulla selezione"
```

##### Bulk action toolbar

```
Appare quando >= 1 riga selezionata
Sostituisce o si sovrappone all'header normale

┌──────────────────────────────────────────────┐
│ ✓ 12 selezionati  [Esporta] [Archivia] [⋮]  │
└──────────────────────────────────────────────┘

Count           →  "N selezionati", testo colorPrimary
Azioni          →  max 2-3 button visibili
Overflow ⋮      →  azioni secondarie
Azione destructive → SEMPRE nell'overflow, mai esposta direttamente
Animation       →  slide dall'alto 200ms, fade out al deselect
```

##### Riga espandibile

```
Handle chevron   →  a sinistra del checkbox
Stato chiuso     →  chevron ›
Stato aperto     →  chevron ⌄, animazione rotazione 90° 200ms
Contenuto        →  si espande sotto la riga, padding 16-24px
                   può contenere: dettagli, form, tabella nested
Bg riga aperta   →  leggermente diverso per distinguere
```

##### Azioni su riga

```
Sempre visibili:
  Solo se max 1-2 azioni molto frequenti
  CLIconButton xs, colore textSecondary

On hover (desktop):
  Appaiono con fade 100ms
  Max 2-3 IconButton + menu ⋮

Su touch:
  Sempre visibili (no hover)
  Oppure long press → BottomSheet azioni

Menu contestuale ⋮:
  Lista azioni
  Ultima destructive con colore error + separatore sopra
```

##### Colonne — gestione

```
Toggle visibilità:
  Menu "Colonne" sopra la tabella
  Checkbox per ogni colonna
  Drag handle per riordinare
  Persistenti per utente

Pinned columns:
  Prima colonna (ID/nome) sempre visibile
  Pinned right per azioni
  Opzione "fissa/sfissa" nel menu colonna

Resize:
  Drag sul bordo destro dell'header
  Cursor: SystemMouseCursors.resizeColumn
  Min e max width per colonna
  Doppio click → auto-fit al contenuto
  Persistente per utente
```

##### Row styling

```
Zebra striping     →  Sconsigliato (appesantisce)
                     Opzionale per tabelle molto dense
                     Bg alternato ogni 2 righe con surfacePage

Hover row          →  bg surfaceHover

Active row (click) →  bg colorPrimarySubtle
                     border-left 3px colorPrimary (opzionale)
                     Persistente se drawer dettaglio aperto

Row status         →  bordo sinistro 3-4px colore semantico
                     per indicare stato visivo rapido
                     es. rosso per scaduto, verde per completato

Testo              →  default troncato con ellipsis
                     tooltip con testo completo on hover
                     wrap opzionale per colonne descrizione (max 2-3 righe)
```

##### Inline editing

```
Quando:
  Campi singoli frequentemente modificati
  No validation complesse
  Feedback immediato necessario

Trigger:
  Double click sulla cella
  Click sull'icona edit on hover
  Enter quando riga selezionata

UI durante edit:
  Cella diventa input inline
  Auto-focus e select all
  Save: blur o Enter
  Cancel: Esc
  Validation inline se errore

Multi-cell:
  Tab → prossima cella
  Shift+Tab → precedente
```

##### Footer

```
┌──────────────────────────────────────────────────┐
│ Totale: €124.500    Media: €2.490                 │
├──────────────────────────────────────────────────┤
│ Righe per pagina: [25 ▾]   1-25 di 243   [<][>]  │
└──────────────────────────────────────────────────┘

Totali:
  Solo colonne numeriche
  Allineato a destra come la colonna
  Separatore border-top più spesso

Paginazione:
  Righe per pagina: select [10, 25, 50, 100]
  Info: "Da-A di Totale"
  Frecce prev/next, disabled ai limiti
  Pagine numerate: max 5-7 visibili, ellipsis per altre
```

##### Viste salvate

```
Feature pro della tabella
Salva combinazioni di filtri/sort/colonne

UI:
  Dropdown "Viste" in alto a sx della tabella
  "+ Crea vista" per salvare stato attuale
  Lista viste salvate con nome
  Vista corrente evidenziata
  Menu ⋮ per vista: rinomina, duplica, elimina, imposta default

Vista "Default" o "Tutti" sempre disponibile, non eliminabile
Viste personali vs condivise (se collaborativo)
```

##### Adattamento mobile (compact)

```
Tabella → Lista di card

Desktop:                          Mobile:
┌────┬──────────┬────────┐       ┌─────────────────────┐
│ ✓  │ Nome     │ Stato  │       │ Mario Rossi          │
├────┼──────────┼────────┤  →    │ mario@email.com      │
│ ✓  │ Mario R. │ Active │       │ ● Active        ›   │
└────┴──────────┴────────┘       └─────────────────────┘

Card structure:
  Titolo principale (prima colonna)
  Metadata secondario (2-3 colonne chiave)
  Status badge
  Chevron per apertura dettaglio
  Swipe actions: sinistra destructive, destra primaria
```

##### Stati edge

```
Primo caricamento          →  skeleton tabella intera
Pagina vuota (senza dati)  →  empty state dentro il body
Pagina vuota (con filtri)  →  "Nessun risultato" + "Cancella filtri"
Pagina oltre limite        →  "Pagina non esistente, torna alla prima"
Errore caricamento         →  inline retry nella pagina tabella
```

##### Proprietà principali

```dart
class CLTable<T> extends StatelessWidget {
  final List<T> data;
  final List<CLTableColumn<T>> columns;
  final CLTableController<T>? controller;
  final bool isLoading;
  final bool isSelectable;
  final bool hasBulkActions;
  final List<CLTableBulkAction<T>>? bulkActions;
  final CLTableDensity density;         // .compact, .normal, .comfortable
  final bool isExpandable;
  final Widget Function(T)? expandedBuilder;
  final CLTablePagination? pagination;
  final List<CLTableSavedView>? savedViews;
  final Widget? emptyState;
  final String? searchHint;
  // ...
}
```

#### 6.3.2 `CLKPICard`

```
┌─────────────────────────┐
│  Fatturato mensile   ⓘ  │  ← label + info icon opzionale
│  €124.500               │  ← valore principale, displaySm bold
│  ↑ +12,3% vs mese prec  │  ← trend
│  [sparkline opzionale]  │  ← mini chart
└─────────────────────────┘
```

```dart
class CLKPICard extends StatelessWidget {
  final String label;
  final String value;                   // già formattato
  final CLKPITrend? trend;              // +12,3% colore success/error
  final List<double>? sparklineData;    // mini grafico
  final IconData? icon;
  final VoidCallback? onTap;            // se cliccabile
  final String? infoTooltip;            // spiegazione KPI
}

class CLKPITrend {
  final double percentage;
  final String compareLabel;            // es. "vs mese scorso"
  final CLKPITrendDirection direction;  // .up, .down, .neutral
}
```

Visual trend:
```
Positivo     →  +12,3% colore success, freccia su
Negativo     →  -5,1% colore error, freccia giù
Neutro       →  0% colore textSecondary
```

#### 6.3.3 `CLList` e `CLListItem`

```dart
class CLListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;                // avatar, icon, checkbox
  final List<Widget>? trailing;         // azioni, badge
  final VoidCallback? onTap;
  final bool isSelected;
  final CLSize size;                    // .sm densa, .md con subtitle
}
```

Layout:
```
Senza subtitle:
┌──────────────────────────────────────┐
│ [avatar] Titolo            [actions] │  height: sm (40)
└──────────────────────────────────────┘

Con subtitle:
┌──────────────────────────────────────┐
│ [avatar] Titolo            [actions] │
│          Subtitle                    │  height: md (48-56)
└──────────────────────────────────────┘
```

#### 6.3.4 `CLVirtualList`

Per liste molto lunghe (>1000 elementi). Usa internamente `ListView.builder` con lazy loading.

```dart
class CLVirtualList<T> extends StatelessWidget {
  final Future<List<T>> Function(int page, int pageSize) loader;
  final Widget Function(BuildContext, T) itemBuilder;
  final int pageSize;                   // default 50
  final Widget? emptyState;
  final Widget? errorBuilder;
}
```

#### 6.3.5 `CLTimeline`

```dart
class CLTimeline extends StatelessWidget {
  final List<CLTimelineEvent> events;
  final bool groupByDate;               // "Oggi", "Ieri", "12 gen 2026"
}

class CLTimelineEvent {
  final String title;
  final String? description;
  final DateTime timestamp;
  final CLTimelineStatus status;        // completed, active, pending, error
  final Widget? leading;
  final List<Widget>? actions;
}
```

Visual:
```
Linea verticale sx  →  1-2px, borderDefault
Nodo evento         →  cerchio 12-16px sulla linea
Content gap         →  padding-left 24px dal nodo

Nodo stati:
  Completato  →  filled colorPrimary con check bianco
  Attivo      →  filled colorPrimary + pulse animation
  In attesa   →  outlined neutral
  Errore      →  filled colorError con X
```

#### 6.3.6 `CLCalendar`

```dart
class CLCalendar extends StatelessWidget {
  final CLCalendarView view;            // .month, .week, .day
  final DateTime selectedDate;
  final List<CLCalendarEvent>? events;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<CLCalendarEvent>? onEventTap;
}
```

Responsive:
```
expanded+   →  mese intero
medium      →  settimana
compact     →  giorno, header scrollabile per navigazione
```

#### 6.3.7 `CLKanban`

```dart
class CLKanban<T> extends StatelessWidget {
  final List<CLKanbanColumn<T>> columns;
  final Widget Function(T) cardBuilder;
  final void Function(T, int fromColumn, int toColumn)? onCardMoved;
}
```

Visual:
```
Colonna:
  Header: titolo + count + azioni
  Width: 280-320px fisso
  Bg: surfacePage leggermente diverso da content
  Scroll orizzontale se overflow colonne

Card dentro colonna:
  Bg surfaceCard, shadow elevation 1
  Gap 8-12px tra card
  Max 3 righe visibili per titolo

Drag:
  Ghost card: opacity 0.6
  Drop indicator: linea colorPrimary
  Colonna target: bg colorPrimarySubtle leggero
```

Responsive:
```
expanded+   →  colonne affiancate
medium      →  2 colonne visibili, scroll orizzontale
compact     →  1 colonna per volta, swipe laterale per cambiare
```

#### 6.3.8 `CLTreeView`

```dart
class CLTreeView<T> extends StatelessWidget {
  final List<CLTreeNode<T>> nodes;
  final Widget Function(T) nodeBuilder;
  final Future<List<CLTreeNode<T>>> Function(T)? lazyLoader;
  final Set<T>? selectedNodes;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final bool isMultiSelect;
  final bool hasCheckboxes;
}
```

Visual:
```
Indentazione       →  16-20px per livello
Icona chevron      →  20px, ruota 90° quando aperto
Animation apri     →  expand verticale 200ms
Icona tipo nodo    →  opzionale, a sx del label
Lazy load          →  spinner accanto al label durante fetch
Check tree         →  checkbox con stato indeterminate per parent
```


### 6.4 Navigation (componenti)

#### 6.4.1 `CLSidebar`

Vedi [Sezione 5](#5-layout-shell-e-navigazione) per pattern completo. Qui solo l'API.

```dart
class CLSidebar extends StatelessWidget {
  final String? logo;                   // asset path
  final String? logoCompact;            // asset path (versione ridotta)
  final List<CLNavItem> items;
  final CLNavItem? activeItem;
  final ValueChanged<CLNavItem>? onItemTap;
  final bool isCollapsed;
  final VoidCallback? onCollapseToggle;
  final CLSidebarFooter? footer;        // profilo utente, settings
  final CLWorkspaceSwitcher? workspaceSwitcher;
}

class CLNavItem {
  final String label;
  final IconData icon;
  final String? route;
  final List<CLNavItem>? children;      // L2 / L3
  final int? badgeCount;
  final bool hasBadgeDot;
}
```

#### 6.4.2 `CLNavigationRail`

Sidebar stretta con solo icone (per window size `medium`).

```dart
class CLNavigationRail extends StatelessWidget {
  final List<CLNavItem> items;
  final CLNavItem? activeItem;
  final ValueChanged<CLNavItem>? onItemTap;
}
```

#### 6.4.3 `CLBottomNav`

```dart
class CLBottomNav extends StatelessWidget {
  final List<CLBottomNavItem> items;   // max 5
  final int activeIndex;
  final ValueChanged<int>? onItemTap;
}

class CLBottomNavItem {
  final String label;
  final IconData icon;
  final int? badgeCount;
}
```

```
Max 5 voci       →  oltre → drawer o voce "Altro"
Icona + label    →  SEMPRE, mai solo icona
Height           →  56-64px + safe area bottom
Active state     →  icona + label colorPrimary
Inactive state   →  icona + label textSecondary
```

#### 6.4.4 `CLAppBar`

Vedi [Sezione 5.8](#58-appbar-tutti-i-breakpoint) per struttura. API:

```dart
class CLAppBar extends StatelessWidget {
  final Widget? leading;                // logo, hamburger, back button
  final Widget? title;                  // testo o breadcrumb
  final CLBreadcrumb? breadcrumb;       // su desktop
  final List<Widget>? actions;
  final Widget? bottom;                 // tabs, filter bar opzionale
  final bool hasScrollElevation;        // shadow appare durante scroll
}
```

#### 6.4.5 `CLTabs`

```dart
class CLTabs extends StatelessWidget {
  final List<CLTab> tabs;
  final int activeIndex;
  final ValueChanged<int>? onTabChanged;
  final Axis direction;                 // .horizontal (default), .vertical
  final CLSize size;                    // default .sm
}

class CLTab {
  final String label;
  final IconData? icon;
  final int? badgeCount;
  final bool hasBadgeDot;
  final bool isDisabled;
}
```

##### Visual

```
Indicator:
  Underline 2px colorPrimary (default)
  Oppure pill bg colorPrimarySubtle
Slide animation:
  Indicator si sposta tra tab, 200ms easeInOut
  Mai teleporta istantaneamente

Con numero:
  "Clienti (24)"
  Count in textSecondary parentesi

Con badge dot:
  Pallino colorError 8px, top-right del tab

Overflow:
  Scroll orizzontale con scroll shadows
  OPPURE dropdown "Altri" per tab nascoste
```

#### 6.4.6 `CLBreadcrumb`

```dart
class CLBreadcrumb extends StatelessWidget {
  final List<CLBreadcrumbItem> items;
  final IconData separator;             // default LucideIcons.chevronRight
  final int? maxVisibleItems;           // troncamento, default 4
}

class CLBreadcrumbItem {
  final String label;
  final VoidCallback? onTap;            // null se attuale
  final IconData? icon;
}
```

```
Separatore    →  chevron › oppure slash /
Troncamento   →  "Home / ... / Pagina attuale"
Click su ...  →  dropdown con livelli nascosti
Ultimo elem.  →  non cliccabile, textPrimary weight 500
```

#### 6.4.7 `CLPagination`

```dart
class CLPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int? totalItems;
  final int pageSize;
  final List<int> pageSizeOptions;     // [10, 25, 50, 100]
  final ValueChanged<int>? onPageChanged;
  final ValueChanged<int>? onPageSizeChanged;
  final bool showPageSize;
  final bool showTotalInfo;            // "1-25 di 243"
}
```

Visual:
```
[<] 1  2  3 ... 18 [>]   Righe: [25 ▾]  1-25 di 243

Pagine numerate:
  Max 5-7 visibili
  Ellipsis per quelle nascoste
  Pagina attuale: bg colorPrimarySubtle
  Frecce prev/next disabled ai limiti
```

#### 6.4.8 `CLStepper`

```dart
class CLStepper extends StatelessWidget {
  final List<CLStep> steps;
  final int activeStep;
  final Axis direction;                 // .horizontal, .vertical
  final ValueChanged<int>? onStepTap;   // null = non cliccabile
}

class CLStep {
  final String title;
  final String? description;
  final CLStepStatus status;            // .upcoming, .active, .completed, .error
  final bool isOptional;
}
```

##### Stati nodo step

```
upcoming    →  cerchio outlined neutral, numero textSecondary
active      →  cerchio filled colorPrimary, numero textOnPrimary
completed   →  cerchio filled colorPrimary con check bianco
error       →  cerchio filled colorError con X bianca
```

##### Responsive

```
expanded+   →  horizontal se <=5 step, altrimenti vertical
medium      →  vertical preferito
compact     →  vertical sempre, con step attivo evidenziato
```

#### 6.4.9 `CLCommandBar` / `CLCommandPalette`

Ricerca azioni globale (Cmd/Ctrl+K).

```dart
Future<T?> showCLCommandPalette<T>({
  required BuildContext context,
  required List<CLCommandGroup> groups,
  String? initialQuery,
});

class CLCommandGroup {
  final String title;
  final List<CLCommand> commands;
}

class CLCommand {
  final String label;
  final IconData? icon;
  final String? context;                // "in CRM / Clienti"
  final String? shortcut;               // "⌘K"
  final VoidCallback onExecute;
}
```

##### Visual

```
Trigger        →  Cmd/Ctrl+K globale
Posizione      →  overlay centrato, top 20% dello schermo
Size           →  max-width 640px, max-height 480px

Struttura:
  Search input in cima       →  auto-focus all'apertura
  Lista risultati sotto       →  raggruppata per categoria
  Footer con hint            →  "↑↓ naviga  ↵ seleziona  esc chiudi"

Categorie di default:
  Azioni recenti       →  top 5 azioni usate di recente
  Pagine               →  naviga alle pagine dell'app
  Azioni              →  crea nuovo, importa, esporta
  Ricerca dati         →  clienti, documenti, ecc.
  Impostazioni         →  scorciatoie a settings

Singolo risultato:
  Icona a sinistra     →  tipo di risultato
  Titolo               →  bodyMd
  Contesto             →  bodySm textSecondary
  Shortcut a destra    →  se l'azione ha un keyboard shortcut

Stati:
  Empty state      →  "Cerca pagine, azioni e dati..."
  Nessun match     →  "Nessun risultato per 'xxx'"
  Loading async    →  skeleton 3 righe
```

#### 6.4.10 `CLNotificationCenter`

```dart
class CLNotificationCenter extends StatelessWidget {
  // Normalmente triggerato da CLIconButton con badge nell'AppBar
  final List<CLNotification> notifications;
  final VoidCallback onMarkAllRead;
  final ValueChanged<CLNotification>? onNotificationTap;
}
```

##### Layout

```
Drawer destra     →  width 400px (desktop)
                     fullscreen (mobile)

Header:
  Titolo "Notifiche"
  Tabs: Tutte / Non lette
  Azione "Segna tutte come lette"

Lista raggruppata per data:  Oggi / Ieri / Questa settimana / Precedenti

Singola notifica:
  Non letta        →  bg colorPrimarySubtle, pallino blu a sx
  Letta            →  bg default, nessun pallino
  Avatar/icona     →  40px a sx
  Titolo + body    →  bodyMd / bodySm textSecondary
  Data relativa    →  caption textSecondary
  Menu ⋮          →  segna come letto, elimina
  Click            →  naviga alla risorsa correlata
  Azione inline    →  CLButton ghost opzionale

Empty state:
  "Nessuna notifica"
  Icona campanella + testo centrato
```

### 6.5 Overlay

#### 6.5.1 `CLModal`

##### API

```dart
Future<T?> showCLModal<T>({
  required BuildContext context,
  String? title,
  String? subtitle,
  required Widget child,
  List<Widget>? actions,
  CLModalSize size = CLModalSize.md,
  bool dismissible = true,
  bool preventDismissOnChanges = false,  // confirm dialog se modifiche
});

enum CLModalSize {
  xs,    // 400px - conferme rapide
  sm,    // 480px - form semplici
  md,    // 560px - form standard (default)
  lg,    // 720px - form complesse, preview
  xl,    // 900px - editor, preview documenti
  full,  // 100% - 48px margini
}
```

##### Struttura interna

```
┌──────────────────────────────────┐
│ Titolo                        ×  │  ← Header sticky, border-bottom
│ Sottotitolo opzionale            │    padding 20-24px
├──────────────────────────────────┤
│                                  │
│  Body con contenuto              │  ← Body scrollabile
│                                  │    padding 24px
│                                  │    max-height: 60vh
│                                  │
├──────────────────────────────────┤
│  [Annulla]            [Conferma] │  ← Footer sticky, border-top
└──────────────────────────────────┘    padding 16-20px
```

##### Scroll

```
Header e footer    →  sempre visibili (sticky)
Body               →  scroll quando contenuto > max-height
Scroll indicator   →  shadow top quando scrollato, shadow bottom se altro contenuto
```

##### Backdrop

```
Colore light   →  neutral-900 opacity 50%
Colore dark    →  neutral-950 opacity 70%
Blur opzionale →  backdrop-filter blur 4px su modal importanti
Click backdrop →  chiude il modal
                  se preventDismissOnChanges → confirm dialog "Vuoi uscire?"
```

##### Responsive

```
expanded+    →  modal centrato con size specifica
medium       →  modal centrato, size maggiore se possibile
compact      →  BottomSheet fullscreen (sostituisce completamente il modal)
```

#### 6.5.2 `CLConfirmDialog`

Helper specifico per conferme.

```dart
Future<bool> showCLConfirm({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Conferma',
  String cancelLabel = 'Annulla',
  CLButtonVariant confirmVariant = CLButtonVariant.primary,
});
```

##### Testi delle azioni

```
❌  "OK" / "Annulla"              →  generico, non descrittivo
✅  "Elimina cliente" / "Torna"   →  descrive l'azione reale

Azione destructive:
  Button primary    →  variant destructive, testo "Elimina"
  Button secondary  →  "Annulla" a sinistra

Azione positiva:
  Button primary    →  variant primary, testo specifico
  Button ghost      →  "Annulla" a sinistra
```

##### Strong confirmation

Per azioni irreversibili molto critiche:

```dart
Future<bool> showCLStrongConfirm({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmationText,     // es. "ELIMINA"
});
```

L'utente deve digitare `confirmationText` per abilitare il button conferma.

#### 6.5.3 `CLDrawer`

```dart
void showCLDrawer({
  required BuildContext context,
  required Widget child,
  CLDrawerSide side = CLDrawerSide.right,  // .left, .right
  double width = 400,
  bool dismissible = true,
});
```

Responsive:
```
expanded+    →  overlay semi-trasparente a lato, contenuto rimane visibile
medium       →  push del contenuto a lato (opzionale)
compact      →  fullscreen, sostituisce il contenuto
```

#### 6.5.4 `CLTooltip`

```dart
class CLTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final CLTooltipPosition position;     // .auto, .top, .bottom, .left, .right
  final Duration delay;                 // default 400ms
  final bool isRich;                    // con titolo + body + link
  final String? title;                  // per rich
}
```

##### Visual

```
Bg              →  neutral-900 (light) / neutral-100 (dark)
Testo           →  white (light) / neutral-900 (dark)
Typography      →  bodySm
Padding         →  8px 12px
Border radius   →  6px
Shadow          →  elevation livello 5
Max width       →  320px con word-wrap
Arrow           →  piccola freccia verso l'elemento trigger
Delay           →  400ms prima di apparire
Dismiss         →  al mouse leave o long press (mobile)
```

##### Quando NON usare tooltip

```
❌  Su touch device (non accessibili senza long press)
❌  Per informazioni essenziali (user non sa che c'è)
❌  Su elementi non interattivi
✅  Per spiegazioni rapide su icon button
✅  Per testo troncato (tooltip con testo completo)
✅  Per shortcut da tastiera
```

#### 6.5.5 `CLPopover`

Contenuto più ricco di un tooltip, triggerato da click.

```dart
class CLPopover extends StatelessWidget {
  final Widget trigger;
  final Widget content;
  final CLPopoverPosition position;
  final bool showArrow;
  final bool dismissOnOutsideTap;
}
```

Responsive:
```
expanded+    →  popover con arrow, overlay
compact      →  BottomSheet
```

#### 6.5.6 `CLContextMenu`

Menu triggerato da click destro (desktop) o long press (mobile).

```dart
void showCLContextMenu({
  required BuildContext context,
  required Offset position,              // da TapDownDetails
  required List<CLContextMenuItem> items,
});

class CLContextMenuItem {
  final String label;
  final IconData? icon;
  final String? shortcut;
  final VoidCallback onSelect;
  final bool isDestructive;              // colore error + separator sopra
  final bool isDisabled;
}
```

#### 6.5.7 `CLBottomSheet` (mobile specifico)

```dart
Future<T?> showCLBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool isDismissible = true,
  bool isScrollControlled = true,        // per contenuti lunghi
  double? initialSize,                   // 0-1, percentuale altezza
});
```

Visual:
```
Handle bar     →  in cima, 40x4px neutral-300
                  sempre visibile
Border radius  →  16px solo top
Swipe down     →  chiude (se dismissible)
Max height     →  90vh
Drag handle    →  opzionale per resize
```


### 6.6 Feedback

#### 6.6.1 `CLToast`

```dart
void showCLToast({
  required BuildContext context,
  required String message,
  CLToastVariant variant = CLToastVariant.info,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
  bool dismissible = true,
});

enum CLToastVariant { success, error, warning, info }
```

##### Anatomia

```
┌────────────────────────────────────────┐
│ ✓  Messaggio breve          [Azione] × │
└────────────────────────────────────────┘

Icona           →  16px, colore semantico
Testo           →  bodyMd, max 2 righe poi tronca
Azione          →  CLLinkButton, una sola, testo breve
Dismiss X       →  sempre presente
Progress bar    →  opzionale, in fondo al toast, tempo rimanente
                   pausa on hover (desktop)
```

##### Durate auto-dismiss

```
Success      →  4000ms
Info         →  5000ms
Warning      →  6000ms
Error        →  non si chiude automaticamente (richiede azione)
Con azione   →  8000ms
```

##### Stack multipli

```
Posizione desktop    →  bottom-right, offset 24px dai bordi
Posizione mobile     →  bottom-center, sopra la BottomNav + safe area

Stack:
  Nuovi toast        →  appaiono in cima allo stack
  Max visibili       →  3, quello successivo comprime i precedenti
  Compressed         →  toast vecchi si rimpiccioliscono e si sovrappongono
  Hover su stack     →  si espandono tutti mostrando lo stack completo

Gap tra toast        →  8px
```

#### 6.6.2 `CLAlert`

Alert inline o banner.

```dart
class CLAlert extends StatelessWidget {
  final CLAlertVariant variant;         // success, error, warning, info
  final String? title;
  final String? message;
  final IconData? icon;                 // override icona default
  final List<Widget>? actions;          // button o link
  final VoidCallback? onDismiss;        // null = non dismissible
  final bool isBanner;                  // true = full width pagina
}
```

##### Visual

```
┌────────────────────────────────────────┐
│ ⓘ  Titolo alert                    [×] │  ← icon + title + close
│    Messaggio dettagliato...             │
│    [Azione]                             │  ← actions opzionali
└────────────────────────────────────────┘

Colori per variant:
  Success     →  bg colorSuccessSubtle, border colorSuccess, icona colorSuccess
  Error       →  bg colorErrorSubtle, border colorError, icona colorError
  Warning     →  bg colorWarningSubtle, border colorWarning, icona colorWarning
  Info        →  bg colorInfoSubtle, border colorInfo, icona colorInfo

Border:
  Left 4px variant colore    →  per alert inline
  Top/bottom 1px             →  per banner full width

Padding:
  Inline     →  16px
  Banner     →  12px H, padding pagina
```

##### Banner vs inline

```
Banner (isBanner: true):
  Full width della pagina
  Sotto l'AppBar (sticky opzionale)
  Usato per: annunci globali, modalità offline, trial scaduto

Inline (default):
  Dentro un contenitore
  Width del contenitore
  Usato per: messaggi contestuali in form, pagine, sezioni
```

#### 6.6.3 `CLProgressBar` / `CLCircularProgress`

##### `CLProgressBar` (lineare)

```dart
class CLProgressBar extends StatelessWidget {
  final double? value;                  // 0-1, null = indeterminate
  final double height;                  // default 4
  final Color? color;                   // default colorPrimary
  final String? label;                  // "Upload in corso..."
  final bool showPercentage;            // "67%"
}
```

##### `CLCircularProgress`

```dart
class CLCircularProgress extends StatelessWidget {
  final double? value;                  // 0-1, null = indeterminate
  final CLSize size;                    // default .md
  final Color? color;
  final double? strokeWidth;
  final Widget? centerChild;            // per mostrare percentuale o icona
}
```

#### 6.6.4 `CLSkeleton`

```dart
class CLSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final CLSkeletonVariant variant;      // .text, .rect, .circle
}

// Named constructors
class CLSkeleton {
  CLSkeleton.text({this.width, this.height = 16});    // riga di testo
  CLSkeleton.rect({this.width, this.height});         // rettangolo generico
  CLSkeleton.circle({required double size});          // avatar
  CLSkeleton.card({this.width, this.height = 120});   // card placeholder
  CLSkeleton.tableRow({int columns = 4});             // riga tabella
}
```

##### Regole di fedeltà

```
Skeleton NON è un rettangolo grigio generico.
Skeleton REPLICA la struttura reale:
  - Avatar tondo dove c'è un avatar
  - Linee di diversa lunghezza per il testo
  - Pill per badge
  - Rettangoli della stessa altezza delle righe tabella
  - Grafici con placeholder di barre/linee

Animazione:
  Shimmer gradient che scorre da sinistra a destra
  Loop 1.5s
  Colore base: neutral-200 (light) / neutral-700 (dark)
  Colore highlight: neutral-100 (light) / neutral-600 (dark)

Transizione skeleton → contenuto:
  Fade cross 200ms
  Mai swap istantaneo
  Dimensioni identiche per evitare layout shift
```

##### Loading delay intelligente

```
< 300ms        →  nessun loader, risultato diretto
300ms - 1s     →  skeleton/spinner
> 1s           →  skeleton + messaggio contesto
> 5s           →  skeleton + "Sta impiegando più del solito..."
> 15s          →  timeout error con retry

Implementazione:
  setTimeout 300ms prima di mostrare loader
  Se risposta arriva prima, cancella timeout
```

#### 6.6.5 `CLSpinner`

```dart
class CLSpinner extends StatelessWidget {
  final CLSize size;                    // default .md
  final Color? color;
}
```

Semplice indeterminate loader. Usato quando skeleton non è appropriato (es. dentro un button).

#### 6.6.6 `CLEmptyState`

```dart
class CLEmptyState extends StatelessWidget {
  final Widget? illustration;           // widget custom (Image, Icon, SVG)
  final IconData? icon;                 // alternativa più semplice
  final String title;
  final String? description;
  final List<Widget>? actions;          // CLButton opzionali
  final CLEmptyStateVariant variant;    // .noData, .noResults, .noPermission, .error
}
```

##### Tre varianti principali

###### No data (primo accesso)
```
┌──────────────────────────┐
│      [illustrazione]     │  ← 120px, colore colorPrimary subtle
│                          │
│  Nessun cliente ancora   │  ← headingSm, textPrimary
│                          │
│  Aggiungi il tuo primo   │  ← bodyMd textSecondary, max 2 righe
│  cliente per iniziare    │
│                          │
│     [+ Crea cliente]     │  ← CLButton primary md
└──────────────────────────┘
```

###### No results (dopo ricerca/filtro)
```
┌──────────────────────────┐
│      [icona search]      │  ← icona semplice, 48px, neutral
│                          │
│  Nessun risultato        │  ← headingSm
│  per "mario rossi"       │
│                          │
│  Prova con termini       │  ← bodyMd textSecondary
│  diversi o rimuovi       │
│  i filtri attivi         │
│                          │
│   [Cancella filtri]      │  ← CLButton ghost o link
└──────────────────────────┘
```

###### No permission
```
┌──────────────────────────┐
│    [icona lucchetto]     │  ← 48px, neutral
│                          │
│  Accesso non             │  ← headingSm
│  autorizzato             │
│                          │
│  Non hai i permessi      │  ← bodyMd textSecondary
│  per visualizzare        │
│  questa sezione          │
│                          │
│   [Contatta l'admin]     │  ← CLButton ghost
└──────────────────────────┘
```

##### Regole

```
Illustrazione  →  per onboarding, primo accesso, azioni emotive
Icona semplice →  per stati funzionali, no results, errori
Testo titolo   →  max 4-5 parole, specifico
Testo body     →  max 2 righe, spiega cosa fare
CTA            →  max 1-2 (primaria + secondaria ghost)
Centrato       →  verticalmente e orizzontalmente
Min height     →  240px per non sembrare schiacciato
```

#### 6.6.7 `CLErrorState`

Variante specifica per errori (404, 500, crash, ecc.).

```dart
class CLErrorState extends StatelessWidget {
  final CLErrorStateVariant variant;    // .notFound, .serverError, .network, .generic
  final String? title;                  // override default
  final String? description;            // override default
  final VoidCallback? onRetry;
  final VoidCallback? onReport;         // segnala problema
}
```

### 6.7 Indicators

#### 6.7.1 `CLBadge`

```dart
class CLBadge extends StatelessWidget {
  // ...
}

// Named constructors
CLBadge.dot({Color? color})              // solo pallino 8px
CLBadge.count({required int count, int? max})  // numerico, "9+" se > max
CLBadge.text({required String text})     // testo arbitrario
```

##### Varianti stile

```
Filled      →  bg colore pieno, testo contrast
Subtle      →  bg colore 15% opacity, testo colore pieno
Outlined    →  no bg, border colore, testo colore
Dot         →  solo pallino colorato, no testo
```

##### Posizionamento

```
Sovrapposto (con icon/avatar):
  Top-right, offset -4px / -4px
  Border 2px surfaceCard per stacco visivo
  
Inline:
  Allineato al testo con gap 4-6px
```

#### 6.7.2 `CLChip` / `CLTag`

```dart
class CLChip extends StatelessWidget { ... }

// Named constructors
CLChip.readonly({required String label, Color? color})
CLChip.removable({required String label, VoidCallback? onRemove})
CLChip.selectable({required String label, required bool isSelected, VoidCallback? onTap})
```

##### Visual

```
Default:
  Height      →  CLSize.xs (32px) o sm (40px)
  Padding H   →  12px
  Font        →  labelSm
  Border rad  →  pill (height/2) OR 6px (quadrato)
  
Removable:
  X icon right   →  16px, gap 4px
  
Selectable:
  Not selected   →  bg neutral-100, border borderDefault
  Selected       →  bg colorPrimarySubtle, testo colorPrimary, check icon left

Custom color tag:
  Bg             →  colore tag a opacity 15%
  Border         →  colore tag a opacity 30%
  Testo          →  colore tag 100% (o scuro se bg troppo chiaro)
  Dot colorato   →  opzionale, a sx del testo
```

#### 6.7.3 `CLStatusBadge`

```dart
class CLStatusBadge extends StatelessWidget {
  final String label;
  final CLStatusType status;            // .active, .pending, .error, .neutral, custom
  final bool hasDot;                    // pallino prima del testo
}
```

Esempi:
```
● Active    (dot success)
● Pending   (dot warning)
● Error     (dot error)
● Archived  (dot neutral)
```

#### 6.7.4 `CLAvatar`

##### Named constructors

```dart
class CLAvatar extends StatelessWidget {
  // ...
}

CLAvatar.image({required String imageUrl, CLAvatarSize size})
CLAvatar.initials({required String name, CLAvatarSize size})
CLAvatar.placeholder({IconData? icon, CLAvatarSize size})
```

##### Size

```dart
enum CLAvatarSize {
  xs(20),    // chip, lista densa
  sm(28),    // lista, tabella
  md(36),    // default, header item
  lg(48),    // card, dettaglio
  xl(64),    // profilo, hero
  xxl(96);   // pagina profilo

  final double size;
  const CLAvatarSize(this.size);
}
```

##### Fallback gerarchico

```
1. Immagine utente (se disponibile)
2. Iniziali (da nome cognome) su bg colorato generato
3. Icona generica (se nessun nome)
```

##### Iniziali

```
1 parola ("Mario")         →  "M"
2+ parole ("Mario Rossi")  →  "MR" (prima + ultima iniziale)
Max 2 caratteri            →  mai 3
Uppercase                  →  sempre
Font                       →  label, weight 600, white o dark (contrasto con bg)
```

##### Bg colore generato

```
Algoritmo       →  hash(userId o email) % N colori palette
Palette         →  8-12 colori pastello, consistenti col design
Stesso utente   →  sempre stesso colore ovunque nell'app
```

##### Presence indicator

```
Pallino in basso a destra sovrapposto
Size: 25% dell'avatar
Border: 2px surfaceCard per staccarlo

Colori:
  Online    →  colorSuccess
  Away      →  colorWarning
  Busy      →  colorError
  Offline   →  neutral-400
```

#### 6.7.5 `CLAvatarGroup`

Stack di avatar sovrapposti.

```dart
class CLAvatarGroup extends StatelessWidget {
  final List<CLAvatarData> avatars;
  final int maxVisible;                 // default 3-5
  final CLAvatarSize size;
  final VoidCallback? onTap;            // click su gruppo
}
```

```
Overlap          →  -8px tra un avatar e il successivo
Border           →  2px surfaceCard su ciascun avatar
Ordine z-index   →  primo sopra, ultimo sotto
Overflow         →  "+N" come ultimo elemento
                    stesso size, bg neutral-200, testo neutral-700
Tooltip hover    →  nome completo su ciascun avatar
```

#### 6.7.6 `CLTrendIndicator`

```dart
class CLTrendIndicator extends StatelessWidget {
  final double percentage;              // negativo per down
  final String? compareLabel;           // "vs mese scorso"
  final CLTrendDirection direction;     // .up, .down, .neutral (auto da percentage)
  final CLSize size;
}
```

Visual:
```
↑ +12,3%       →  success green, freccia su
↓ -5,1%        →  error red, freccia giù
— 0%           →  neutral, trattino
```

#### 6.7.7 `CLProgressRing`

```dart
class CLProgressRing extends StatelessWidget {
  final double value;                   // 0-1
  final double size;                    // width = height
  final double strokeWidth;
  final Color? color;
  final String? centerText;             // es. "67%"
  final Widget? centerChild;
}
```


### 6.8 Layout

#### 6.8.1 `CLCard`

##### Named constructors

```dart
CLCard({Widget child, EdgeInsets? padding})                // base
CLCard.clickable({Widget child, VoidCallback onTap})       // hover + scale
CLCard.collapsible({Widget header, Widget body})           // accordion singolo
CLCard.withHeader({Widget? header, Widget? footer, Widget body})
CLCard.withMedia({Widget media, Widget body})              // con immagine/video top
```

##### Visual base

```
Bg              →  surfaceCard
Border          →  1px borderDefault (opzionale, per stile minimal)
Border radius   →  8-12px
Padding         →  s6 (24) desktop, s4 (16) mobile
Shadow          →  elevation livello 1
```

##### Stati

```
Default         →  shadow 1, border subtle
Hover (clickable) →  shadow 2, elevation aumenta
Pressed         →  scale 0.99
Selected        →  border colorPrimary 2px, bg colorPrimarySubtle leggero
Loading         →  skeleton interno
```

##### Header e footer

```dart
CLCard.withHeader(
  header: CLCardHeader(
    title: 'Titolo card',
    subtitle: 'Sottotitolo',
    actions: [CLIconButton(...)],
    leading: CLAvatar(...),
  ),
  footer: CLCardFooter(
    actions: [CLButton(...)],
  ),
  body: ...,
)
```

Visual header:
```
┌─────────────────────────────────────┐
│ [avatar] Titolo              [⋮]   │  ← leading + title + actions
│          Sottotitolo                │
├─────────────────────────────────────┤
│                                     │
│  body                               │
│                                     │
└─────────────────────────────────────┘
```

#### 6.8.2 `CLDivider`

```dart
class CLDivider extends StatelessWidget {
  final Axis direction;                 // .horizontal (default), .vertical
  final double thickness;               // default 1
  final Color? color;                   // default borderDefault
  final String? label;                  // testo centrato nella linea
  final bool isDashed;                  // linea tratteggiata
}
```

Varianti:
```
Orizzontale semplice   →  1px borderDefault, spesso full width
Orizzontale con label  →  linea + testo centrato ("OPPURE", "o")
Verticale              →  1px, height fissa, tra gruppi inline
Spessore variabile     →  2-3px per sezioni importanti
Tratteggiato           →  drop zone, placeholder, confini informali
```

#### 6.8.3 `CLAccordion`

```dart
class CLAccordion extends StatelessWidget {
  final List<CLAccordionItem> items;
  final bool allowMultiple;             // più aperti contemporaneamente
  final Set<int>? initiallyOpen;
}

class CLAccordionItem {
  final Widget header;
  final Widget body;
  final IconData? icon;
}
```

Animazione:
```
Apertura        →  expand verticale 200ms easeOut
Chiusura        →  collapse verticale 150ms easeIn
Freccia         →  rotazione 90° sincrona con l'animazione
Contenuto       →  fade in durante l'espansione
Overflow        →  hidden durante l'animazione
```

#### 6.8.4 `CLSection`

Contenitore con titolo per organizzare sezioni di una pagina.

```dart
class CLSection extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? action;                 // es. "Vedi tutti", CLLinkButton
  final Widget child;
  final EdgeInsets? padding;
}
```

Visual:
```
Titolo sezione                                 [Vedi tutti →]
Descrizione opzionale sotto il titolo
──────────────────────────────────────────────────────────── (divider opz.)

   [contenuto della sezione]
```

#### 6.8.5 `CLShell`

Widget top-level che gestisce il layout shell completo (sidebar + header + content).

```dart
class CLShell extends StatelessWidget {
  final CLSidebarConfig sidebar;
  final CLAppBar? appBar;
  final Widget body;
  final bool adaptToWindowSize;         // default true
}
```

Responsabile di:
- Decidere layout in base a `context.windowSize`
- Animare transizioni tra layout quando l'utente trascina la finestra
- Preservare stato durante resize
- Gestire safe area mobile


---

## 7. Pattern UX Trasversali

### 7.1 Form Management

#### 7.1.1 Stati di un campo

```
defaultEmpty     →  border borderDefault, placeholder visibile
focused          →  border borderFocus 2px, label animata su
filled           →  border borderDefault, label su, testo visibile
error            →  border borderError, messaggio sotto in rosso
success          →  border borderSuccess, check icon nel suffix
disabled         →  opacity 0.38, non interagibile
readOnly         →  bg subtle, no focus border
loading          →  spinner nel suffix, non editabile
```

#### 7.1.2 Timing validation (ricapitolo)

```
On blur         →  default, migliore per UX
On submit       →  fallback finale, tutti errori insieme
On type         →  solo per validazioni real-time utili (password strength, username check)
Mai on focus    →  non mostrare errori entrando nel campo
```

#### 7.1.3 Anatomia messaggio errore

```
┌─────────────────────────────┐
│ Email                        │
│ mario@                       │
└─────────────────────────────┘
  ⚠ Inserisci un indirizzo     ← icon + testo error
    email valido                  caption (11sp), textError
                                 padding-top s1
```

Formato messaggio:
```
Cosa è andato storto       →  "Email non valida"
Perché                     →  "Manca il simbolo @"
Come risolvere             →  "Inserisci un'email tipo mario@esempio.com"
```

#### 7.1.4 Form layout

| Pattern | Quando |
|---------|--------|
| Single column | Sempre su compact/medium, form semplici |
| Two column | Expanded+, campi correlati (nome + cognome) |
| Inline label | Tabelle, form dense, spazio limitato |
| Floating label | Material style, form standalone |
| Section divisa | Form lunghe, usa CLSection o CLStepper |

#### 7.1.5 Regole layout form

```
Label sopra il campo             →  più leggibile, più spazio
Campi correlati affiancati       →  nome+cognome, cap+città (solo expanded+)
Azioni form in fondo             →  primary a destra, secondary a sinistra
Required indicator               →  asterisco rosso dopo la label (* Nome)
Helper text                      →  sotto il campo, caption, textSecondary
Max-width form pagina            →  720px centrato (non full width)
```

### 7.2 Autosave

#### 7.2.1 Indicatore stato

Posizionato in alto a destra del form o header entità:

```
"Salvataggio..."          →  spinner + testo, durante save
"Salvato"                 →  check + testo, 2s poi sparisce
"Errore di salvataggio"   →  icona + testo, rimane visibile con retry
"Modifiche non salvate"   →  pallino + testo, appare dopo edit
```

#### 7.2.2 Debounce

```
Debounce         →  salva dopo 1s di inattività dall'ultima modifica
Salvataggio manuale →  Cmd/Ctrl+S forza salvataggio immediato
Offline          →  accoda modifiche, salva quando torna online
```

#### 7.2.3 Stato "pending save" per campo singolo

Oltre all'indicatore globale, ogni campo può avere:

```
Campo con modifica non salvata    →  dot arancione nel suffix
Campo in salvataggio              →  spinner nel suffix
Campo salvato                     →  check verde 2s poi sparisce
Campo con errore sync             →  icona error + tooltip con errore
```

### 7.3 Unsaved changes guard

Prima di chiudere modal o navigare via con modifiche non salvate:

```
Tipo           →  CLConfirmDialog
Testo          →  "Hai modifiche non salvate. Vuoi uscire comunque?"
Button         →  "Resta" (primary) + "Esci senza salvare" (destructive)
Badge visivo   →  dot accanto al titolo della pagina o tab browser
Titolo browser →  "• Nome cliente" con pallino prefisso
```

### 7.4 Undo pattern

#### 7.4.1 Toast con undo

```
Dopo azioni reversibili (elimina, sposta, archivia):
  Toast con CLLinkButton "Annulla"
  Durata toast: 8s (doppio dello standard)
  Dopo undo: toast "Azione annullata" 2s

Esempi:
  "Cliente eliminato. [Annulla]"
  "Task spostato. [Annulla]"
  "Elemento archiviato. [Annulla]"
```

#### 7.4.2 Cronologia globale (solo editor complessi)

```
Cmd/Ctrl+Z       →  undo
Cmd/Ctrl+Shift+Z →  redo
Cmd/Ctrl+Y       →  redo (Windows)

Solo in editor/form con cronologia esplicita (rich text editor, disegni)
```

### 7.5 Confirmation patterns

#### 7.5.1 Livelli di conferma

| Livello | Metodo | Quando |
|---------|--------|--------|
| Light | Toast con undo | Eliminazione singolo elemento |
| Medium | `showCLConfirm()` | Eliminazione multipla, azioni con impatto |
| Strong | `showCLStrongConfirm()` (typing) | Eliminazioni definitive, azioni irreversibili |

#### 7.5.2 Quando richiedere conferma

```
✅ Servono:
  Azioni destructive          →  elimina, reset, revoca
  Azioni irreversibili        →  invia fattura, chiudi mese
  Azioni costose              →  invia email a 500 clienti
  Cambi di stato significativi →  approva, pubblica

❌ Non servono:
  Azioni reversibili (con undo)
  Modifiche che vengono salvate
  Navigazione
```

### 7.6 Drag and drop

#### 7.6.1 Elementi draggabili

```
Handle visivo      →  icona ⋮⋮ o ≡, appare on hover (desktop)
                      sempre visibile su touch
Cursor             →  grab / grabbing durante drag
```

#### 7.6.2 Ghost element

```
Opacity 0.6
Shadow elevation 4
Ruotato 2° per feedback visivo
Segue cursore con leggero offset
```

#### 7.6.3 Drop zone

```
Default                →  nessun indicatore
Drag over valida       →  bg colorPrimarySubtle, border dashed colorPrimary
Drag over non valida   →  bg colorErrorSubtle, cursor not-allowed
```

#### 7.6.4 Drop line (inserimento tra elementi)

```
Linea orizzontale 2px colorPrimary
Appare tra gli elementi durante hover
Gap 4px sopra/sotto la linea
```

#### 7.6.5 Feedback post-drop

```
Elemento in nuova posizione    →  pulse bg colorPrimarySubtle per 800ms
Toast conferma opzionale       →  "Spostato in X" con undo
```

### 7.7 Keyboard shortcuts

#### 7.7.1 Convenzioni globali

| Shortcut | Azione |
|----------|--------|
| Cmd/Ctrl + K | Command palette |
| Cmd/Ctrl + / | Lista shortcut disponibili |
| Cmd/Ctrl + S | Salva (anche se autosave) |
| Cmd/Ctrl + Z | Undo |
| Cmd/Ctrl + Shift + Z | Redo |
| Esc | Chiudi modal/dropdown/popover |
| ? | Help contestuale |

#### 7.7.2 Navigazione liste/tabelle

| Shortcut | Azione |
|----------|--------|
| ↑ ↓ | Muovi selezione tra righe |
| Enter | Apri elemento selezionato |
| Space | Toggle selezione (checkbox) |
| Cmd/Ctrl + A | Seleziona tutto |
| Shift + click | Selezione range |

#### 7.7.3 Modal/form

| Shortcut | Azione |
|----------|--------|
| Tab | Prossimo campo |
| Shift + Tab | Campo precedente |
| Enter | Submit (se nel form) |
| Esc | Chiudi/Annulla |

#### 7.7.4 Visualizzazione shortcut

```
Menu items       →  badge a destra con shortcut "⌘K"
Tooltip          →  mostra shortcut tra parentesi "Salva (⌘S)"
Command palette  →  shortcut accanto al nome azione
Help overlay     →  "?" mostra lista completa shortcut della pagina
```

### 7.8 Stato UI per ruoli/permessi

#### 7.8.1 Nascondere vs disabilitare

```
Nascondi    →  l'utente non deve sapere che esiste
               es. funzioni di un piano superiore (mostra CTA upgrade)

Disabilita  →  l'utente sa che esiste ma non può usarlo ora
               es. bottone salva prima di riempire i campi obbligatori
               es. azione non permessa per il suo ruolo (spiega perché)
```

#### 7.8.2 Tooltip obbligatorio su disabled per permessi

```
Testo chiaro e specifico:
  "Non hai i permessi per questa azione"
  "Disponibile nel piano Business"
  "Richiede l'approvazione dell'admin"
```

#### 7.8.3 Stato di accesso

```dart
enum CLAccessState {
  allowed,                     // mostra normale
  disabledNoPermission,        // disabled + tooltip spiegazione
  disabledUpgrade,             // disabled + CTA upgrade
  hidden,                      // non rendererizzato
}

// I componenti accettano opzionalmente
CLButton(
  label: 'Esporta',
  access: CLAccessState.disabledNoPermission,
  accessReason: 'Richiede ruolo admin',
)
```

### 7.9 Async patterns & stati pagina

#### 7.9.1 Stati di una pagina

```
Loading     →  skeleton dell'intera pagina, mai spinner centrato
Empty       →  CLEmptyState con CTA
Error       →  CLErrorState con messaggio + retry
Success     →  contenuto normale
Refreshing  →  contenuto visibile + indicatore sottile in cima
```

#### 7.9.2 Caricamento progressivo

```
Pagina dashboard:
  Render header e sidebar immediato
  KPI primi (API veloce)
  Grafici dopo (API medio)
  Tabella ultima (API lento)

Ogni sezione con il suo skeleton indipendente.
L'utente vede contenuto progressivamente, non tutto insieme.
```

#### 7.9.3 Ottimistic update

```
L'utente esegue un'azione  →  aggiorna UI immediatamente
                           →  chiama API in background
                           →  se API fallisce → rollback + toast errore
                           →  se API succede → niente (UI già aggiornata)

Usare per:
  Toggle
  Delete singolo
  Status change
  Drag & drop
  Like/reaction

NON usare per:
  Creazione con ID dal server
  Pagamenti
  Operazioni finanziarie critiche
  Workflow che dipendono da risposta server
```

#### 7.9.4 Paginazione async

| Pattern | Quando |
|---------|--------|
| Pagination numerata | Tabelle, risultati di ricerca |
| Load more button | Liste, feed |
| Infinite scroll | Feed social, liste molto lunghe |
| Cursor-based | Dati real-time, evita duplicati |

#### 7.9.5 Gestione errori di rete

```
Errore temporaneo   →  toast + retry automatico silenzioso (max 3 volte)
Errore persistente  →  CLErrorState con retry button manuale
401 unauthorized    →  redirect al login (dopo modal warning sessione scaduta)
403 forbidden       →  CLErrorState "Non hai i permessi"
500 server error    →  CLErrorState con messaggio generico + report
Offline             →  banner persistente in cima pagina
429 rate limited    →  toast + countdown + disabilita azione per tempo necessario
```

### 7.10 Real-time & connessione

#### 7.10.1 Indicatore connessione

```
Online          →  nessun indicatore (stato normale)
Offline         →  banner warning in cima: "Connessione assente.
                   Le modifiche saranno salvate quando torni online"
Reconnecting    →  banner warning con spinner: "Riconnessione in corso..."
Reconnected     →  toast success "Connessione ripristinata" (auto 3s)
```

#### 7.10.2 Badge aggiornamento real-time

```
Nuovo dato      →  dot badge pulsa 2 volte poi rimane fermo
                   pulse: scale 1→1.4→1, opacity 1→0.6→1, 600ms
Numero cambio   →  flip animation verticale 150ms
                   nuovo numero scende dall'alto
Rimozione badge →  scale 1→0 + fade, 200ms
```

#### 7.10.3 Refresh dati

```
Auto-refresh         →  CLProgressBar sottile 2px in cima (indeterminate)
                        non interrompe l'utente
Pull to refresh      →  solo mobile, spinner nativo della piattaforma
Dato aggiornato      →  flash bg colorPrimarySubtle sulla riga/cella
                        per 800ms poi torna normale
```

#### 7.10.4 Collaboration real-time

```
Cursor altri utenti         →  solo in editor testo, label con nome
Presence nell'entità        →  "Mario sta modificando", avatar in header
Lock mode                   →  "Mario sta modificando. Richiedi controllo"
Diff in real-time           →  fade-in del nuovo contenuto 300ms
```

### 7.11 Data formatting

#### 7.11.1 Date

| Contesto | Formato |
|----------|---------|
| Relative < 24h | "2 ore fa", "pochi minuti fa", "adesso" |
| Relative < 7gg | "3 giorni fa", "ieri" |
| Assoluta breve | "12 gen", "12 gen 2026" |
| Assoluta estesa | "12 gennaio 2026" |
| Con ora | "12 gen 2026, 14:30" |
| Tooltip su relativa | Sempre data assoluta on hover |

Quando usare:
```
Feed, attività, chat        →  relativa
Documenti, fatture          →  assoluta estesa
Tabelle                     →  assoluta breve
Log, timestamp              →  assoluta con ora
```

#### 7.11.2 Numeri

```
Interi grandi          →  1.234.567 (separatore migliaia locale)
Decimali               →  max 2 decimali di default
Compatti               →  1,2M / 34,5K / 980
Valuta                 →  € 1.234,56 (simbolo + separatori locali)
Percentuale            →  34,5% (1 decimale)
```

#### 7.11.3 Trend

```
Positivo     →  +12,3% colorSuccess, freccia su
Negativo     →  -5,1% colorError, freccia giù
Neutro       →  0% textSecondary, trattino
```

#### 7.11.4 Valori null / vuoti

```
Campo testo vuoto       →  "—" (em dash)
Campo numerico vuoto    →  "—"
Campo data vuoto        →  "—"
Non applicabile         →  "N/A"
In attesa di dati       →  skeleton inline
Zero                    →  "0" (è diverso da mancante!)
```

#### 7.11.5 Testo troncato

```
Sempre con tooltip      →  testo completo on hover
Tooltip delay           →  400ms (non troppo reattivo)
Tooltip max-width       →  320px con word-wrap
Ellipsis posizione      →  fine stringa di default
                           inizio per path/url lunghi ("…/cartella/file.pdf")
```

### 7.12 Timezone handling

```
Visualizzazione date:
  Sempre nel timezone utente di default
  Toggle "mostra in UTC" per utenti tecnici (opzionale)
  Tooltip con timezone esplicito on hover

Input date/time:
  Timezone esplicito accanto al picker
  Conversione automatica in UTC per storage

Entità collaborative:
  Mostra timezone autore quando rilevante
  "Creato alle 14:30 GMT+1 da Mario"
```

### 7.13 Session & auth states

```
Sessione in scadenza (< 5min):
  Toast warning: "Sessione in scadenza tra 5 minuti. [Estendi]"

Sessione scaduta:
  CLModal bloccante: "Sessione scaduta. Accedi di nuovo"
  Campi login inline nel modal
  Dati form preservati per dopo il re-login

Logout da altro device:
  Banner: "Sei stato disconnesso da un altro dispositivo"
  Redirect al login

Multi-device:
  Lista sessioni attive in settings
  Possibilità di disconnettere device remoti
```

### 7.14 Import / Export

#### 7.14.1 Export

```
Trigger        →  CLButton "Esporta" in header tabella
Dropdown opzioni:
  CSV       →  dati grezzi
  Excel     →  formattato con stile
  PDF       →  con intestazione e branding
  Stampa    →  direct print dialog

Scope export:
  "Solo selezionati" (se selezione)
  "Tutta la pagina"
  "Tutti i risultati filtrati"

Feedback:
  Export piccoli (<1000 righe)  →  download immediato
  Export grandi                 →  "Stiamo preparando il file..."
                                   email al completamento
                                   notification center con link
```

#### 7.14.2 Import wizard

```
Flusso a step (CLStepper):
  1. Upload file         →  CLFileUpload drag&drop
  2. Mapping colonne     →  associa colonne file → campi sistema
  3. Preview             →  tabella con prime 10 righe
                            mostra errori/warning per riga
  4. Conferma import     →  summary: N validi, M errori
  5. Progress            →  CLProgressBar + contatore
  6. Completato          →  summary risultati + scarica errori

UI errori validation:
  Riga problematica     →  bg colorErrorSubtle, icona warning
  Tooltip errore        →  "Email non valida", "Campo obbligatorio"
  Scarica solo errori   →  CSV con righe errate per correzione
```

### 7.15 Search patterns

#### 7.15.1 Global search

```
Trigger       →  CLIconButton search in AppBar o Cmd/Ctrl+K
UI            →  CLCommandPalette (vedi 6.4.9)
```

#### 7.15.2 In-page search (tabella, lista)

```
CLTextField.search() sempre visibile in toolbar tabella
Placeholder "Cerca..."
Debounce 300ms
Icona search a sinistra, clear X a destra se ha valore
Ricerca fuzzy su tutti i campi di default
Opzione "Cerca solo in colonna X" via menu avanzato
```

### 7.16 Progress per azioni lunghe

```
Banner in cima pagina:
  Icona + "Elaborazione in corso..."
  CLProgressBar
  "342 di 1000 elaborati"
  CLButton "Annulla" (se possibile)

Persistente anche cambiando pagina:
  Banner diventa badge minimale ("Elaborazione 34%") su altre pagine
  Click sul badge riporta alla vista completa

Completato:
  Banner diventa success
  "Completato: 998 importati, 2 errori [Vedi errori]"
  Dismiss manuale
```

### 7.17 Error boundaries e fallback

```
Crash di un widget       →  error boundary mostra fallback locale
Fallback component:
  Icona warning
  "Qualcosa è andato storto"
  Button "Riprova"
  Link "Segnala il problema"

Crash intera pagina      →  CLErrorState fullscreen
  Keep header/sidebar    →  l'utente può navigare altrove

Non fare:
  ❌  Crash totale dell'app
  ❌  Schermata bianca
  ❌  Error stack in produzione
```

### 7.18 Onboarding e help

#### 7.18.1 Product tour (spotlight)

```
Overlay scuro su tutta la pagina
Hole trasparente sul target
Tooltip card con step

Tooltip card:
  Titolo step        →  "Benvenuto!"
  Body               →  descrizione
  Progress           →  "1 di 5"
  Actions            →  "Salta", "Precedente", "Avanti"

Trigger:
  Primo accesso      →  automatico
  Menu help          →  sempre accessibile

Persistenza:
  Traccia step completati per utente
  Non ripetere una volta finito
```

#### 7.18.2 Contextual help

```
Icona ? accanto a label complesse   →  CLTooltip con spiegazione
Link a documentazione               →  apre in nuova tab
Help pane (?  in AppBar)            →  CLDrawer con articoli correlati
```

#### 7.18.3 Hint / empty tip

```
Quando un utente non ha mai usato una feature:
  Hint tooltip suggerisce           →  "Prova a filtrare le righe"
  Empty state con esempio           →  "Es. Aggiungi il tuo primo cliente"
  Sample data / demo                →  pre-populate con esempi cancellabili
```

### 7.19 User menu e profilo

#### 7.19.1 Menu profilo utente

```
Trigger        →  CLAvatar + nome (o solo avatar) nella sidebar/AppBar
Dropdown content:
  Header utente      →  avatar grande + nome + email + ruolo
  Separatore
  "Il mio profilo"
  "Impostazioni"
  "Cambia tema" (submenu light/dark/system)
  "Cambia lingua" (submenu)
  Separatore
  "Guide e documentazione"
  "Contatta il supporto"
  "Novità" (badge se nuove)
  Separatore
  "Esci"
```

#### 7.19.2 Workspace switcher (multi-tenant)

```
Trigger        →  in cima alla sidebar, logo + nome workspace
Dropdown:
  Current workspace  →  highlight con check
  Other workspaces   →  lista con logo/avatar
  Separator
  "+ Crea workspace"
  "Impostazioni workspace"
```

### 7.20 Pagina settings — struttura

#### 7.20.1 Layout tipico

```
┌─────────────────────────────────────────┐
│  Impostazioni                            │
├──────────────┬──────────────────────────┤
│              │                          │
│  Menu left   │   Contenuto sezione      │
│              │                          │
│  Profilo     │                          │
│  Sicurezza   │                          │
│  Notifiche   │                          │
│  Billing     │                          │
│  Team        │                          │
│  API         │                          │
│              │                          │
└──────────────┴──────────────────────────┘

Menu left:
  Width 240px
  Voci sezione, stato attivo evidenziato
  Gruppi con divider se molte voci

Contenuto:
  Header sezione   →  titolo + descrizione
  Sezioni con card →  ogni gruppo di impostazioni in una CLCard
  Save inline      →  ogni card ha il suo save button
                      OPPURE autosave con indicatore
```

#### 7.20.2 Anatomia singola impostazione

```
┌───────────────────────────────────────┐
│  Titolo impostazione                   │
│  Descrizione più lunga della           │
│  funzionalità e delle implicazioni     │
│                            [Toggle]   │
└───────────────────────────────────────┘

Layout:
  Testo a sinistra, controllo a destra (desktop)
  Testo sopra, controllo sotto (mobile compact)

Danger zone (delete account, reset):
  Sezione "Zona pericolosa" in fondo
  Border colorError, bg colorErrorSubtle
  CLButton destructive per azioni
```

### 7.21 Billing e subscription

#### 7.21.1 Trial/upgrade banner

```
Banner in cima all'AppBar:
  Trial          →  "X giorni rimanenti. [Upgrade]"
  Scaduto        →  CLAlert error "Il tuo trial è scaduto. [Rinnova]"
  Payment issue  →  "Problema con il pagamento. [Aggiorna]"

Dismissible    →  solo se non bloccante
Persistente    →  se pagamento fallito o account bloccato
```

#### 7.21.2 Feature gating

```
Feature non disponibile nel piano:
  Badge "Pro"/"Business" accanto al nome feature
  Click mostra modal upgrade con benefici
  Preview sfocata della feature

Limiti di utilizzo:
  CLProgressBar       →  "85 di 100 contatti usati"
  Warning              →  appare all'80% del limite
  Blocco               →  al 100%, modal con upgrade CTA
```


---

## 8. Tema e Personalizzazione

### 8.1 Architettura del tema

Il tema è basato su `ThemeExtension` di Flutter. Non usa `ColorScheme` direttamente — tutti i token sono in extension custom.

```dart
class CLThemeExtension extends ThemeExtension<CLThemeExtension> {
  final CLColorTokens colors;
  final CLSpacingTokens spacing;
  final CLTypographyTokens typography;
  final CLSizingTokens sizing;
  final CLElevationTokens elevation;
  final CLRadiusTokens radius;

  const CLThemeExtension({
    required this.colors,
    required this.spacing,
    required this.typography,
    required this.sizing,
    required this.elevation,
    required this.radius,
  });

  @override
  CLThemeExtension copyWith({ ... });

  @override
  CLThemeExtension lerp(ThemeExtension<CLThemeExtension>? other, double t) { ... }
}
```

### 8.2 Builder del tema

Entry point per consumer della libreria:

```dart
class CLTheme {
  static ThemeData light({
    CLColorTokens? colorsOverride,
    CLTypographyTokens? typographyOverride,
    String? fontFamily,
    double? baseRadius,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamily ?? 'Inter',
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      extensions: [
        CLThemeExtension(
          colors: colorsOverride ?? CLColorTokens.defaultLight(),
          typography: typographyOverride ?? CLTypographyTokens.defaultTokens(),
          spacing: CLSpacingTokens.defaultTokens(),
          sizing: CLSizingTokens.defaultTokens(),
          elevation: CLElevationTokens.defaultLight(),
          radius: CLRadiusTokens.defaultTokens(baseRadius: baseRadius ?? 8),
        ),
      ],
      // Applica altri standard Material richiesti
      ...
    );
  }

  static ThemeData dark({ ... });
}
```

### 8.3 Uso da parte del consumer

```dart
MaterialApp(
  theme: CLTheme.light(),
  darkTheme: CLTheme.dark(),
  themeMode: ThemeMode.system,
  home: CLShell(...),
)
```

### 8.4 Brand customization

Il consumer può personalizzare il tema:

```dart
CLTheme.light(
  colorsOverride: CLColorTokens.defaultLight().copyWith(
    colorPrimary: Color(0xFF00A86B),          // brand verde
    colorPrimaryHover: Color(0xFF008F5A),
  ),
  fontFamily: 'CustomBrandFont',
  baseRadius: 4,                              // design più squadrato
)
```

### 8.5 Dark mode switching

#### 8.5.1 Tre modalità utente

```
Light         →  forza light mode
Dark          →  forza dark mode
System        →  segue preferenza OS
```

#### 8.5.2 Transizione

```
Cambio tema    →  animazione 300ms su colori (cross-fade) e bg
                  shadow e radius non si animano (cambio istantaneo)
                  
Persistenza    →  scelta salvata in SharedPreferences
```

### 8.6 Context extensions (accesso ai token)

Vedere [Sezione 4.8](#48-accesso-ai-token-in-qualsiasi-widget) per l'API completa.

Regola: **i componenti accedono ai token solo tramite `context.colors.X`, `context.spacing.X`, `context.typography.X`, `context.sizing.X`**. Mai import diretti dei file token nei widget.

### 8.7 Densità globale

Preferenza utente a livello di tema:

```dart
enum CLDensity { compact, normal, comfortable }

CLTheme.light(density: CLDensity.compact)
```

Componenti si adattano automaticamente leggendo `Theme.of(context).extension<CLThemeExtension>()!.density`.

### 8.8 Personalizzazione per consumer esterni

La libreria deve supportare due livelli di customizzazione:

#### 8.8.1 Livello 1: token override (consigliato)

Cambi colori, font, radius. Tutti i componenti si adattano. **NON modifica la struttura dei componenti**.

#### 8.8.2 Livello 2: widget composition

Se un consumer vuole un componente con struttura diversa, **usa la composizione**, non modifica la libreria. Esempio:

```dart
// Consumer custom button
class MyProjectButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CLButton(
      // configurazione custom
    );
  }
}
```

**La libreria non offre slot/hook per riconfigurare la struttura interna dei componenti**.

---

## 9. Accessibilità

### 9.1 Principi guida

- Conformità **WCAG 2.1 AA** come baseline, AAA dove possibile.
- Accessibilità **non è un'opzione**: ogni componente la implementa di default.
- Testare regolarmente con screen reader (VoiceOver, TalkBack, NVDA).

### 9.2 Semantic labels

Ogni widget pubblico accetta o genera automaticamente `semanticLabel`:

```dart
class CLIconButton extends StatelessWidget {
  final String semanticLabel;             // OBBLIGATORIO
  // ...
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: !isDisabled,
      child: ...,
    );
  }
}
```

Componenti obbligati ad avere semanticLabel:
- `CLIconButton`
- `CLAvatar` (nome utente)
- `CLBadge` (se standalone)
- Qualsiasi elemento interattivo senza testo visibile

### 9.3 Focus management

#### 9.3.1 Focus visibile

```
Outline: 2px solid borderFocus
Offset: 2px dal bordo del componente
Mai rimosso (nemmeno per "pulizia estetica")
Box-shadow alternative se outline non rende bene
```

#### 9.3.2 Focus order

```
Ordine logico      →  segue il DOM / widget tree naturale
Skip link          →  su applicazioni grandi, "Vai al contenuto principale"
Focus trap         →  dentro modal/drawer, Tab non esce
```

#### 9.3.3 Focus trap (modal)

```dart
// CLModal deve implementare
FocusScope(
  canRequestFocus: true,
  child: ...,  // focus circola solo dentro il modal
)

// Alla chiusura, focus torna al trigger originale
```

#### 9.3.4 Autofocus

```
Modal con form      →  primo campo del form
BottomSheet         →  primo campo interattivo
Command palette     →  search input
Dropdown searchable →  search input

NON autofocus:
  Pagine normali       →  può creare scroll jump
  Campi opzionali      →  meglio lasciare la scelta all'utente
```

### 9.4 Contrasto colori

#### 9.4.1 Rapporti minimi WCAG AA

| Elemento | Rapporto minimo |
|----------|-----------------|
| Testo normale (< 18sp) | 4.5:1 |
| Testo grande (>= 18sp o >= 14sp bold) | 3:1 |
| Elementi UI (border, icone) | 3:1 |
| Testo disabilitato | esente (ma opacity 0.38 è ok) |

#### 9.4.2 Verifica dei token

Tutti i token semantici del design system rispettano AA. Se un brand cambia `colorPrimary`, il consumer deve verificare che:
- `textOnPrimary` abbia contrasto >= 4.5:1 con `colorPrimary`
- `colorPrimary` abbia contrasto >= 3:1 con `surfacePage`

### 9.5 Keyboard navigation

Vedi [Sezione 7.7](#77-keyboard-shortcuts). Riassunto requisiti minimi:

```
Tab / Shift+Tab         →  navigazione tra elementi interattivi
Enter / Space           →  attiva button, toggle checkbox
Esc                     →  chiude modal/dropdown
Frecce                  →  navigazione in liste, menu, tab
Home / End              →  primo/ultimo elemento in lista
Page Up / Down          →  scroll in liste lunghe

Regola: OGNI componente cliccabile deve essere raggiungibile da tastiera.
```

### 9.6 Screen reader

#### 9.6.1 Annunci live (aria-live equivalent)

```dart
SemanticsService.announce('Operazione completata', TextDirection.ltr);
```

Usato per:
- Toast importanti (success di salvataggio, errori)
- Cambiamenti di stato non ovvi (tabella refreshata, filtri applicati)
- Risultati di ricerca ("5 risultati trovati")

#### 9.6.2 Raggruppamento semantico

```dart
Semantics(
  container: true,
  label: 'Barra degli strumenti',
  child: Row(children: [...]),
)
```

#### 9.6.3 Decorazioni escluse

Elementi puramente decorativi:

```dart
ExcludeSemantics(
  child: Container(color: accentColor, height: 4),
)
```

### 9.7 Text scaling

```
Supportare textScaleFactor fino a 2.0 senza rotture:
  - Nessun testo tagliato
  - Componenti che si espandono verticalmente quando serve
  - Nessun layout fisso che non si adatta
  - Icone NON scalano con il testo (restano alla size del componente)

Test obbligatorio:
  - MediaQuery.textScaleFactor = 1.5, 2.0
  - Verifica ogni componente pubblico
```

### 9.8 Touch targets

```
Minimo touch target    →  48x48 px (mobile), 40x40 (desktop)
Gap tra target         →  minimo 8px per evitare mis-tap
Area cliccabile        →  può essere più grande dell'area visibile
                          (hit-slop invisibile attorno)
```

Esempio: un `CLIconButton` size xs (32px) deve avere hit area 48px su mobile.

### 9.9 Reduced motion

```dart
if (MediaQuery.of(context).disableAnimations) {
  // - Scala/slide → istantaneo o solo fade
  // - Skeleton shimmer → pulse più leggero
  // - Page transition → crossfade minimale
  // - Parallax, confetti, decorative → disabilitati
}
```

### 9.10 High contrast mode

Windows high contrast mode, macOS "Aumenta contrasto":

```
Verifica periodica:
  - Border visibili su tutti gli input/button
  - Focus ring sempre distinguibile
  - Testo mai solo da colore (es. link con underline, non solo colore)
  - Icone con semantic label (non solo colore per distinguere)
```

### 9.11 Pattern anti-accessibilità da evitare

```
❌  Placeholder come unica label di un campo
❌  Colore come unico indicatore di stato (es. solo bordo rosso)
❌  Icon button senza tooltip/semanticLabel
❌  Modal che apre senza focus trap
❌  Scroll lock che non si ripristina
❌  Disabilitare focus ring con outline: none
❌  Testo sotto 12sp su desktop, 13sp su mobile
❌  Click area troppo piccola (< 40px)
❌  Animazioni senza rispetto di reducedMotion
❌  Toast error senza annuncio a screen reader
```


---

## 10. Responsive e Window Size

### 10.1 Principio fondamentale: window size, non device

La libreria **non usa** `Platform.isIOS` / `Platform.isAndroid` per decidere il layout. Usa sempre la **larghezza effettiva della finestra**.

Questo è critico perché:
- Un desktop con finestra rimpicciolita a 400px deve comportarsi come mobile
- Un tablet in split-screen deve adattarsi
- Web, desktop, mobile usano gli stessi breakpoint

### 10.2 Enum e breakpoint

```dart
enum CLWindowSize {
  compact,       // < 600px
  medium,        // 600 - 900
  expanded,      // 900 - 1280
  large,         // 1280 - 1536
  extraLarge;    // > 1536

  static CLWindowSize fromWidth(double width) {
    if (width < 600) return CLWindowSize.compact;
    if (width < 900) return CLWindowSize.medium;
    if (width < 1280) return CLWindowSize.expanded;
    if (width < 1536) return CLWindowSize.large;
    return CLWindowSize.extraLarge;
  }
}
```

### 10.3 Accesso al window size

```dart
// Via context extension
final size = context.windowSize;

// Helper booleani
context.isCompact       // < 600
context.isMedium        // 600-900
context.isExpanded      // >= 900 (copre expanded, large, extraLarge)
context.isDesktopWide   // >= 1280

// Implementazione
extension CLResponsiveContext on BuildContext {
  CLWindowSize get windowSize => 
    CLWindowSize.fromWidth(MediaQuery.of(this).size.width);
  
  bool get isCompact => windowSize == CLWindowSize.compact;
  bool get isMedium => windowSize == CLWindowSize.medium;
  bool get isExpanded => windowSize.index >= CLWindowSize.expanded.index;
}
```

### 10.4 LayoutBuilder vs MediaQuery

| Caso | Usa |
|------|-----|
| Layout intera pagina | `MediaQuery` / `context.windowSize` |
| Componente che dipende dal parent | `LayoutBuilder` |
| Componente self-contained | `ConstrainedBox` + `Flexible` |

Non affidarsi solo a MediaQuery per componenti dentro sidebar stretta — la sidebar ha larghezza diversa dallo schermo.

### 10.5 Widget helper: `CLResponsive`

```dart
class CLResponsive<T> extends StatelessWidget {
  final T Function(BuildContext) compact;
  final T Function(BuildContext)? medium;
  final T Function(BuildContext)? expanded;
  final T Function(BuildContext)? large;
  final T Function(BuildContext)? extraLarge;
  // ...
}

// Uso
CLResponsive<Widget>(
  compact: (ctx) => MobileLayout(),
  medium: (ctx) => TabletLayout(),
  expanded: (ctx) => DesktopLayout(),
)
```

### 10.6 Helper `CLResponsiveValue`

Per scegliere un valore semplice in base al size:

```dart
final padding = CLResponsiveValue<double>(
  compact: 16,
  medium: 20,
  expanded: 24,
  large: 32,
).resolve(context);
```

### 10.7 Adattamento layout per componente

Tabella di riferimento comportamenti responsive:

| Componente | compact | medium | expanded+ |
|------------|---------|--------|-----------|
| Shell | BottomNav + drawer | Rail o drawer | Sidebar espansa |
| Sidebar | Drawer laterale | NavigationRail | Sidebar 2 colonne |
| AppBar | Compact, back button | Compact | Breadcrumb + azioni |
| Modal | BottomSheet fullscreen | Modal centrato | Modal centrato |
| Drawer | Fullscreen sheet | Overlay | Overlay o push |
| DatePicker | BottomSheet | Overlay | Overlay inline |
| Select dropdown | BottomSheet | Overlay | Overlay |
| Table | Card list | Card list o scroll | Tabella completa |
| Form | Single column | Single column | Two column opt. |
| Button form | isFullWidth: true | Width auto | Width auto |
| Tabs | Scrollable | Scrollable | Fixed |
| KPI grid | 1 col | 2 col | 3-4 col |
| Kanban | 1 colonna swipe | 2 col scroll | Colonne affiancate |

### 10.8 Touch vs pointer

Indipendente dal window size: anche su desktop si possono avere touchscreen.

```dart
final hasTouch = MediaQuery.of(context).navigationMode == NavigationMode.directional 
                 || Platform.isIOS 
                 || Platform.isAndroid;
// Meglio: usare pointer events per determinare interazione
```

Comportamento:
- **Hover effects** solo se `pointer == mouse`
- **Touch target minimo 48px** se touch disponibile
- **Action on hover** → disponibili come tap espliciti se touch

### 10.9 Zoom browser

```
L'utente può zoommare il browser (Cmd/Ctrl + Plus).
Il design deve funzionare fino a 200% zoom senza overflow orizzontale.

Implicazione: mai usare width fissi in pixel per elementi critici.
Usare flex, min-width, max-width per contenere.
```

### 10.10 Safe areas (mobile)

```dart
SafeArea(
  top: true,       // notch, status bar
  bottom: true,    // home indicator
  child: ...,
)

// CLShell gestisce automaticamente:
// - Safe area top per AppBar
// - Safe area bottom per BottomNav e FAB
// - Nessun contenuto nascosto sotto le safe area
```

### 10.11 Orientamento (mobile)

Supportare entrambi portrait e landscape. Non forzare orientation lock a meno che il contenuto lo richieda esplicitamente (es. un gioco, un grafico molto largo).

Landscape mobile:
```
Height disponibile molto ridotta
AppBar → altezza ridotta o collassabile
Form → scroll interno, non crescita verticale
Tastiera aperta → resize content, non dismiss dei campi
```

### 10.12 Resize real-time (desktop/web)

Il layout deve rispondere a resize in tempo reale.

```
Trigger resize browser:
  Transizione layout in base ai breakpoint superati
  Durata: 150ms per evitare flash, senza animazioni complesse
  Sidebar collassa/espande con animazione
  Content si ridistribuisce immediatamente
  Stato preservato (form, scroll position, selezioni)
```

### 10.13 Print styles

Preparare la libreria per stampa:

```
Quando @media print:
  Sidebar → nascosta
  AppBar → nascosta o semplificata
  BottomNav → nascosta
  Toast/overlay → nascosti
  Shadow → rimosse
  Background → bianco
  Link colors → colore + underline mantenuti
  Page breaks → rispettati dentro i componenti (no cut a metà)
  Max-width → utilizzato sempre (no full-bleed)
```

---

## 11. Copy, Microcopy e Tono di Voce

### 11.1 Attributi del tono

La libreria è neutra sul tono dei testi, ma definisce **principi** da seguire:

| Attributo | Descrizione |
|-----------|-------------|
| **Professionale** | Contesto business, non gergale |
| **Chiaro** | Semplice, non ambiguo, specifico |
| **Conciso** | Niente ridondanze, al punto |
| **Cortese** | Rispettoso, mai colpevolizzante |
| **Utile** | Ogni testo aiuta l'utente a capire/agire |

### 11.2 Lunghezze massime consigliate

| Elemento | Max caratteri | Note |
|----------|---------------|------|
| Button label | 20 (2-3 parole) | Azione verbo + oggetto |
| Tab label | 24 | Testo essenziale |
| Chip/Tag | 30 | Tronca oltre con tooltip |
| Toast message | 100 (2 righe) | Breve, specifico |
| Modal title | 60 | Domanda o affermazione |
| Modal body | 500 | Se più, usare scroll |
| Empty state title | 40 | 4-5 parole |
| Empty state body | 120 (2 righe) | Spiega e suggerisce azione |
| Tooltip | 80 | Singola frase |
| Error inline | 100 | Cosa + perché + come |
| Placeholder | 40 | Esempio del formato atteso |
| Hint/helper | 80 | Una riga |

### 11.3 Pattern ricorrenti

#### 11.3.1 Azioni CTA

```
❌  "OK", "Sì", "Conferma"
✅  "Salva modifiche", "Elimina cliente", "Crea fattura"

Formula: [Verbo imperativo] + [oggetto specifico]
```

#### 11.3.2 Pulsanti di conferma / annullamento

```
Azione positiva:
  Primary:  "Crea fattura", "Salva modifiche", "Invia"
  Ghost:    "Annulla"

Azione destructive:
  Primary:  "Elimina definitivamente" (variant destructive)
  Ghost:    "Annulla"

MAI "OK" / "Cancel" generici.
```

#### 11.3.3 Messaggi di errore

Formula: **Cosa è andato storto + Perché + Come risolverlo**

```
❌  "Errore"
❌  "Input non valido"
✅  "Email non valida. Manca il simbolo @. Inserisci un'email tipo mario@esempio.com"
✅  "Password troppo corta. Deve contenere almeno 8 caratteri."
```

#### 11.3.4 Messaggi di successo

Conferma azione + eventuale prossimo passo:

```
✅  "Cliente creato"
✅  "Modifiche salvate"
✅  "Fattura inviata a mario@rossi.it"
✅  "Importazione completata: 1.234 contatti aggiunti. [Vedi]"
```

#### 11.3.5 Stati vuoti

```
No data (primo accesso):
  Titolo:  "Nessun [cosa] ancora"
  Body:    "Crea il tuo primo [cosa] per [beneficio]"
  CTA:     "[Azione] [cosa]"

No results (dopo filtro/ricerca):
  Titolo:  "Nessun risultato per '[query]'"
  Body:    "Prova con termini diversi o rimuovi i filtri"
  CTA:     "Cancella filtri"

No permission:
  Titolo:  "Accesso non autorizzato"
  Body:    "Non hai i permessi per visualizzare questa sezione. Contatta l'amministratore."
  CTA:     "Contatta admin" o nulla
```

### 11.4 Formato errori comuni

```
Campo obbligatorio:
  "Campo obbligatorio" oppure "[Nome campo] è obbligatorio"

Formato non valido:
  "Formato non valido. Usa: [esempio]"

Valore troppo lungo/corto:
  "Massimo 255 caratteri" / "Minimo 8 caratteri"

Duplicato:
  "Questo [cosa] esiste già"

Permissions:
  "Non hai i permessi per questa azione"

Rete:
  "Impossibile connettersi. Controlla la tua connessione"

Server:
  "Si è verificato un errore. Riprova o [contatta il supporto]"
```

### 11.5 Time e date in copy

```
Futuro:
  "Tra 3 giorni"
  "Il 15 marzo"
  "Domani alle 14:30"

Passato:
  "2 ore fa"
  "Ieri"
  "Il 12 gennaio"

Scadenze:
  "Scade oggi"
  "Scade tra 3 giorni"
  "Scaduto da 5 giorni" (colore warning/error)
```

### 11.6 Numeri nel copy

```
Count items:
  "1 cliente" / "0 clienti" / "24 clienti"  (singolare/plurale corretto)
  "Più di 1.000 clienti" (compattato per grandi numeri)

Range:
  "1-25 di 243"
  "Ultimi 30 giorni"

Percentuali:
  "+12,3% vs mese scorso"
  "85% completato"
```

### 11.7 Terminologia consistente

Mantenere gli stessi termini in tutta l'app:

```
❌ Mix inconsistente:
  "Elimina" in un posto, "Cancella" in un altro
  "Salva" vs "Memorizza"
  "Annulla" vs "Cancella"
  "Gruppi" vs "Categorie" (per la stessa cosa)

✅ Decidere e mantenere:
  Elimina (distruggere) / Annulla (revert)
  Salva (persist) / Applica (temporaneo)
  Crea / Modifica / Elimina (CRUD standard)
```

### 11.8 Lingua e localizzazione

```
Default           →  italiano
Supporto i18n     →  usare Flutter intl, non hardcodare stringhe
Fallback          →  inglese se stringa mancante
Plurali           →  usare Intl.plural per count-based

Formati locali:
  Data            →  dd/mm/yyyy (IT) vs mm/dd/yyyy (EN)
  Numero          →  1.234,56 (IT) vs 1,234.56 (EN)
  Valuta          →  € 1.234,56 (IT)
  Ora             →  24h (IT) vs 12h AM/PM (EN)
```


---

## 12. Do's and Don'ts

### 12.1 Colori

❌ **Don't**:
```dart
Container(color: Color(0xFF2563EB))                    // hardcoded
Container(color: Colors.blue)                          // Material color
Container(color: Theme.of(context).primaryColor)       // Material ColorScheme
```

✅ **Do**:
```dart
Container(color: context.colors.colorPrimary)
Container(color: context.colors.surfaceCard)
```

### 12.2 Spacing

❌ **Don't**:
```dart
Padding(padding: EdgeInsets.all(15))                   // non è un token
SizedBox(height: 10)                                   // hardcoded
Container(margin: EdgeInsets.only(top: 23))            // random
```

✅ **Do**:
```dart
Padding(padding: EdgeInsets.all(context.spacing.s4))
SizedBox(height: context.spacing.s3)
```

### 12.3 Tipografia

❌ **Don't**:
```dart
Text('Hello', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))
Text('Titolo', style: TextStyle(fontSize: 20, color: Colors.black))
```

✅ **Do**:
```dart
Text('Hello', style: context.typography.label)
Text('Titolo', style: context.typography.headingLg.copyWith(
  color: context.colors.textPrimary,
))
```

### 12.4 Sizing componenti

❌ **Don't**:
```dart
Container(height: 42, padding: EdgeInsets.symmetric(horizontal: 15))
SizedBox(width: 38, height: 38, child: Icon(...))       // icon button custom
```

✅ **Do**:
```dart
CLButton(size: CLSize.md, ...)
CLIconButton(size: CLSize.md, icon: ..., ...)
```

### 12.5 Responsive

❌ **Don't**:
```dart
if (Platform.isIOS) {
  return MobileLayout();
} else {
  return DesktopLayout();
}
```

✅ **Do**:
```dart
if (context.isCompact) {
  return MobileLayout();
}
return DesktopLayout();

// Oppure
CLResponsive(
  compact: (ctx) => MobileLayout(),
  expanded: (ctx) => DesktopLayout(),
)
```

### 12.6 Stati disabled

❌ **Don't**:
```dart
// Disabilitare solo cambiando colore
CLButton(label: 'Save', onPressed: formIsValid ? save : null)
// Nessuna spiegazione del perché è disabled
```

✅ **Do**:
```dart
CLButton(
  label: 'Save',
  onPressed: formIsValid ? save : null,
  tooltip: formIsValid ? null : 'Completa tutti i campi obbligatori',
)
```

### 12.7 Feedback azioni

❌ **Don't**:
```dart
onPressed: () => deleteItem(),    // nessun feedback all'utente
```

✅ **Do**:
```dart
onPressed: () async {
  final confirmed = await showCLConfirm(
    context: context,
    title: 'Eliminare?',
    message: 'Questa azione non è reversibile.',
    confirmLabel: 'Elimina',
    confirmVariant: CLButtonVariant.destructive,
  );
  if (!confirmed) return;
  
  await deleteItem();
  
  showCLToast(
    context: context,
    message: 'Elemento eliminato',
    variant: CLToastVariant.success,
    actionLabel: 'Annulla',
    onAction: () => restoreItem(),
  );
}
```

### 12.8 Modal e overlay

❌ **Don't**:
```dart
showDialog(context: context, builder: (_) => CLModal(...))
// uso showDialog di Flutter
```

✅ **Do**:
```dart
final result = await showCLModal<bool>(
  context: context,
  title: 'Conferma',
  child: ...,
  actions: [...],
);
// sempre via function helper
```

### 12.9 Icone

❌ **Don't**:
```dart
Icon(Icons.check)                          // Material icons
Icon(CupertinoIcons.checkmark)             // Cupertino icons
// Mix di librerie
```

✅ **Do**:
```dart
Icon(LucideIcons.check)                    // sempre Lucide
// OR icone custom brand nello stesso stile
```

### 12.10 Accessibilità

❌ **Don't**:
```dart
IconButton(
  icon: Icon(LucideIcons.trash),
  onPressed: delete,
)
// Nessun label, screen reader legge "button"
```

✅ **Do**:
```dart
CLIconButton(
  icon: LucideIcons.trash,
  onPressed: delete,
  semanticLabel: 'Elimina cliente',
  tooltip: 'Elimina',
)
```

### 12.11 Loading states

❌ **Don't**:
```dart
if (isLoading) return CircularProgressIndicator();   // solo spinner
return Content(...);
```

✅ **Do**:
```dart
if (isLoading) return CLSkeleton.card(height: 120);   // skeleton strutturato
return Content(...);
```

### 12.12 Empty states

❌ **Don't**:
```dart
if (data.isEmpty) return Text('Nessun dato');        // testo misero
```

✅ **Do**:
```dart
if (data.isEmpty) return CLEmptyState(
  variant: CLEmptyStateVariant.noData,
  title: 'Nessun cliente ancora',
  description: 'Aggiungi il tuo primo cliente per iniziare',
  actions: [CLButton(label: 'Crea cliente', icon: LucideIcons.plus, ...)],
);
```

### 12.13 Form validation

❌ **Don't**:
```dart
// Validation on type che mostra errori mentre l'utente scrive
onChanged: (value) {
  if (!isValidEmail(value)) {
    setState(() => error = 'Email non valida');
  }
}
```

✅ **Do**:
```dart
// Validation on blur, errore scomparirà durante typing successivo
CLTextField(
  label: 'Email',
  validator: (value) => isValidEmail(value) ? null : 'Email non valida',
  validateOn: CLValidateOn.blur,
)
```

### 12.14 Colori non-semantici

❌ **Don't**:
```dart
Text('Errore', style: TextStyle(color: Colors.red))
Container(color: Colors.green)                         // successo?
```

✅ **Do**:
```dart
Text('Errore', style: TextStyle(color: context.colors.textError))
Container(color: context.colors.colorSuccessSubtle)
```

### 12.15 Azioni destructive

❌ **Don't**:
```dart
// Azione destructive esposta in bulk toolbar
Row(children: [
  CLButton(label: 'Elimina tutti', variant: destructive),
])
```

✅ **Do**:
```dart
// Azione destructive sempre nell'overflow menu
CLIconButton(
  icon: LucideIcons.moreVertical,
  onPressed: () => showCLContextMenu(
    context: context,
    items: [
      CLContextMenuItem(label: 'Archivia', ...),
      CLContextMenuItem(label: 'Esporta', ...),
      // Separator + destructive last
      CLContextMenuItem(label: 'Elimina tutti', isDestructive: true, ...),
    ],
  ),
)
```

---

## 13. Appendici

### 13.1 Keyboard shortcuts — riferimento completo

#### Globali

| Shortcut | Azione |
|----------|--------|
| Cmd/Ctrl + K | Apri command palette |
| Cmd/Ctrl + / | Mostra lista shortcut |
| Cmd/Ctrl + S | Salva |
| Cmd/Ctrl + Z | Undo |
| Cmd/Ctrl + Shift + Z | Redo |
| Cmd/Ctrl + Y | Redo (Windows alt) |
| Esc | Chiudi modal/dropdown |
| ? | Help contestuale |
| Cmd/Ctrl + Alt + D | Toggle dark mode (opzionale) |

#### Navigazione

| Shortcut | Azione |
|----------|--------|
| Cmd/Ctrl + , | Apri settings |
| Cmd/Ctrl + H | Vai alla home |
| Cmd/Ctrl + Shift + N | Notifiche |
| Cmd/Ctrl + B | Toggle sidebar |

#### Tabelle/liste

| Shortcut | Azione |
|----------|--------|
| ↑ ↓ | Naviga righe |
| Enter | Apri riga selezionata |
| Space | Toggle selezione |
| Cmd/Ctrl + A | Seleziona tutto |
| Shift + click | Selezione range |
| Delete / Backspace | Elimina selezionati (con conferma) |

#### Form

| Shortcut | Azione |
|----------|--------|
| Tab | Prossimo campo |
| Shift + Tab | Campo precedente |
| Enter | Submit form |
| Esc | Annulla / chiudi |

### 13.2 Z-index — reference

| Z-index | Uso |
|---------|-----|
| 0 | Contenuto base |
| 10 | Sticky elements (header tabella) |
| 100 | Sidebar, AppBar |
| 200 | Dropdown, popover, tooltip |
| 300 | Drawer laterale |
| 400 | Modal backdrop |
| 401 | Modal content |
| 500 | Toast / Snackbar |
| 600 | Command palette |
| 700 | Loader globale |
| 999 | Debug overlay |

### 13.3 Breakpoint — reference

| Size | Range | Primary use |
|------|-------|-------------|
| compact | < 600px | Mobile portrait |
| medium | 600-900 | Mobile landscape, tablet portrait |
| expanded | 900-1280 | Tablet landscape, laptop |
| large | 1280-1536 | Desktop standard |
| extraLarge | > 1536 | Desktop ampio, monitor esterno |

### 13.4 Timing — reference

| Timing | Valore |
|--------|--------|
| Loading delay (show spinner) | 300ms |
| Tooltip delay | 400ms |
| Autosave debounce | 1000ms |
| Search debounce | 300ms |
| Toast success | 4000ms |
| Toast info | 5000ms |
| Toast warning | 6000ms |
| Toast con action | 8000ms |
| Toast error | persistente |
| Modal open animation | 200ms |
| Modal close animation | 150ms |
| Dropdown open | 150ms |
| Dropdown close | 100ms |
| Accordion open | 200ms |
| Accordion close | 150ms |
| Page transition (desktop) | 200ms |
| Page transition (mobile) | 300ms |
| Hover transition | 150ms |
| Press scale | 100ms in, 150ms out |
| Sidebar collapse | 250ms |
| Skeleton shimmer loop | 1500ms |

### 13.5 Elevation — reference dark overlay

| Level | Light shadow | Dark overlay bianco |
|-------|--------------|---------------------|
| 0 | nessuna | 0% |
| 1 | `0 1px 3px rgba(0,0,0,0.08)` | 4% |
| 2 | `0 4px 8px rgba(0,0,0,0.10)` | 6% |
| 3 | `0 4px 12px rgba(0,0,0,0.12)` | 8% |
| 4 | `0 8px 24px rgba(0,0,0,0.16)` | 10% |
| 5 | `0 12px 32px rgba(0,0,0,0.20)` | 12% |

### 13.6 Struttura assets

```
assets/
├── fonts/
│   ├── Inter-Regular.ttf
│   ├── Inter-Medium.ttf
│   ├── Inter-SemiBold.ttf
│   ├── Inter-Bold.ttf
│   └── JetBrainsMono-Regular.ttf
├── icons/
│   └── custom/
│       ├── logo.svg
│       └── [icone custom brand]
├── illustrations/
│   ├── empty_states/
│   │   ├── no_data.svg
│   │   ├── no_results.svg
│   │   └── no_permission.svg
│   └── onboarding/
└── sounds/                          (opzionale, per notification)
    └── notification.mp3
```

### 13.7 Analytics hooks — pattern consigliato

```dart
// I componenti non fanno analytics direttamente.
// Il consumer può wrappare con logging:

class CLButton extends StatelessWidget {
  final String? analyticsId;              // opzionale
  final VoidCallback? onPressed;
  
  // Internamente emette evento
  void _handlePress() {
    if (analyticsId != null) {
      CLAnalytics.trackTap(analyticsId);
    }
    onPressed?.call();
  }
}

// Consumer configura provider
CLAnalytics.initialize(
  tracker: MyAnalyticsService(),
);
```

### 13.8 Debug utilities

Per sviluppo e testing:

```dart
// Overlay grid
CLDebug.showGrid = true;       // mostra colonne griglia

// Overlay spacing
CLDebug.showSpacing = true;    // outline padding/margin

// Font baseline
CLDebug.showBaseline = true;   // mostra line-height

// Componenti sizing
CLDebug.showBoundaries = true; // bordo debug su ogni componente

// Solo in debug mode:
assert(() {
  CLDebug.showGrid = true;
  return true;
}());
```

### 13.9 Test strategy

#### Widget test

```dart
// Ogni componente pubblico deve avere:
testWidgets('CLButton renders with label', (tester) async {
  await tester.pumpWidget(
    CLTestApp(
      child: CLButton(label: 'Save', onPressed: () {}),
    ),
  );
  expect(find.text('Save'), findsOneWidget);
});

testWidgets('CLButton disabled when onPressed is null', (tester) async {
  // ...
});

testWidgets('CLButton shows spinner when isLoading', (tester) async {
  // ...
});
```

#### Golden test

```dart
// Snapshot visivo per ogni size/variant
testGoldens('CLButton variants', (tester) async {
  await loadAppFonts();
  final widget = Row(children: [
    for (final size in CLSize.values)
      for (final variant in CLButtonVariant.values)
        CLButton(label: 'Save', variant: variant, size: size),
  ]);
  await tester.pumpWidgetBuilder(widget);
  await screenMatchesGolden(tester, 'button_variants');
});
```

#### Accessibility test

```dart
testWidgets('CLIconButton has semantic label', (tester) async {
  await tester.pumpWidget(
    CLTestApp(
      child: CLIconButton(
        icon: LucideIcons.trash,
        semanticLabel: 'Delete',
        onPressed: () {},
      ),
    ),
  );
  expect(
    tester.getSemantics(find.byType(CLIconButton)),
    matchesSemantics(label: 'Delete', isButton: true),
  );
});
```

### 13.10 Example app

Il package deve includere un'app demo in `example/` che mostri:

```
example/
  lib/
    main.dart                      ← entry point
    showcase/
      buttons_showcase.dart        ← tutti i button
      inputs_showcase.dart
      tables_showcase.dart
      [...]
    pages/
      dashboard_demo.dart          ← dashboard completa
      form_demo.dart
      data_table_demo.dart
```

Ogni showcase deve mostrare:
- Tutte le varianti
- Tutte le size
- Light + Dark side-by-side
- Stati: default, hover, disabled, loading, error
- Esempi di uso reale

### 13.11 Checklist di review per nuovo componente

Prima di mergare un componente nuovo:

```
Design tokens
☐ Usa solo token del design system (niente colori/size hardcoded)
☐ Supporta light e dark mode

Accessibilità
☐ Ha semanticLabel o label visibile
☐ Focus visibile con outline
☐ Raggiungibile da tastiera
☐ Touch target >= 48px (mobile) / 40px (desktop)
☐ Testato con textScaleFactor 1.5 e 2.0
☐ Rispetta reducedMotion

Responsive
☐ Si adatta a compact (< 600px)
☐ Si adatta a medium (600-900)
☐ Si adatta a expanded+ (> 900)
☐ Non rompe con resize real-time

API
☐ Nome segue convenzione CL*
☐ Accetta size (se applicabile)
☐ Accetta variant (se applicabile)
☐ Callback prefisso "on*"
☐ Booleani prefisso "is*"/"has*"

Documentazione
☐ DartDoc completo
☐ Esempio nel docstring
☐ Aggiunto a example/ showcase
☐ Esportato in barrel file

Test
☐ Widget test base
☐ Golden test per ogni variant
☐ Accessibility test
☐ Test su light e dark mode

Coerenza
☐ Animazioni rispettano timing standard
☐ Gli stati hover/press/focus sono definiti
☐ Il componente segue filosofia sobria
☐ Testi hardcoded sono i18n-ready
```

---

## 📝 Note finali

### Maintenance

- La **fonte di verità** è questo documento, non il codice.
- Ogni modifica di design tokens passa da qui prima di essere implementata.
- Breaking changes richiedono bump di major version.
- Deprecation almeno una minor prima di rimuovere API.

### Conflitti con Material Design

Se qualcosa in Flutter Material diverge dalle regole di questa bibbia, **prevalgono le regole di questa bibbia**. Il design system CL è costruito *sopra* Material per sfruttarne l'infrastruttura, ma reimplementa o nasconde tutto ciò che non si allinea.

### Per l'AI Agent

Prima di scrivere un qualsiasi componente o pattern:

1. Cerca nel documento se esiste già.
2. Se esiste, segui le specifiche esatte.
3. Se non esiste o sei incerto, **chiedi** — non dedurre.
4. Se proponi qualcosa di nuovo, documentalo qui prima di implementarlo.

---

*Documento vivo. Versione basata sulla specifica iterativa della conversazione originale.*  
*Ultima revisione: vedi commit history.*
