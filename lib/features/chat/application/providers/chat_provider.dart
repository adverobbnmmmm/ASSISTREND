import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';

/// A provider that asynchronously loads and exposes friends and groups.
final chatProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ChatService.fetchAvailableChats();
});
