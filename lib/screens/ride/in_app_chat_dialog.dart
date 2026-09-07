import 'package:flutter/material.dart';

class InAppChatDialog extends StatefulWidget {
  final String driverName;
  final String vehiclePlate;

  const InAppChatDialog({
    super.key,
    required this.driverName,
    required this.vehiclePlate,
  });

  @override
  State<InAppChatDialog> createState() => _InAppChatDialogState();
}

class _InAppChatDialogState extends State<InAppChatDialog> {
  final List<Map<String, dynamic>> _messages = [
    {"sender": "driver", "text": "Namaste! I am on the way in my Tata Nexon EV.", "time": "Just now"},
    {"sender": "passenger", "text": "I am standing near Platform 1 main gate.", "time": "Just now"},
  ];
  final _textController = TextEditingController();

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        "sender": "passenger",
        "text": _textController.text.trim(),
        "time": "Just now",
      });
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 16, backgroundColor: Color(0xFF00E676), child: Icon(Icons.person, color: Colors.black, size: 18)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.driverName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text(widget.vehiclePlate, style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 10)),
                  ],
                ),
              ],
            ),
            IconButton(icon: const Icon(Icons.close, color: Colors.white60, size: 18), onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
      content: SizedBox(
        width: 340,
        height: 300,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  final isMe = m['sender'] == 'passenger';
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFF00E676) : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m['text'], style: TextStyle(color: isMe ? Colors.black : Colors.white, fontSize: 12)),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF00E676), size: 20),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}