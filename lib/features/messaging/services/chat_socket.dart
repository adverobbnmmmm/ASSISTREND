import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:assistrend/config/app_config.dart';
import '../models/chat_models.dart';

/// Thin wrapper around a single chat WebSocket connection.
///
/// Connect to ws://host/ws/chat/<conversationId>/?token=<jwt>, listen for
/// incoming [ChatMessage]s, and send text frames. The backend authenticates
/// the connection from the JWT and derives the sender from it.
class ChatSocket {
  WebSocketChannel? _channel;

  void connect(int conversationId, String token) {
    final url =
        '${AppConfig.wsBaseUrl}/ws/chat/$conversationId/?token=$token';
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  /// Stream of incoming messages decoded into [ChatMessage].
  Stream<ChatMessage> get messages {
    final channel = _channel;
    if (channel == null) {
      return const Stream.empty();
    }
    return channel.stream.map((event) {
      final data = jsonDecode(event as String) as Map<String, dynamic>;
      return ChatMessage.fromJson(data);
    });
  }

  void send(String text) {
    _channel?.sink.add(jsonEncode({'text': text}));
  }

  Future<void> dispose() async {
    await _channel?.sink.close();
    _channel = null;
  }
}
