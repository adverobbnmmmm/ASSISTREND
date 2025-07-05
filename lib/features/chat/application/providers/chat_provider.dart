import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../../domain/models/chat_models.dart';

/// A provider that loads and exposes friends and groups for the chat home.
final chatProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ChatService.fetchAvailableChats();
});
