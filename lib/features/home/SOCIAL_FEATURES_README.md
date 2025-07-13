# Social Features Implementation

This implementation adds commenting and like functionality to the Assistrend Flutter application, integrating with the existing Django backend social service.

## Features Implemented

### 1. Like System
- **Like/Unlike Posts**: Users can like and unlike posts
- **Optimistic Updates**: UI updates immediately, with rollback on API failure
- **Like Count Display**: Shows real-time like counts
- **Visual Feedback**: Like button changes color when active

### 2. Comment System
- **Add Comments**: Users can add comments to posts
- **View Comments**: Comments displayed in a modal bottom sheet
- **Real-time Updates**: Comments refresh after adding new ones
- **User-friendly UI**: Clean comment tiles with timestamps

### 3. API Integration
- **Social Service**: Dedicated service for social interactions
- **Error Handling**: Comprehensive error handling with user feedback
- **Authentication**: Proper user authentication integration

## Files Created/Modified

### Models
- `lib/features/home/models/post_model.dart` - Updated with like/comment fields
- `lib/features/home/models/comment_model.dart` - New comment model

### Services
- `lib/features/home/services/social_service.dart` - Social API service
- `lib/core/network/api_service.dart` - Updated posts API with user context

### Providers
- `lib/features/home/providers/posts_provider.dart` - Updated with like functionality
- `lib/features/home/providers/comments_provider.dart` - New comments provider

### UI Components
- `lib/features/home/widgets/post_card.dart` - New modern post card widget
- `lib/features/home/widgets/comment_tile.dart` - Comment display widget
- `lib/features/home/widgets/comments_bottom_sheet.dart` - Comments modal
- `lib/features/home/presentation/postbottombar.dart` - Updated with functionality

### Test Page
- `lib/features/home/presentation/posts_test_page.dart` - Test page for features

## Backend Integration

The implementation integrates with the existing Django backend endpoints:

### Like Endpoints
- `GET /api/social-service/features/addLike/?postId=<id>&userId=<id>` - Add like
- `POST /api/social-service/features/removeLike/` - Remove like

### Comment Endpoints
- `POST /api/social-service/features/addComment` - Add comment
- `GET /api/social-service/features/getComment?postId=<id>` - Get comments

### Post Feed
- `GET /api/social-service/features/getPostUserFeed?userId=<id>` - Get posts with like status

## Usage

### Using the New Post Card Widget
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/post_card.dart';
import '../providers/posts_provider.dart';

class MyPostsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsState = ref.watch(postsProvider);
    
    return ListView.builder(
      itemCount: postsState.posts.length,
      itemBuilder: (context, index) {
        return PostCard(post: postsState.posts[index]);
      },
    );
  }
}
```

### Using the Comments System
```dart
// Comments are automatically handled by the PostCard widget
// Or you can show comments manually:
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => CommentsBottomSheet(
    postId: postId,
    postUsername: username,
  ),
);
```

### Managing Likes
```dart
// Like/unlike is handled automatically by the PostCard widget
// Or you can manage likes manually:
ref.read(postsProvider.notifier).toggleLike(postId);
```

## State Management

The implementation uses Riverpod for state management:

- **PostsProvider**: Manages posts and like operations
- **CommentsProvider**: Manages comments for individual posts
- **Optimistic Updates**: UI updates immediately for better UX

## Error Handling

- Network errors are caught and displayed to users
- Failed operations show error messages
- Retry functionality for failed operations
- Graceful degradation when services are unavailable

## Testing

Use the `PostsTestPage` to test the implementation:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PostsTestPage(),
  ),
);
```

## Future Enhancements

1. **User Profiles**: Add user profile pictures and names
2. **Comment Likes**: Allow liking individual comments
3. **Nested Comments**: Support for comment replies
4. **Real-time Updates**: WebSocket integration for real-time updates
5. **Share Functionality**: Complete share feature implementation
6. **Bookmark System**: Save posts for later viewing
7. **Push Notifications**: Notify users of likes and comments

## Dependencies

Make sure these packages are in your `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  http: ^1.1.0
  # ... other dependencies
```

## Notes

- The implementation is designed to work with the existing app architecture
- Comments currently use placeholder usernames - enhance by fetching user details
- The UI follows the app's existing design patterns
- All new features are fully integrated with the authentication system
