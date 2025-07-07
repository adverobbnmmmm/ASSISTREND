import 'package:flutter/material.dart';
import '../models/search_result_model.dart';

class SearchResultItem extends StatelessWidget {
  final SearchResultModel result;
  final VoidCallback? onTap;

  const SearchResultItem({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (result.type) {
      case 'profile':
        return ProfileResultItem(result: result, onTap: onTap);
      case 'photo':
        return MediaResultItem(result: result, onTap: onTap, isVideo: false);
      case 'video':
        return MediaResultItem(result: result, onTap: onTap, isVideo: true);
      case 'text':
      default:
        return TextResultItem(result: result, onTap: onTap);
    }
  }
}

class ProfileResultItem extends StatelessWidget {
  final SearchResultModel result;
  final VoidCallback? onTap;

  const ProfileResultItem({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: result.imageUrl != null ? NetworkImage(result.imageUrl!) : null,
        child: result.imageUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text(
        result.title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: result.subtitle != null
          ? Text(result.subtitle!, style: TextStyle(color: Colors.grey[500]))
          : null,
      onTap: onTap,
    );
  }
}

class MediaResultItem extends StatelessWidget {
  final SearchResultModel result;
  final VoidCallback? onTap;
  final bool isVideo;

  const MediaResultItem({
    super.key,
    required this.result,
    this.onTap,
    required this.isVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.imageUrl != null)
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    result.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (isVideo)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (result.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        result.subtitle!,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextResultItem extends StatelessWidget {
  final SearchResultModel result;
  final VoidCallback? onTap;

  const TextResultItem({
    super.key,
    required this.result,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (result.subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    result.subtitle!,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                _formatTimestamp(result.timestamp),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
