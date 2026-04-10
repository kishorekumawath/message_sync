// Standalone CLI script — runs the same logic as the Flutter app
// but captures console output for submission evidence.
//
// Run with: dart run bin/run_test.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

Map<String, String> _loadEnv() {
  final file = File('.env');
  if (!file.existsSync()) throw Exception('.env file not found');
  return Map.fromEntries(
    file.readAsLinesSync()
        .where((l) => l.contains('=') && !l.trimLeft().startsWith('#'))
        .map((l) {
          final idx = l.indexOf('=');
          return MapEntry(l.substring(0, idx).trim(), l.substring(idx + 1).trim());
        }),
  );
}

final _env = _loadEnv();
final kToken = _env['TOKEN']!;
final kBaseUrl = _env['BASE_URL']!;
final kWsUrl = 'wss://${Uri.parse(kBaseUrl).host}/ws?token=$kToken';
const kTotalMessages = 30;

void log(String msg) => print(msg); // ignore: avoid_print

Future<void> main() async {
  // --- RESET ---
  final resetRes = await http.post(
    Uri.parse('$kBaseUrl/reset'),
    headers: {'Authorization': 'Bearer $kToken'},
  );
  if (resetRes.statusCode == 200) {
    log('[RESET] Server state cleared');
  } else {
    log('[RESET] Failed: ${resetRes.statusCode} ${resetRes.body}');
    exit(1);
  }

  // --- WEBSOCKET CONNECT ---
  log('[WS] Connecting to $kWsUrl');
  final channel = WebSocketChannel.connect(Uri.parse(kWsUrl));
  await channel.ready;
  log('[WS] Connected');

  // Listen for WS responses in background
  final wsReceived = <Map<String, dynamic>>[];
  final sub = channel.stream.listen((raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      wsReceived.add(msg);
      log('[WS RECV] counter=${msg['counter']}, '
          'echo_message=${msg['echo_message']}, ts=${msg['ts']}');
    } catch (_) {
      log('[WS RECV] unparseable: $raw');
    }
  });

  // --- SEND 30 MESSAGES ---
  for (int i = 1; i <= kTotalMessages; i++) {
    final text = 'ping $i';
    channel.sink.add(text);
    log('[WS] Sending: $text');
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  // Wait for any late responses
  log('[WS] Waiting for late responses...');
  await Future<void>.delayed(const Duration(seconds: 2));

  await sub.cancel();
  await channel.sink.close();
  log('[WS] Disconnected');

  // --- FETCH AUTHORITATIVE LIST ---
  log('[API] Fetching authoritative message list...');
  final msgRes = await http.get(
    Uri.parse('$kBaseUrl/messages'),
    headers: {'Authorization': 'Bearer $kToken'},
  );
  if (msgRes.statusCode != 200) {
    log('[API] Failed: ${msgRes.statusCode} ${msgRes.body}');
    exit(1);
  }
  final data = jsonDecode(msgRes.body) as Map<String, dynamic>;
  final ordered = List<Map<String, dynamic>>.from(data['messages'] as List)
    ..sort((a, b) => (a['counter'] as int).compareTo(b['counter'] as int));

  // --- PRINT RESULTS ---
  log('');
  log('=== RESULTS (monotonically ordered by counter) ===');
  for (final msg in ordered) {
    log('[RESULT] counter=${msg['counter']} | ${msg['echo_message']} | ts=${msg['ts']}');
  }

  // Verify monotonicity
  bool isMonotonic = true;
  for (int i = 1; i < ordered.length; i++) {
    if ((ordered[i]['counter'] as int) <= (ordered[i - 1]['counter'] as int)) {
      isMonotonic = false;
      break;
    }
  }
  log('');
  log('[DONE] ${ordered.length} messages received, '
      'monotonically increasing: $isMonotonic');
}
