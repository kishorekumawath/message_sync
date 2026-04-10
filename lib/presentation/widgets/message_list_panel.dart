import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';

class MessageListPanel extends StatelessWidget {
  const MessageListPanel({
    super.key,
    required this.messages,
    required this.isRunning,
  });

  final List<Message> messages;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Text(
                'Messages',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                  letterSpacing: 0.5,
                ),
              ),
              if (messages.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '${messages.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    isRunning ? 'Waiting…' : 'No messages',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFCCCCCC),
                    ),
                  ),
                )
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: messages.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 4),
                  itemBuilder: (ctx, i) => _MessageRow(message: messages[i]),
                ),
        ),
      ],
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    final isWs = message.source == MessageSource.ws;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          // Counter
          SizedBox(
            width: 28,
            child: Text(
              '${message.counter}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          // Message text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.echoMessage,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                ),
                Text(
                  'ts: ${message.ts}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
              ],
            ),
          ),
          // Source tag
          Text(
            isWs ? 'WS' : 'API',
            style: TextStyle(
              fontSize: 10,
              color: isWs ? const Color(0xFF555555) : const Color(0xFFAAAAAA),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
