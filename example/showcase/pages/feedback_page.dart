import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Feedback',
      description: 'Spinner · ProgressBar · CircularProgress · Skeleton · Alert · Toast · EmptyState · ErrorState.',
      children: [
        ShowcaseSection(
          title: 'Spinner & Progress',
          child: Column(
            children: [
              ShowcaseRow(label: 'Spinner', children: const [
                GenaiSpinner(size: GenaiSize.xs),
                GenaiSpinner(size: GenaiSize.sm),
                GenaiSpinner(),
                GenaiSpinner(size: GenaiSize.lg),
              ]),
              const ShowcaseRow(label: 'Circular', children: [
                GenaiCircularProgress(value: 0.65),
                GenaiCircularProgress(),
              ]),
              ShowcaseRow(label: 'Bar — determinate', children: [
                SizedBox(width: 240, child: GenaiProgressBar(value: 0.4, label: 'Caricamento')),
                SizedBox(width: 240, child: GenaiProgressBar(value: 0.85, showPercentage: true)),
              ]),
              const ShowcaseRow(label: 'Bar — indeterminate', children: [
                SizedBox(width: 240, child: GenaiProgressBar()),
              ]),
              ShowcaseRow(label: 'Ring', children: const [
                GenaiProgressRing(value: 0.72, centerText: '72%'),
              ]),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Skeleton',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              GenaiSkeleton.text(width: 240),
              SizedBox(height: 8),
              GenaiSkeleton.text(width: 320),
              SizedBox(height: 16),
              GenaiSkeleton.rect(height: 48),
              SizedBox(height: 16),
              GenaiSkeletonRow(),
              SizedBox(height: 16),
              GenaiSkeleton.card(),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'GenaiAlert',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GenaiAlert.info(
                title: 'Info',
                message: 'Questa è una nota informativa.',
                onDismiss: () {},
              ),
              const SizedBox(height: 8),
              GenaiAlert.success(
                title: 'Salvato',
                message: 'Le modifiche sono state salvate.',
              ),
              const SizedBox(height: 8),
              GenaiAlert.warning(
                title: 'Attenzione',
                message: 'Stai per uscire senza salvare.',
              ),
              const SizedBox(height: 8),
              GenaiAlert.error(
                title: 'Errore di rete',
                message: 'Non è stato possibile contattare il server.',
                onDismiss: () {},
              ),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Toast — showGenaiToast',
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            GenaiButton.outline(label: 'Info', onPressed: () => showGenaiToast(context, message: 'Operazione completata', type: GenaiToastType.info)),
            GenaiButton.outline(
                label: 'Success', onPressed: () => showGenaiToast(context, message: 'Salvato con successo', type: GenaiToastType.success)),
            GenaiButton.outline(
                label: 'Warning', onPressed: () => showGenaiToast(context, message: 'Connessione instabile', type: GenaiToastType.warning)),
            GenaiButton.destructive(
                label: 'Error', onPressed: () => showGenaiToast(context, message: 'Errore di salvataggio', type: GenaiToastType.error)),
            GenaiButton.ghost(
                label: 'Top center',
                onPressed: () => showGenaiToast(context, message: 'Posizionamento alto', position: GenaiToastPosition.topCenter)),
          ]),
        ),
        ShowcaseSection(
          title: 'EmptyState',
          child: Wrap(spacing: 16, runSpacing: 16, children: [
            SizedBox(
              width: 320,
              child: GenaiCard.outlined(
                child: GenaiEmptyState(
                  icon: LucideIcons.inbox,
                  title: 'Nessun cliente ancora',
                  description: 'Aggiungi il tuo primo cliente per iniziare.',
                  primaryAction: GenaiButton.primary(label: 'Crea cliente', icon: LucideIcons.plus, onPressed: () {}),
                ),
              ),
            ),
            SizedBox(
              width: 320,
              child: GenaiCard.outlined(
                child: GenaiEmptyState.noResults(
                  icon: LucideIcons.search,
                  title: 'Nessun risultato',
                  description: 'Prova a modificare i filtri di ricerca.',
                ),
              ),
            ),
          ]),
        ),
        ShowcaseSection(
          title: 'ErrorState',
          child: SizedBox(
            width: 480,
            child: GenaiCard.outlined(
              child: GenaiErrorState(
                title: 'Si è verificato un errore',
                description: 'Impossibile caricare i dati.',
                errorCode: 'NET-503',
                onRetry: () {},
              ),
            ),
          ),
        ),
      ],
    );
  }
}
