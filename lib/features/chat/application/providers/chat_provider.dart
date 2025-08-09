// lib/features/chat/application/providers/chat_provider.dart

import 'package:assistrend/features/chat/domain/models/chat_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../../utils/chat_cache.dart';

/// A provider that asynchronously loads and exposes friends and groups.
final chatProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // 1. Try loading cached data
  final cachedData = await ChatCache.load();

  // 2. Emit cached data immediately if it exists
  if (cachedData != null) {
    Future.microtask(() => ref.state = AsyncData(cachedData));
  }

  // 3. Fetch fresh data from backend
  final freshData = await ChatService.fetchAvailableChats();

  // 4. Compare and update cache if needed
  if (cachedData == null || !mapEquals(cachedData, freshData)) {
    await ChatCache.save(
      friends: freshData['friends'] as List<Friend>,
      groups: freshData['groups'] as List<ChatGroup>,
    );

    return freshData;
  }

  // 5. Return cached data if same
  return cachedData;
});
