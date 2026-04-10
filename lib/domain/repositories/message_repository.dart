import '../entities/message.dart';

abstract class MessageRepository {
  Future<void> reset();
  Future<List<Message>> fetchMessages();
  Stream<Message> sendAndReceive(int count, {void Function(String)? onSend});
}
