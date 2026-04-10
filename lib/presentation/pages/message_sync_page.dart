import 'package:flutter/material.dart';
import '../viewmodel/message_sync_viewmodel.dart';
import '../widgets/log_panel.dart';
import '../widgets/message_list_panel.dart';

class MessageSyncPage extends StatelessWidget {
  const MessageSyncPage({super.key, required this.viewModel});
  final MessageSyncViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: const Color(0xFFE8E8E8)),
            ),
            title: const Text(
              'MessageSync',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton(
                  onPressed: viewModel.isRunning ? null : viewModel.runTest,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    disabledForegroundColor: Colors.grey,
                  ),
                  child: viewModel.isRunning
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Running…'),
                          ],
                        )
                      : const Text('Start Test'),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              if (viewModel.isRunning)
                const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: Color(0xFFF0F0F0),
                  color: Colors.black87,
                ),
              _StatusText(status: viewModel.status),
              const Divider(height: 1, color: Color(0xFFE8E8E8)),
              Expanded(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    if (constraints.maxWidth > 600) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(
                            flex: 2,
                            child: MessageListPanel(
                              messages: viewModel.messages,
                              isRunning: viewModel.isRunning,
                            ),
                          ),
                          const VerticalDivider(
                            width: 1,
                            color: Color(0xFFE8E8E8),
                          ),
                          Flexible(
                            flex: 3,
                            child: LogPanel(logs: viewModel.logs),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        SizedBox(
                          height: constraints.maxHeight * 0.4,
                          child: MessageListPanel(
                            messages: viewModel.messages,
                            isRunning: viewModel.isRunning,
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE8E8E8)),
                        Expanded(child: LogPanel(logs: viewModel.logs)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          status,
          style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
        ),
      ),
    );
  }
}
