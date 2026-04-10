import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'data/datasources/api_service.dart';
import 'data/datasources/ws_service.dart';
import 'data/repositories/message_repository_impl.dart';
import 'presentation/pages/message_sync_page.dart';
import 'presentation/viewmodel/message_sync_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final repository = MessageRepositoryImpl(
    apiService: ApiService(),
    wsService: WsService(),
  );
  final viewModel = MessageSyncViewModel(repository: repository);

  runApp(MessageSyncApp(viewModel: viewModel));
}

class MessageSyncApp extends StatelessWidget {
  const MessageSyncApp({super.key, required this.viewModel});
  final MessageSyncViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MessageSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          outline: Color(0xFF777777),
          outlineVariant: Color(0xFFCCCCCC),
          surfaceContainerHighest: Color(0xFFEEEEEE),
          surfaceContainerLow: Color(0xFFF7F7F7),
          onSurfaceVariant: Color(0xFF333333),
          tertiary: Colors.black,
          onTertiary: Colors.white,
        ),
        dividerColor: const Color(0xFFDDDDDD),
        cardTheme: const CardThemeData(color: Colors.white),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MessageSyncPage(viewModel: viewModel),
    );
  }
}
