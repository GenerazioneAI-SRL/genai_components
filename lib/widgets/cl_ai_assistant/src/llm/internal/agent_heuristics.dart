/// Pure heuristic helpers used by [ReactAgent] to:
/// - detect question-shaped text from the LLM,
/// - block redundant or unnecessary `ask_user` calls,
/// - decide when a search-bar retry is warranted,
/// - extract comparable word sets for similarity checks.
///
/// All methods are stateless and side-effect free. Extracted from
/// `react_agent.dart` to keep the agent file under the size budget without
/// changing behavior.
class AgentHeuristics {
  const AgentHeuristics._();

  /// Heuristic: does the user's message ask for DETAILS about a specific item
  /// — as opposed to a simple value query like "what's my balance?".
  /// Used in verification to catch shallow list-view responses that should
  /// have drilled into a detail screen.
  static bool isDetailInfoQuery(String message) {
    final lower = message.toLowerCase();
    const detailIntents = [
      'tell me about',
      'details',
      'detail',
      'what did i',
      'show me my',
      'info about',
      'information about',
      'about my',
      'describe',
    ];
    for (final intent in detailIntents) {
      if (lower.contains(intent)) return true;
    }
    // "last/recent/my" + noun pattern (e.g. "my last order").
    if (lower.contains('last') ||
        lower.contains('recent') ||
        lower.contains('latest')) {
      // If the message has a recency prefix and is asking about *something*,
      // it's likely a detail query. The LLM will determine the specifics.
      if (lower.contains('my') || lower.contains('the')) return true;
    }
    return false;
  }

  /// Heuristic: does the text look like a question directed at the user?
  /// Used to detect when the LLM returns a question as text instead of
  /// using the ask_user tool.
  static bool looksLikeQuestion(String text) {
    final trimmed = text.trim();
    if (trimmed.endsWith('?')) return true;
    final lower = trimmed.toLowerCase();
    // Common question patterns directed at the user.
    return lower.contains('do you want') ||
        lower.contains('would you like') ||
        lower.contains('shall i') ||
        lower.contains('should i') ||
        lower.contains('can you tell me') ||
        lower.contains('could you') ||
        lower.contains('please provide') ||
        lower.contains('please tell me') ||
        lower.contains('what is your') ||
        lower.contains('which one');
  }

  /// Detects if the agent is asking an unnecessary confirmation question
  /// when the user already expressed clear action intent.
  ///
  /// E.g., user says "order X" and agent asks "Would you like to add X?"
  /// — the user ALREADY said to do it.
  static bool isUnnecessaryConfirmation(String question, String userMessage) {
    final lowerQ = question.toLowerCase();

    // Patterns that indicate the agent is confirming an action.
    const confirmPatterns = [
      'would you like to',
      'shall i',
      'do you want me to',
      'do you want to',
      'should i',
      'want me to',
    ];

    final hasConfirmPattern = confirmPatterns.any((p) => lowerQ.contains(p));
    if (!hasConfirmPattern) return false;

    // The user's message must be imperative (not a question or info request).
    final lowerU = userMessage.toLowerCase().trim();
    if (lowerU.endsWith('?')) return false;
    // Short imperative messages (< 60 chars) that aren't questions are likely commands.
    return lowerU.length < 60;
  }

  /// Detects if the agent is asking about quantity when the user already
  /// specified it in their original message.
  ///
  /// E.g., user says "add 3 items" and agent asks "How many?"
  static bool isRedundantQuantityQuestion(
    String question,
    String userMessage,
  ) {
    final lowerQ = question.toLowerCase();

    // Question must be asking about quantity.
    const quantityPatterns = [
      'how many',
      'how much',
      'quantity',
      'kitna',
      'kitne',
      'kitni',
    ];
    final isQuantityQuestion = quantityPatterns.any((p) => lowerQ.contains(p));
    if (!isQuantityQuestion) return false;

    // User's message must contain a digit or a common number word.
    final lowerU = userMessage.toLowerCase();
    if (RegExp(r'\d+').hasMatch(lowerU)) return true;

    // Common number words across languages — these are basic numerals,
    // not domain-specific terms.
    const numberWords = [
      // English
      'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
      'nine', 'ten', 'half', 'quarter', 'dozen',
      // Hindi (transliterated)
      'ek', 'do', 'teen', 'char', 'paanch', 'panch', 'chhah', 'saat',
      'aath', 'nau', 'das', 'aadha', 'pav',
      // Common units
      'kilo', 'kg', 'gram', 'packet', 'piece', 'litre', 'liter',
    ];
    return numberWords.any((w) {
      // Word boundary check to avoid false matches (e.g. "done" containing "do").
      final idx = lowerU.indexOf(w);
      if (idx == -1) return false;
      final before = idx > 0 ? lowerU[idx - 1] : ' ';
      final after =
          idx + w.length < lowerU.length ? lowerU[idx + w.length] : ' ';
      return !RegExp(r'[a-z]').hasMatch(before) &&
          !RegExp(r'[a-z]').hasMatch(after);
    });
  }

  /// Detects if the agent is asking a question it already asked earlier
  /// in this conversation turn. Uses word overlap to detect rephrased duplicates.
  static bool isDuplicateAskUser(String question, List<String> history) {
    if (history.isEmpty) return false;
    final qWords = extractWords(question);
    if (qWords.isEmpty) return false;

    for (final prev in history) {
      final pWords = extractWords(prev);
      if (pWords.isEmpty) continue;
      final overlap = qWords.intersection(pWords).length;
      final similarity = overlap / qWords.length;
      if (similarity > 0.6) return true;
    }
    return false;
  }

  /// Extract meaningful words from a string for overlap comparison.
  static Set<String> extractWords(String text) {
    const stopWords = {
      'the',
      'a',
      'an',
      'is',
      'are',
      'was',
      'were',
      'to',
      'for',
      'of',
      'in',
      'on',
      'at',
      'by',
      'do',
      'you',
      'i',
      'me',
      'my',
      'your',
      'it',
      'this',
      'that',
      'and',
      'or',
      'but',
      'would',
      'like',
      'want',
      'please',
      'could',
      'should',
      'can',
      'will',
      'shall',
    };
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 1 && !stopWords.contains(w))
        .toSet();
  }

  /// Heuristic: does the user's message imply they need to search for something?
  /// Used to trigger a search-bar retry when the agent incorrectly claims
  /// it cannot find a search field.
  static bool userNeedsSearch(String message) {
    final lower = message.toLowerCase();
    // Explicit search intent.
    if (lower.contains('search') ||
        lower.contains('find') ||
        lower.contains('look for')) {
      return true;
    }
    // Imperative commands that typically require searching:
    // "order X", "buy X", "add X", "book X", "get X"
    const actionVerbs = [
      'order',
      'buy',
      'add',
      'book',
      'get',
      'manga',
      'mangao',
    ];
    for (final verb in actionVerbs) {
      // verb followed by a space and something = likely needs search
      if (lower.contains('$verb ')) return true;
    }
    return false;
  }

  /// Detects if the agent's text response claims it cannot find a search bar.
  static bool claimsNoSearchBar(String text) {
    final lower = text.toLowerCase();
    const patterns = [
      'unable to find the search',
      'cannot find the search',
      'can\'t find the search',
      'couldn\'t find the search',
      'could not find the search',
      'don\'t see a search',
      'do not see a search',
      'no search bar',
      'no search field',
      'search bar is not',
      'search field is not',
      'i am unable to find a search',
      'i don\'t see a text field',
      'unable to locate the search',
      'unable to find a text field',
    ];
    return patterns.any((p) => lower.contains(p));
  }
}
