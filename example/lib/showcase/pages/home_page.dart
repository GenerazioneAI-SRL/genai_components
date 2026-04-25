import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

/// Forma LMS Dashboard v3 replica — the hero showcase for v3.
///
/// Replicates the layout of `Dashboard v3.html` using v3 components:
/// - Greeting + subtitle row.
/// - [GenaiFocusCard] with AI label, highlighted title, meta, actions and a
///   right-column of [GenaiSuggestionItem]s.
/// - 4-up KPI row (ore / obbligatoria / corsi attivi / certificati) with
///   inline sparklines and delta chips.
/// - 2-column grid: left = "Progresso per tipologia" chart card with
///   [GenaiBarRow] × 4, right = alerts feed (3 dismissable items).
/// - "Le tue formazioni" grid of 4 [GenaiFormationCard]s.
/// - "In agenda" list of 3 [GenaiAgendaRow]s.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// ─── Inline Forma LMS mock data ────────────────────────────────────────────
// Keep it local — no fabricated data layer per spec.
class _Tipologia {
  final String id;
  final String nome;
  final String descrizione;
  final int oreFatte;
  final int oreTot;
  final int piani;
  final Color color;
  final IconData icon;
  final bool prioritaria;
  const _Tipologia({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.oreFatte,
    required this.oreTot,
    required this.piani,
    required this.color,
    required this.icon,
    this.prioritaria = false,
  });
}

class _Alert {
  final String id;
  final String titolo;
  final String body;
  final String data;
  final GenaiAlertType livello;
  const _Alert(this.id, this.titolo, this.body, this.data, this.livello);
}

class _Agenda {
  final int day;
  final String month;
  final String titolo;
  final String luogo;
  final String ora;
  final String tipo;
  final GenaiChipTone tone;
  const _Agenda(
    this.day,
    this.month,
    this.titolo,
    this.luogo,
    this.ora,
    this.tipo,
    this.tone,
  );
}

const _tipologie = <_Tipologia>[
  _Tipologia(
    id: 'obbligatoria',
    nome: 'Obbligatoria',
    descrizione: 'Sicurezza, privacy, antiriciclaggio. Scadenze legali.',
    oreFatte: 14,
    oreTot: 24,
    piani: 3,
    color: Color(0xFFB3261E),
    icon: LucideIcons.shield,
    prioritaria: true,
  ),
  _Tipologia(
    id: 'fnc',
    nome: 'Fondo N. C.',
    descrizione: 'Fondo Nuove Competenze — riqualificazione aziendale.',
    oreFatte: 32,
    oreTot: 60,
    piani: 2,
    color: Color(0xFF0B5FD9),
    icon: LucideIcons.sparkles,
  ),
  _Tipologia(
    id: 'tirocinio',
    nome: 'Tirocinio',
    descrizione: 'Percorso on-the-job con tutor aziendale.',
    oreFatte: 0,
    oreTot: 120,
    piani: 1,
    color: Color(0xFF0A7D50),
    icon: LucideIcons.briefcase,
  ),
  _Tipologia(
    id: 'apprendistato',
    nome: 'Apprendistato',
    descrizione: 'Formazione contrattuale per neoassunti.',
    oreFatte: 18,
    oreTot: 80,
    piani: 1,
    color: Color(0xFFA35F00),
    icon: LucideIcons.graduationCap,
  ),
];

class _HomePageState extends State<HomePage> {
  final List<_Alert> _alerts = [
    const _Alert(
      'a1',
      'Scadenza Sicurezza 2026',
      'Il corso obbligatorio "Sicurezza e guardrail" scade il 31/12. Ti mancano 10h.',
      '2h fa',
      GenaiAlertType.danger,
    ),
    const _Alert(
      'a2',
      'Quiz prenotato',
      'Quiz intermedio Fondo N.C. lunedì 28 aprile · 10:00 · Aula Virtuale 3.',
      'ieri',
      GenaiAlertType.info,
    ),
    const _Alert(
      'a3',
      'Nuovo piano disponibile',
      'AI per il business è ora prenotabile. 48 ore · Blended.',
      '3 giorni fa',
      GenaiAlertType.success,
    ),
  ];

