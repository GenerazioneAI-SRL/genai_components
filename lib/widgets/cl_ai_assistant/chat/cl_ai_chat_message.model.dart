import 'package:flutter/widgets.dart';

import '../../../enums/message_role.enum.dart';

/// Stato di un messaggio della chat ([CLAiChatMessage.status]).
enum CLAiChatStatus {
  /// Messaggio dell'utente in viaggio verso il server (bolla attenuata, «Invio…»).
  sending,

  /// Risposta in arrivo (streaming): il testo può crescere, accanto c'è un indicatore.
  pending,

  /// Messaggio completo.
  done,

  /// Invio o risposta falliti: bordo di errore, [CLAiChatMessage.errorText] e «Riprova» se c'è
  /// [CLAiChatMessage.onRetry].
  error,
}

/// Fonte citata da un messaggio. Nel testo il segnaposto `[n]` (1-based) diventa un riferimento
/// cliccabile alla citazione `n`; sotto la bolla le citazioni compaiono come elenco.
@immutable
class CLAiCitation {
  const CLAiCitation({required this.label, this.subtitle, this.onTap});

  /// Titolo della fonte (es. «Regolamento ferie 2026»).
  final String label;

  /// Riga secondaria facoltativa (es. «Documento · pag. 4»).
  final String? subtitle;

  /// Apertura della fonte. Senza, la citazione è solo testo.
  final VoidCallback? onTap;
}

/// Suggerimento cliccabile dello stato vuoto di [CLAiChatView].
@immutable
class CLAiChatSuggestion {
  const CLAiChatSuggestion({required this.label, this.message, this.icon});

  /// Testo della chip.
  final String label;

  /// Testo inviato al tap. Di serie [label].
  final String? message;

  /// Icona facoltativa della chip.
  final IconData? icon;

  /// Il testo da inviare: [message] o, se manca, [label].
  String get text => message ?? label;
}

/// Messaggio di [CLAiChatView]. Solo dati: nessuna logica di agente.
///
/// - [role]: `user` (bolla a destra), `assistant` (bolla a sinistra con avatar), `tool` (riga
///   compatta con l'icona di uno strumento), `system` (nota centrata).
/// - [markdown]: se `true` il testo è reso con il markdown di base (titoli, elenchi, blocchi di
///   codice, grassetto, corsivo, `codice`, link). I segnaposto `[n]` delle [citations] valgono in
///   entrambi i casi.
/// - [footer]: widget sotto la bolla, es. una card azione con «Conferma»/«Rifiuta».
@immutable
class CLAiChatMessage {
  const CLAiChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.markdown = false,
    this.status = CLAiChatStatus.done,
    this.errorText,
    this.onRetry,
    this.onEdit,
    this.citations = const [],
    this.footer,
    this.createdAt,
  });

  /// Identità stabile: serve all'animazione d'entrata (un id già visto non si anima di nuovo).
  final String id;
  final MessageRole role;
  final String text;
  final bool markdown;
  final CLAiChatStatus status;

  /// Testo dell'errore. Di serie «Messaggio non inviato» (utente) o «Risposta non riuscita».
  final String? errorText;

  /// Con [status] `error` mostra «Riprova».
  final VoidCallback? onRetry;

  /// Mostra «Modifica» sotto la bolla: il testo diventa modificabile e al salvataggio arriva qui.
  final ValueChanged<String>? onEdit;

  final List<CLAiCitation> citations;
  final Widget? footer;
  final DateTime? createdAt;

  bool get isUser => role == MessageRole.user;

  CLAiChatMessage copyWith({
    String? text,
    bool? markdown,
    CLAiChatStatus? status,
    String? errorText,
    VoidCallback? onRetry,
    ValueChanged<String>? onEdit,
    List<CLAiCitation>? citations,
    Widget? footer,
  }) =>
      CLAiChatMessage(
        id: id,
        role: role,
        text: text ?? this.text,
        markdown: markdown ?? this.markdown,
        status: status ?? this.status,
        errorText: errorText ?? this.errorText,
        onRetry: onRetry ?? this.onRetry,
        onEdit: onEdit ?? this.onEdit,
        citations: citations ?? this.citations,
        footer: footer ?? this.footer,
        createdAt: createdAt,
      );
}
