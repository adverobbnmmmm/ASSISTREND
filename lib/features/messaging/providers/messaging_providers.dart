import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/storage.dart';
import '../models/chat_models.dart';
import '../services/messaging_api.dart';

/// Loads the current user's conversations. Invalidate to refresh.
final conversationsProvider =
    FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final token = await Storage.getToken();
  if (token == null) return [];
  return MessagingApi.getConversations();
});
