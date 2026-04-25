import 'package:flutter/material.dart';
import 'package:genai_components/genai_components.dart';

import '../widgets/showcase_section.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  List<GenaiSurveyQuestion> _builderQuestions = [];

  static final _sampleQuestions = [
    GenaiSurveyQuestion(
      question: 'Qual è il tuo livello di soddisfazione?',
      isMandatory: true,
      singleChoice: true,
      isRating: true,
      isStarRating: true,
      options: const [],
    ),
    GenaiSurveyQuestion(
      question: 'Quali funzionalità utilizzi più spesso?',
      isMandatory: true,
      singleChoice: false,
      options: [
        GenaiSurveyOption(id: 'opt_1', text: 'Dashboard'),
        GenaiSurveyOption(id: 'opt_2', text: 'Reportistica'),
        GenaiSurveyOption(id: 'opt_3', text: 'Notifiche'),
        GenaiSurveyOption(id: 'opt_4', text: 'Esportazione dati'),
      ],
    ),
    GenaiSurveyQuestion(
      question: 'Lasciaci un commento libero',
      isMandatory: false,
      options: const [],
    ),
  ];

  static final _sampleResults = [
    GenaiSurveyResult(
      question: 'Qual è il tuo livello di soddisfazione?',
      answers: const [
        {'': '4'},
      ],
    ),
    GenaiSurveyResult(
      question: 'Quali funzionalità utilizzi più spesso?',
      answers: const [
        {'opt_1': 'Dashboard'},
        {'opt_3': 'Notifiche'},
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return ListView(
      padding: EdgeInsets.all(spacing.s6),
      children: [
        ShowcaseSection(
          title: 'GenaiSurveyViewer',
          subtitle:
              'Sondaggio compilabile con domande a scelta singola, multipla, rating, testo libero.',
          child: GenaiSurveyViewer.fromArray(
            questions: _sampleQuestions,
            onSave: (results) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Salvate ${results.length} risposte.')),
              );
            },
          ),
        ),
        SizedBox(height: spacing.s8),
        ShowcaseSection(
          title: 'GenaiSurveyResultViewer',
          subtitle: 'Visualizzatore read-only delle risposte raccolte.',
          child: GenaiSurveyResultViewer.fromArray(questions: _sampleResults),
        ),
        SizedBox(height: spacing.s8),
        ShowcaseSection(
          title: 'GenaiSurveyBuilder',
          subtitle:
              'Editor visuale per la creazione di sondaggi con 8 tipi di domanda.',
          child: GenaiSurveyBuilder.fromArray(
            questions: _builderQuestions,
            onSurveyChange: (q) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() => _builderQuestions = q);
              });
            },
          ),
        ),
      ],
    );
  }
}