  final _agenda = const [
    _Agenda(
      28,
      'APR',
      'Quiz Fondo Nuove Competenze',
      'Aula virtuale 3',
      '10:00',
      'esame',
      GenaiChipTone.warn,
    ),
    _Agenda(
      30,
      'APR',
      'Webinar — AI nei flussi di lavoro',
      'Zoom',
      '14:30',
      'lezione',
      GenaiChipTone.info,
    ),
    _Agenda(
      5,
      'MAG',
      'Revisione piano Obbligatoria',
      'Sede Milano',
      '09:00',
      'meeting',
      GenaiChipTone.info,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    final spacing = context.spacing;

    return Container(
      color: colors.surfacePage,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.pageMargin,
          vertical: spacing.s28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting
            Text(
              'Buongiorno, Francesco',
              style: ty.pageTitle.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: spacing.s4),
            Text(
              'Venerdì 24 aprile · ${_alerts.length} avvisi da leggere, 1 urgente',
              style: ty.bodySm.copyWith(color: colors.textSecondary),
            ),

            SizedBox(height: spacing.s18),
            _buildFocusCard(context),

            SizedBox(height: spacing.s18),
            _buildKpiRow(context),

            SizedBox(height: spacing.s18),
            _buildGrid2(context),

            SizedBox(height: spacing.s28),
            _SectionHead(title: 'Le tue formazioni', action: 'Vedi tutte'),
            SizedBox(height: spacing.s14),
            _buildFormationsGrid(context),

            SizedBox(height: spacing.s28),
            _SectionHead(title: 'In agenda', action: 'Apri calendario'),
            SizedBox(height: spacing.s14),
            _buildAgendaCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusCard(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return GenaiFocusCard(
      aiLabel: 'Prossima azione consigliata',
      title: Text.rich(
        TextSpan(
          style: ty.focusTitle.copyWith(color: colors.textPrimary),
          children: [
            const TextSpan(text: 'Riprendi '),
            TextSpan(
              text: '"Sicurezza e guardrail"',
              style: ty.focusTitle.copyWith(color: colors.colorInfo),
            ),
            const TextSpan(text: ' — ti mancano '),
            TextSpan(
              text: '6 minuti',
              style: ty.focusTitle.copyWith(color: colors.colorInfo),
            ),
            const TextSpan(
              text: ' per completare la lezione e accedere al quiz finale.',
            ),
          ],
        ),
      ),
      meta: [
        _metaPair(context, LucideIcons.book, 'Formazione obbligatoria'),
        _metaPair(context, LucideIcons.clock, '14:00 / 20:00'),
        _metaPair(context, LucideIcons.target, 'Obiettivo: 6.5h / 5h'),
      ],
      actions: [
        GenaiButton.primary(
          label: 'Riprendi lezione',
          icon: LucideIcons.play,
          onPressed: () {},
        ),
        GenaiButton.secondary(label: 'Posticipa a domani', onPressed: () {}),
        GenaiButton.ghost(label: 'Altre opzioni', onPressed: () {}),
      ],
      suggestions: [
        GenaiSuggestionItem(
          dotColor: colors.colorDanger,
          title: 'Scadenza vicina',
          subtitle: 'Sicurezza · 251 gg',
          metaRight: 'prior.',
          onTap: () {},
        ),
        GenaiSuggestionItem(
          dotColor: colors.colorInfo,
          title: 'Quiz intermedio',
          subtitle: 'prenotato lun 28 · 10:00',
          metaRight: '4gg',
          onTap: () {},
        ),
        GenaiSuggestionItem(
          dotColor: colors.colorSuccess,
          title: 'Nuovo piano',
          subtitle: 'AI per il business · 48h',
          metaRight: 'novità',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _metaPair(BuildContext context, IconData ic, String text) {
    final colors = context.colors;
    final ty = context.typography;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(ic, size: 14, color: colors.textSecondary),
        SizedBox(width: context.spacing.s6),
        Text(text, style: ty.bodySm.copyWith(color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildKpiRow(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, cons) {
        final isWide = cons.maxWidth >= 900;
        final cols = isWide ? 4 : (cons.maxWidth >= 600 ? 2 : 1);
        final gap = context.spacing.s14;
        final cellW = (cons.maxWidth - gap * (cols - 1)) / cols;
        final obligPct = _tipologie[0].oreFatte / _tipologie[0].oreTot;
        final cards = <Widget>[
          GenaiKpiCard(
            label: 'Ore formazione',
            value: '64',
            unit: 'h',
            delta: 0.18,
            sparkline: const [3.2, 4.1, 5.0, 3.8, 4.5, 5.2, 6.0, 6.5],
          ),
          GenaiKpiCard(
            label: 'Obbligatoria',
            value: '${(obligPct * 100).round()}',
            unit: '%',
            sparkline: [0.2, 0.25, 0.33, 0.4, 0.5, 0.55, 0.58, obligPct],
            delta: -0.05,
          ),
          GenaiKpiCard(
            label: 'Corsi attivi',
            value: '7',
            sparkline: const [4, 5, 5, 6, 6, 7, 7, 7],
            delta: 0.14,
          ),
          GenaiKpiCard(
            label: 'Certificati',
            value: '5',
            sparkline: const [2, 3, 3, 4, 4, 5, 5, 5],
            delta: 0.0,
          ),
        ];
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final c in cards) SizedBox(width: cellW, child: c)],
        );
      },
    );
  }

  Widget _buildGrid2(BuildContext context) {
    final spacing = context.spacing;
    return LayoutBuilder(
      builder: (ctx, cons) {
        final isWide = cons.maxWidth >= 900;
        final left = _buildChartCard(context);
        final right = _buildAlertsCard(context);
        if (!isWide) {
          return Column(
            children: [
              left,
              SizedBox(height: spacing.s14),
              right,
            ],
          );
        }
        final gap = spacing.s14;
        final leftW = (cons.maxWidth - gap) * 2 / 3;
        final rightW = (cons.maxWidth - gap) * 1 / 3;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: leftW, child: left),
            SizedBox(width: gap),
            SizedBox(width: rightW, child: right),
          ],
        );
      },
    );
  }

  Widget _buildChartCard(BuildContext context) {
    final colors = context.colors;
    return GenaiCard.outlined(
      headerTitle: 'Progresso per tipologia',
      headerSubtitle: '4 tipologie',
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.s20,
        vertical: context.spacing.s14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final t in _tipologie)
            GenaiBarRow(
              label: t.nome,
              value: t.oreFatte / t.oreTot,
              valueLabel: '${t.oreFatte}/${t.oreTot}h',
              barColor: t.oreFatte == 0 ? colors.textTertiary : t.color,
            ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard(BuildContext context) {
    final spacing = context.spacing;
    return GenaiCard.outlined(
      headerTitle: 'Avvisi',
      headerSubtitle: '${_alerts.length} nuovi',
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _alerts.length; i++)
            GenaiAlert(
              type: _alerts[i].livello,
              title: _alerts[i].titolo,
              body: _alerts[i].body,
              meta: _alerts[i].data,
              isLastInGroup: i == _alerts.length - 1,
              onDismiss: () => setState(
                () => _alerts.removeWhere((x) => x.id == _alerts[i].id),
              ),
            ),
          if (_alerts.isEmpty)
            Padding(
              padding: EdgeInsets.all(spacing.s20),
              child: Text(
                'Nessun avviso',
                style: context.typography.bodySm.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormationsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, cons) {
        final isWide = cons.maxWidth >= 1000;
        final cols = isWide ? 4 : (cons.maxWidth >= 600 ? 2 : 1);
        final gap = context.spacing.s14;
        final cellW = (cons.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final t in _tipologie)
              SizedBox(
                width: cellW,
                child: GenaiFormationCard(
                  icon: t.icon,
                  iconBg: t.color,
                  name: t.nome,
                  description: t.descrizione,
                  oreTotali: t.oreTot,
                  progress: t.oreFatte / t.oreTot,
                  onTap: () {},
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAgendaCard(BuildContext context) {
    return GenaiCard.outlined(
      padding: EdgeInsets.zero,
      useHeaderSlot: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _agenda.length; i++) ...[
            GenaiAgendaRow(
              day: _agenda[i].day,
              month: _agenda[i].month,
              title: _agenda[i].titolo,
              subtitle: '${_agenda[i].luogo} · ${_agenda[i].ora}',
              meta: [
                GenaiChip.readonly(
                  label: _agenda[i].tipo,
                  tone: _agenda[i].tone,
                ),
              ],
              onTap: () {},
            ),
            if (i < _agenda.length - 1) const GenaiDivider(),
          ],
        ],
      ),
    );
  }
}

class _SectionHead extends StatelessWidget {
  final String title;
  final String action;
  const _SectionHead({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ty = context.typography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: ty.sectionTitle.copyWith(color: colors.textPrimary),
          ),
        ),
        GenaiLinkButton(
          label: action,
          icon: LucideIcons.arrowRight,
          onPressed: () {},
        ),
      ],
    );
  }
}
