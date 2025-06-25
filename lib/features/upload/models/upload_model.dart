import 'dart:io';

enum MediaType {
  image,
  video,
  audio
}

/// Model to hold media information for upload
class UploadMedia {
  final File? file;   // File will be null on platforms like Windows
  final String? path; // Path or name representation of the media
  final MediaType type;
  final String? thumbnail;
  final int? durationMs;  // Duration in milliseconds for videos and audio
  
  const UploadMedia({
    this.file, // Made optional to support Windows/desktop
    this.path, // Made optional for flexibility
    required this.type,
    this.thumbnail,
    this.durationMs,
  });

  bool get hasFile => file != null;
  bool get hasMockPath => path != null;
  bool get isVideoPlayable => type == MediaType.video && file != null && file!.existsSync();
}

/// Model to represent a complete post for upload
class UploadPost {
  final UploadMedia? media;
  final String caption;
  final DateTime createdAt;
  
  const UploadPost({
    this.media,
    required this.caption,
    required this.createdAt,
  });

  bool get hasMedia => media != null;
  bool get isValid => caption.isNotEmpty || hasMedia;
  
  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };

    if (hasMedia) {
      result['media_path'] = media!.path;
      result['media_type'] = media!.type.toString().split('.').last;
    }
    
    return result;
  }
}
