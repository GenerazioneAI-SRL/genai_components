// Part of [AiAssistantController] — voice (STT) input control.
//
// Responsibilities:
// - Starting and stopping live voice transcription.
// - Filtering low-confidence / noise transcriptions.
// - Routing the final recognized text into [sendMessage].
//
// TTS output side (speakSummary, speak) lives in [_ChatStateManager] and
// [_ActionFeedManager] alongside the events that produce speech, so the
// `_voiceOutput` service is touched in three places by design.
part of '../ai_assistant_controller.dart';

extension _VoiceManager on AiAssistantController {
  /// Start voice input. Recognized speech is sent as a message.
  Future<void> _startVoiceInputImpl() async {
    if (_voiceInput == null || _isListening) return;
    // Allow voice input during ask_user but not during other processing.
    if (_isProcessing && !_waitingForUserResponse) return;
    AiLogger.log('Starting voice input', tag: 'Voice');
    _emit(AiEventType.voiceInputStarted, {'locales': _config.preferredLocales});

    _isListening = true;
    _partialTranscription = null;
    if (_config.enableHaptics) HapticFeedback.mediumImpact();
    _safeNotify();

    try {
      await _voiceInput!.startListening(
        preferredLocales: _config.preferredLocales,
        onResult: (text, confidence) {
          _isListening = false;
          _partialTranscription = null;

          // Confidence filtering: discard noise / false starts.
          if (text.trim().length < 2 ||
              (confidence > 0 && confidence < 0.3 && text.trim().length < 5)) {
            AiLogger.log(
              'Voice filtered: "$text" (confidence=${confidence.toStringAsFixed(2)}, len=${text.trim().length})',
              tag: 'Voice',
            );
            _emit(AiEventType.voiceInputError, {
              'text': text,
              'confidence': confidence,
              'error': 'filtered_low_confidence',
            });
            _partialTranscription = "Didn't catch that. Try again.";
            _safeNotify();
            // Clear the "didn't catch" message after a moment.
            Future.delayed(const Duration(seconds: 2), () {
              if (!_disposed &&
                  _partialTranscription == "Didn't catch that. Try again.") {
                _partialTranscription = null;
                _safeNotify();
              }
            });
            return;
          }

          _emit(AiEventType.voiceInputCompleted, {
            'text': text,
            'confidence': confidence,
            'accepted': true,
          });
          if (_config.enableHaptics) HapticFeedback.lightImpact();
          _safeNotify();
          if (text.trim().isNotEmpty) {
            sendMessage(text, isVoice: true);
          }
        },
        onPartial: (partialText) {
          _partialTranscription = partialText;
          _safeNotify();
        },
      );
    } catch (_) {
      _isListening = false;
      _partialTranscription = null;
      _safeNotify();
    }
  }

  /// Stop voice input.
  Future<void> _stopVoiceInputImpl() async {
    if (_voiceInput == null || !_isListening) return;
    await _voiceInput!.stopListening();
    _isListening = false;
    _safeNotify();
  }
}
