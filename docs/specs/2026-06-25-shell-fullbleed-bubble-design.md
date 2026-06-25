# Shell full-bleed + bolla strumenti — Design

**Data:** 2026-06-25
**Branch:** `feat/shell-fullbleed-bubble` (in `genai_components` e `skillera_emp`)
**Banco di prova:** `skillera_emp` (app più piccola). Componente modificato: `CLAdaptiveShell` in `genai_components`.

## Obiettivo

Ridisegnare lo shell delle app Skillera con un layout "full-bleed":
- Il contenuto della pagina scorre **edge-to-edge** sotto le barre.
- **Header** in alto e **barra in basso** sono in vetro smerigliato (blur), il contenuto si intravede sotto mentre scorre.
- La barra in basso (mobile) diventa la **"bolla degli strumenti"**: l'unico posto dove vive ciò che puoi fare nella pagina corrente.

Renderer web confermato **CanvasKit** → il blur ha performance accettabili, non è un blocco.

## Modello di layout

Contenuto a tutto schermo, barre sovrapposte sopra (non in flusso).

```
[ viewport ]
├─ contenuto pagina   → riempie tutto, scrollabile edge-to-edge
├─ barra in basso     → sovrapposta in basso, blur, altezza VARIABILE (solo mobile)
├─ header             → sovrapposto in alto, blur, altezza FISSA
└─ menu/sidebar       → a sinistra, sopra l'header → evita il "taglio" (clip) del blur
```

Il menu sta **sopra** l'header nell'ordine di sovrapposizione: così l'header può essere
una striscia di vetro continua da bordo a bordo, e il menu opaco ci galleggia sopra
pulito (niente blur che sbava sul menu).

## Spazi liberi per il contenuto (insets) — li gestisce lo Scaffold

Problema: se il contenuto scorre sotto le barre, l'inizio e la fine rischiano di
restare nascosti. Soluzione: **non calcoliamo le altezze a mano**, le gestisce lo
`Scaffold` di Flutter con due interruttori:

- `extendBodyBehindAppBar` → il contenuto passa sotto l'header; lo Scaffold riserva
  in cima lo spazio pari all'altezza dell'header.
- `extendBody` → il contenuto passa sotto la barra in basso; **lo Scaffold misura
  quanto è alta la barra in quel momento** e riserva in fondo lo spazio giusto.

La misura avviene durante il calcolo del layout, non dopo: quando la barra in basso
cambia altezza (es. apri i filtri), lo spazio si aggiusta **nello stesso istante**,
senza scatti.

**Mobile** → `Scaffold` con `appBar` (header blur, altezza fissa) +
`bottomNavigationBar` (la bolla strumenti, altezza variabile) + body full-bleed.
Insets automatici.

**Desktop / tablet** → niente barra in basso → niente altezza variabile. Inset in
alto = altezza header (costante), a sinistra = larghezza menu (costante). Banale.
La sovrapposizione menu-sopra-header si fa con uno Stack manuale (tutto fisso, facile).

## La barra in basso = bolla degli strumenti (mobile)

Contenitore generico. **Ogni pagina dichiara cosa metterci** (tramite gli slot già
esistenti dello shell): la bolla non conosce il significato dei controlli, li mostra.

Esempi di cosa una pagina può pubblicare nella bolla:
- Tabella → ricerca, filtri, azioni, barra bulk sulla selezione.
- Calendario → stepper avanti/indietro mesi.
- Altre pagine → toggle cambio vista, o nulla.

Stati della bolla:
1. **Normale** → solo navigazione (sezioni dell'app).
2. **Pagina con strumenti** → navigazione + i controlli pubblicati dalla pagina.
3. **Pannello aperto** (es. filtri) → la bolla si espande e mostra il pannello dentro
   di sé, con **tetto massimo di altezza + scorrimento interno** (~45% schermo) così
   non si mangia mai tutto lo schermo.
4. **Selezione righe attiva** → la bolla diventa barra bulk ("N selezionati" + azioni),
   compare **da sola** quando selezioni la prima riga, sostituisce la navigazione,
   sparisce deselezionando.

Tutto in un solo contenitore → l'utente guarda sempre lì per sapere cosa può fare.

## Comportamenti da confermare

1. **Filtri + selezione righe insieme** → *proposta: uno alla volta.* Selezioni righe
   → la bolla va in modo "bulk" e i filtri si chiudono. Più semplice, meno confusione.
2. **Riga navigazione quando un pannello (filtri) è aperto** → *proposta: sparisce*,
   torna quando chiudi il pannello. Stai operando, non navigando.

## Strategia componente condiviso

`CLAdaptiveShell` vive in `genai_components`, usato da **admin, emp, mentore**. Per non
rompere le altre app:

- Nuovo comportamento **opt-in** via configurazione (es. flag in `CLShellConfig`).
  `emp` lo attiva, `admin`/`mentore` restano come ora. Compatibilità totale.
- Si valuta di renderlo default solo dopo aver validato su `emp`.

## Rischi / cose da verificare presto

- **Performance blur su scroll** — due blur (header + bolla) ridisegnati durante lo
  scorrimento. CanvasKit regge, ma va provato su lista lunga reale; isolare i ridisegni.
- **Migrazione pagine** — col full-bleed ogni pagina deve **lasciare lo spazio**
  riservato dallo Scaffold (usando `SafeArea` / lo spazio già calcolato). Una pagina
  che forza padding zero nasconde il contenuto sotto le barre. Da rivedere pagina per
  pagina su `emp`.
- **Pannello filtri alto** — col tetto al 45% + scroll interno il contenuto dietro si
  stringe parecchio quando i filtri sono aperti. Accettato su mobile.

## Fuori scope (per ora)

- Desktop "tools bubble" (la bolla è mobile; desktop tiene header + sidebar).
- Restyle estetico oltre il blur (colori, glass surfaces tipo skillera_test).
- Propagazione ad admin/mentore (prima si valida su emp).
