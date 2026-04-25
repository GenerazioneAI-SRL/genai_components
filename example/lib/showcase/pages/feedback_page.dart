import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Feedback',
      description:
          'Alert (scanable row, no banner), Toast, Spinner, ProgressBar, '
          'CircularProgress, Skeleton, EmptyState, ErrorState.',
      children: [
        ShowcaseSection(
          title: 'Alert list rows',
          subtitle: 'info / success / warning / danger.',
          child: GenaiCard.outlined(
            padding: EdgeInsets.zero,
            useHeaderSlot: false,
            child: Column(
              children: [
                const GenaiAlert.info(
                  title: 'Nuovo quiz disponibile',
                  body: 'Il quiz Fondo N.C. è ora aperto.',
                  meta: '2h fa',
                ),
                const GenaiAlert.success(
                  title: 'Certificato emesso',
                  body: 'Il tuo attestato per Privacy 2026 è stato firmato.',
                  meta: 'ieri',
                ),
                const GenaiAlert.warning(
                  title: 'Scadenza ravvicinata',
                  body: 'Completa Sicurezza entro 14 giorni.',
                  meta: '3gg',
                ),
                GenaiAlert.danger(
                  title: 'Scadenza superata',
                  body: 'Il corso Antiriciclaggio è scaduto il 01/04.',
                  meta: 'oggi',
                  isLastInGroup: true,
                  onDismiss: () {},
                ),
              ],
            ),
          ),
        ),
        ShowcaseSection(
          title: 'Toast',
          subtitle: 'Surface inverse, azione opzionale.',
          child: Column(
            children: [
              ShowcaseRow(
                label: 'variants',
                children: [
                  GenaiToast(
                    message: 'Salvataggio completato.',
                    type: GenaiAlertType.success,
                    actionLabel: 'Annulla',
                    onAction: () {},
                    onDismiss: () {},
                  ),
                ],
              ),
              ShowcaseRow(
                label: 'danger',
                children: [
                  GenaiToast(
                    message: 'Impossibile connettersi al server.',
                    type: GenaiAlertType.danger,
                    actionLabel: 'Riprova',
                    onAction: () {},
                    onDismiss: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Spinner',
          subtitle: 'sm / md / lg — colore ink default.',
          child: const ShowcaseRow(
            label: 'sizes',
            children: [
              GenaiSpinner(size: GenaiSpinnerSize.sm),
              GenaiSpinner(),
              GenaiSpinner(size: GenaiSpinnerSize.lg),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Progress bar',
          subtitle: 'Toni: ink / info / success / warning / danger.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 10,
                child: GenaiProgressBar(
                  value: 0.35,
                  tone: GenaiProgressBarTone.ink,
                ),
              ),
              SizedBox(height: context.spacing.s12),
              const SizedBox(
                height: 10,
                child: GenaiProgressBar(
                  value: 0.65,
                  tone: GenaiProgressBarTone.info,
                ),
              ),
              SizedBox(height: context.spacing.s12),
              const SizedBox(
                height: 10,
                child: GenaiProgressBar(
                  value: 0.90,
                  tone: GenaiProgressBarTone.ok,
                ),
              ),
              SizedBox(height: context.spacing.s12),
              const SizedBox(
                height: 10,
                child: GenaiProgressBar(
                  value: 0.25,
                  tone: GenaiProgressBarTone.warn,
                ),
              ),
              SizedBox(height: context.spacing.s12),
              const SizedBox(
                height: 10,
                child: GenaiProgressBar(
                  value: 0.15,
                  tone: GenaiProgressBarTone.danger,
                ),
              ),
              SizedBox(height: context.spacing.s12),
              const SizedBox(
                height: 10,
                child: GenaiProgressBar(),
              ), // indeterminate
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Circular progress',
          subtitle: 'Con label opzionale.',
          child: const ShowcaseRow(
            label: 'values',
            children: [
              GenaiCircularProgress(value: 0.25, size: 48, showLabel: true),
              GenaiCircularProgress(value: 0.60, size: 64, showLabel: true),
              GenaiCircularProgress(value: 0.90, size: 80, showLabel: true),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Skeleton',
          subtitle: 'Rectangle / pill / circle / text.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              GenaiSkeleton(width: 320, height: 18),
              SizedBox(height: 8),
              GenaiSkeleton(width: 240, height: 14),
              SizedBox(height: 8),
              GenaiSkeleton(
                width: 32,
                height: 32,
                shape: GenaiSkeletonShape.circle,
              ),
              SizedBox(height: 8),
              GenaiSkeleton(
                width: 80,
                height: 24,
                shape: GenaiSkeletonShape.pill,
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Empty / Error state',
          subtitle: 'Composti con icon + title + description + CTA.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenaiCard.outlined(
                child: GenaiEmptyState(
                  icon: LucideIcons.inbox,
                  title: 'Nessun avviso',
                  description:
                      'Quando riceverai una notifica verrà mostrata qui.',
                  primaryAction: GenaiButton.primary(
                    label: 'Vai al dashboard',
                    onPressed: () {},
                  ),
                ),
              ),
              SizedBox(height: context.spacing.s14),
              GenaiCard.outlined(
                child: GenaiErrorState(
                  icon: LucideIcons.triangleAlert,
                  title: 'Errore di caricamento',
                  description: 'Non siamo riusciti a recuperare i tuoi corsi.',
                  retryAction: GenaiButton.primary(
                    label: 'Riprova',
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
