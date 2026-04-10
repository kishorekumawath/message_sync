import '../../domain/entities/message.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/api_service.dart';
import '../datasources/ws_service.dart';

class MessageRepositoryImpl implements MessageRepository {
  MessageRepositoryImpl({
    required ApiService apiService,
    required WsService wsService,
  })  : _api = apiService,
        _ws = wsService;

  final ApiService _api;
  final WsService _ws;

  @override
  Future<void> reset() => _api.reset();

  @override
  Future<List<Message>> fetchMessages() => _api.fetchMessages();

  @override
  Stream<Message> sendAndReceive(int count, {void Function(String)? onSend}) =>
      _ws.sendAndReceive(count, onSend: onSend);
}
