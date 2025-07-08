import 'dart:convert'; // 👈 Required for jsonEncode
import 'package:web_socket_channel/web_socket_channel.dart'; // 👈 Required for WebSocketChannel

/// Singleton WebSocket connection manager.
///
/// Use [NotificationsSocket.initialize(token)] once at app start or login,
/// then access via [NotificationsSocket.instance].
class NotificationsSocket {
  static NotificationsSocket? _instance;
  static NotificationsSocket? get instance => _instance;

  static void initialize(String jwtToken) {
    _instance = NotificationsSocket._internal(jwtToken);
  }

  late WebSocketChannel _channel;
  late Stream _broadcastStream;

  NotificationsSocket._internal(String jwtToken) {
    final uri = Uri.parse(
      'ws://10.0.2.2:8002/ws/notifications/?token=$jwtToken',
    );
    _channel = WebSocketChannel.connect(uri);

    // ✅ Convert to broadcast stream
    _broadcastStream = _channel.stream.asBroadcastStream();
  }

  Stream get stream => _broadcastStream; // ✅ Return broadcast stream

  void send(Map<String, dynamic> data) {
    final jsonData = jsonEncode(data);
    _channel.sink.add(jsonData);
  }

  void dispose() {
    _channel.sink.close();
  }
}
