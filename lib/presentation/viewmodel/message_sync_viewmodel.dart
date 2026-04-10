import 'package:flutter/foundation.dart';
import '../../core/config.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';

class MessageSyncViewModel extends ChangeNotifier {
  MessageSyncViewModel({required MessageRepository repository})
      : _repo = repository;

  final MessageRepository _repo;

  List<Message> _messages = [];
  List<String> _logs = [];
  bool _isRunning = false;
  String _status = 'Ready. Tap "Start Test" to begin.';

  List<Message> get messages => List.unmodifiable(_messages);
  List<String> get logs => List.unmodifiable(_logs);
  bool get isRunning => _isRunning;
  String get status => _status;

  void _log(String msg) {
    debugPrint(msg);
    _logs = [..._logs, msg];
    notifyListeners();
  }

  void _addWsMessage(Message msg) {
    _messages = [..._messages, msg]
      ..sort((a, b) => a.counter.compareTo(b.counter));
    notifyListeners();
  }

  Future<void> runTest() async {
    if (_isRunning) return;
    _isRunning = true;
    _messages = [];
    _logs = [];
    _status = 'Running...';
    notifyListeners();

    try {
      // Reset server
      await _repo.reset();
      _log('[RESET] Server state cleared');

      // Connect, send 30 messages, receive live WS responses
      _log('[WS] Connecting...');
      await for (final msg in _repo.sendAndReceive(kTotalMessages, onSend: _log)) {
        _log('[WS RECV] counter=${msg.counter}, '
            'echo_message=${msg.echoMessage}, ts=${msg.ts}');
        _addWsMessage(msg);
      }
      _log('[WS] Disconnected');

      // Fill in missing messages from the API
      _log('[API] Fetching authoritative message list...');
      final apiMessages = await _repo.fetchMessages();
      final seenCounters = {for (final m in _messages) m.counter};
      final merged = [
        ..._messages,
        ...apiMessages.where((m) => !seenCounters.contains(m.counter)),
      ]..sort((a, b) => a.counter.compareTo(b.counter));

      _log('');
      _log('=== RESULTS (monotonically ordered by counter) ===');
      for (final msg in merged) {
        _log('[RESULT] counter=${msg.counter} | '
            '${msg.echoMessage} | ts=${msg.ts}');
      }

      // Verify monotonicity
      bool isMonotonic = true;
      for (int i = 1; i < merged.length; i++) {
        if (merged[i].counter <= merged[i - 1].counter) {
          isMonotonic = false;
          break;
        }
      }
      _log('[DONE] ${merged.length} messages received, '
          'monotonically increasing: $isMonotonic');

      _messages = merged;
      _status = 'Done — ${merged.length} messages | Monotonic: $isMonotonic';
    } catch (e, st) {
      _log('[ERROR] $e\n$st');
      _status = 'Error: $e';
    } finally {
      _isRunning = false;
      notifyListeners();
    }
  }
}
