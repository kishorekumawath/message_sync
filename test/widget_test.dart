import 'package:flutter_test/flutter_test.dart';
import 'package:message_sync/main.dart';
import 'package:message_sync/data/datasources/api_service.dart';
import 'package:message_sync/data/datasources/ws_service.dart';
import 'package:message_sync/data/repositories/message_repository_impl.dart';
import 'package:message_sync/presentation/viewmodel/message_sync_viewmodel.dart';

void main() {
  testWidgets('MessageSync smoke test', (WidgetTester tester) async {
    final viewModel = MessageSyncViewModel(
      repository: MessageRepositoryImpl(
        apiService: ApiService(),
        wsService: WsService(),
      ),
    );
    await tester.pumpWidget(MessageSyncApp(viewModel: viewModel));
    expect(find.text('MessageSync'), findsOneWidget);
  });
}
