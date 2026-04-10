import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.counter,
    required super.echoMessage,
    required super.ts,
    super.source,
  });

  factory MessageModel.fromJson(
    Map<String, dynamic> json, {
    MessageSource source = MessageSource.api,
  }) {
    return MessageModel(
      counter: json['counter'] as int,
      echoMessage: json['echo_message'] as String,
      ts: json['ts'] as int,
      source: source,
    );
  }
}
