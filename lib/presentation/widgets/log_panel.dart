import 'package:flutter/material.dart';

class LogPanel extends StatefulWidget {
  const LogPanel({super.key, required this.logs});
  final List<String> logs;

  @override
  State<LogPanel> createState() => _LogPanelState();
}

class _LogPanelState extends State<LogPanel> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(LogPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs.length != oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
                'Console',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555555),
                  letterSpacing: 0.5,
                ),
              ),
              if (widget.logs.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '${widget.logs.length} lines',
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
          child: Container(
            color: const Color(0xFFFAFAFA),
            child: widget.logs.isEmpty
                ? const Center(
                    child: Text(
                      'Output will appear here',
                      style: TextStyle(fontSize: 13, color: Color(0xFFCCCCCC)),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: widget.logs.length,
                    itemBuilder: (ctx, i) => _LogLine(line: widget.logs[i]),
                  ),
          ),
        ),
      ],
    );
  }
}

class _LogLine extends StatelessWidget {
  const _LogLine({required this.line});
  final String line;

  _Style _resolve() {
    if (line.startsWith('[ERROR]')) {
      return const _Style(color: Color(0xFF111111), bold: true);
    }
    if (line.startsWith('[DONE]')) {
      return const _Style(color: Color(0xFF111111), bold: true);
    }
    if (line.startsWith('===')) {
      return const _Style(color: Color(0xFF444444), bold: true);
    }
    if (line.startsWith('[RESULT]')) return const _Style(color: Color(0xFF333333));
    if (line.startsWith('[WS RECV]')) return const _Style(color: Color(0xFF555555));
    if (line.startsWith('[WS]')) return const _Style(color: Color(0xFF777777));
    if (line.startsWith('[API]')) return const _Style(color: Color(0xFF777777));
    if (line.startsWith('[RESET]')) return const _Style(color: Color(0xFF999999));
    return const _Style(color: Color(0xFFAAAAAA));
  }

  @override
  Widget build(BuildContext context) {
    if (line.isEmpty) return const SizedBox(height: 6);
    final s = _resolve();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        line,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11.5,
          color: s.color,
          fontWeight: s.bold ? FontWeight.bold : FontWeight.normal,
          height: 1.6,
        ),
      ),
    );
  }
}

class _Style {
  const _Style({required this.color, this.bold = false});
  final Color color;
  final bool bold;
}
