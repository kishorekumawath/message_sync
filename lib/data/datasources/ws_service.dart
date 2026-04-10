import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/config.dart';
import '../../domain/entities/message.dart';
import '../models/message_model.dart';

class WsService {
  /// Opens a WebSocket, sends [count] messages ("ping 1".."ping N"),
  /// emits server responses live as they arrive, waits 2 s for late arrivals,
  /// then closes the connection and the stream.
  Stream<Message> sendAndReceive(int count, {void Function(String)? onSend}) {
    final controller = StreamController<Message>();
    _run(count, controller, onSend).catchError((Object e) {
      if (!controller.isClosed) {
        controller.addError(e);
        controller.close();
      }
    });
    return controller.stream;
  }

  Future<void> _run(
    int count,
    StreamController<Message> controller,
    void Function(String)? onSend,
  ) async {
    final channel = WebSocketChannel.connect(Uri.parse(kWsUrl));
    await channel.ready;

    final sub = channel.stream.listen((raw) {
      try {
        final msg = MessageModel.fromJson(
          jsonDecode(raw as String) as Map<String, dynamic>,
          source: MessageSource.ws,
        );
        if (!controller.isClosed) controller.add(msg);
      } catch (_) {
        // ignore unparseable frames
      }
    });

    for (int i = 1; i <= count; i++) {
      final text = 'ping $i';
      channel.sink.add(text);
      onSend?.call('[WS] Sending: $text');
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    await Future<void>.delayed(const Duration(seconds: 2));
    await sub.cancel();
    await channel.sink.close();
    if (!controller.isClosed) await controller.close();
  }
}
