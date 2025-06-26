import 'dart:io';
import 'dart:typed_data';

enum MediaType {
  image,
  video,
  audio
}

/// Model to hold media information for upload - Instagram-like
class UploadMedia {
  final File? file;             // File will be null on platforms like Windows
  final String? path;           // Path or name representation of the media
  final MediaType type;
  final String? thumbnail;
  final int? durationMs;        // Duration in milliseconds for videos and audio
  final String? originalFilter; // Original filter applied to the media
  
  const UploadMedia({
    this.file, // Made optional to support Windows/desktop
    this.path, // Made optional for flexibility
    required this.type,
    this.thumbnail,
    this.durationMs,
    this.originalFilter,
  });

  bool get hasFile => file != null;
  bool get hasMockPath => path != null;
  bool get isVideoPlayable => type == MediaType.video && file != null && file!.existsSync();
}

/// Model to represent recent media from the gallery
class RecentMedia {
  final String path;
  final MediaType type;
  final File? file;
  final DateTime timestamp;
  final String? thumbnail;
  final bool isMock;
  final Uint8List? thumbnailData;  // Raw thumbnail data
  final int? duration;  // Duration in milliseconds for video/audio

  const RecentMedia({
    required this.path,
    required this.type,
    this.file,
    required this.timestamp,
    this.thumbnail,
    this.isMock = false,
    this.thumbnailData,
    this.duration,
  });

  bool get isImage => type == MediaType.image;
  bool get isVideo => type == MediaType.video;
  bool get hasFile => file != null && !isMock;
  bool get hasThumbnail => thumbnail != null || thumbnailData != null;
  
  // Convert to UploadMedia for selection
  UploadMedia toUploadMedia() {
    return UploadMedia(
      file: file,
      path: path,
      type: type,
      thumbnail: thumbnail,
      durationMs: duration,
    );
  }
}

/// Model to represent a complete Instagram-like post for upload
class UploadPost {
  final UploadMedia? media;
  final String caption;
  final DateTime createdAt;
  final String? location;
  final List<String>? tags;
  final String? filter;
  final Map<String, double>? adjustments;
  final Map<String, String>? metadata;
  final String? category;
  
  const UploadPost({
    this.media,
    required this.caption,
    required this.createdAt,
    this.location,
    this.tags,
    this.filter,
    this.adjustments,
    this.metadata,
    this.category,
  });

  bool get hasMedia => media != null;
  bool get isValid => caption.isNotEmpty || hasMedia;
  bool get hasLocation => location != null && location!.isNotEmpty;
  bool get hasTags => tags != null && tags!.isNotEmpty;
  
  // Convert to JSON for API upload
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };

    if (hasMedia) {
      result['media_path'] = media!.path;
      result['media_type'] = media!.type.toString().split('.').last;
      if (media!.durationMs != null) {
        result['media_duration'] = media!.durationMs;
      }
    }
    
    if (hasLocation) {
      result['location'] = location;
    }
    
    if (hasTags) {
      result['tags'] = tags;
    }
    
    if (filter != null) {
      result['filter'] = filter;
    }
    
    if (adjustments != null) {
      result['adjustments'] = adjustments;
    }
    
    if (metadata != null) {
      result['metadata'] = metadata;
    }

    if (category != null) {
      result['category'] = category;
    }
    
    return result;
  }
}
