import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';

/// Riassunto di una conversazione salvata (per la lista history).
class AiConversationSummary {
  final String id;
  final String title;
  final DateTime updatedAt;
  const AiConversationSummary({required this.id, required this.title, required this.updatedAt});
}

/// Persistenza conversazioni dell'assistente. Scoped per `scope` (es. tenantId)
/// → conversazioni di tenant diversi non si mischiano (isolamento). Pluggable:
/// l'app fornisce un'implementazione via [AiAssistantConfig.conversationStore].
abstract class AiConversationStore {
  /// Conversazioni salvate nello scope, ordinate per [updatedAt] desc.
  Future<List<AiConversationSummary>> list(String scope);

  /// Messaggi di una conversazione. Lista vuota se assente.
  Future<List<AiChatMessage>> load(String scope, String id);

  /// Crea/aggiorna una conversazione.
  Future<void> save(String scope, String id, String title, List<AiChatMessage> messages);

  /// Elimina una conversazione.
  Future<void> delete(String scope, String id);
}

/// Implementazione su `shared_preferences`. Una entry JSON per scope:
/// `cl_ai_conv:<scope>` → lista di `{id, title, updatedAt, messages:[...]}`.
/// Tiene al massimo [maxConversations] conversazioni (le più recenti).
class SharedPrefsAiConversationStore implements AiConversationStore {
  SharedPrefsAiConversationStore({this.maxConversations = 20});

  final int maxConversations;

  static const _prefix = 'cl_ai_conv:';
  String _key(String scope) => '$_prefix$scope';

  Future<List<Map<String, dynamic>>> _readAll(String scope) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(scope));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeAll(String scope, List<Map<String, dynamic>> convs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(scope), jsonEncode(convs));
  }

  @override
  Future<List<AiConversationSummary>> list(String scope) async {
    final convs = await _readAll(scope);
    final out = [
      for (final c in convs)
        AiConversationSummary(
          id: c['id'] as String,
          title: (c['title'] as String?) ?? 'Conversazione',
          updatedAt: DateTime.tryParse(c['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
    ];
    out.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return out;
  }

  @override
  Future<List<AiChatMessage>> load(String scope, String id) async {
    final convs = await _readAll(scope);
    final conv = convs.where((c) => c['id'] == id).cast<Map<String, dynamic>?>().firstWhere((_) => true, orElse: () => null);
    if (conv == null) return [];
    final msgs = (conv['messages'] as List?) ?? [];
    return [for (final m in msgs) AiChatMessage.fromJson(m as Map<String, dynamic>)];
  }

  @override
  Future<void> save(String scope, String id, String title, List<AiChatMessage> messages) async {
    final convs = await _readAll(scope);
    final entry = {
      'id': id,
      'title': title,
      'updatedAt': DateTime.now().toIso8601String(),
      'messages': [for (final m in messages) m.toJson()],
    };
    final idx = convs.indexWhere((c) => c['id'] == id);
    if (idx >= 0) {
      convs[idx] = entry;
    } else {
      convs.add(entry);
    }
    // Ordina per updatedAt desc e taglia alle più recenti.
    convs.sort((a, b) {
      final ua = DateTime.tryParse(a['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final ub = DateTime.tryParse(b['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return ub.compareTo(ua);
    });
    if (convs.length > maxConversations) convs.removeRange(maxConversations, convs.length);
    await _writeAll(scope, convs);
  }

  @override
  Future<void> delete(String scope, String id) async {
    final convs = await _readAll(scope);
    convs.removeWhere((c) => c['id'] == id);
    await _writeAll(scope, convs);
  }
}
