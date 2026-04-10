class Message {
  final int counter;
  final String echoMessage;
  final int ts;
  final MessageSource source;

  const Message({
    required this.counter,
    required this.echoMessage,
    required this.ts,
    this.source = MessageSource.api,
  });
}

enum MessageSource { ws, api }
