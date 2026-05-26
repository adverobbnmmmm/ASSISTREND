class ProfileSetupModel {
  final String userName;
  final String? emoji;
  final String? about;
  final String? location;
  final DateTime? dob;
  final String? gender;
  final String? profileImageUrl;
  final String? audioUrl;
  final List<String> interests;

  ProfileSetupModel({
    required this.userName,
    this.emoji,
    this.about,
    this.location,
    this.dob,
    this.gender,
    this.profileImageUrl,
    this.audioUrl,
    this.interests = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'display_name': userName,
      'emoji': emoji,
      'bio': about,
      'location': location,
      'dob': dob?.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'gender': gender,
      'profile_picture_url': profileImageUrl,
      'audio_intro_url': audioUrl,
      'interests': interests,
    };
  }

  factory ProfileSetupModel.fromJson(Map<String, dynamic> json) {
    return ProfileSetupModel(
      userName: json['userName'] ?? '',
      emoji: json['emoji'],
      about: json['about'],
      location: json['location'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      gender: json['gender'],
      profileImageUrl: json['profileImageUrl'],
      audioUrl: json['audioUrl'],
      interests: List<String>.from(json['interests'] ?? []),
    );
  }
}

class Interest {
  final int id;
  final String interestName;

  Interest({
    required this.id,
    required this.interestName,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'],
      interestName: json['interestName'],
    );
  }
}

class ProfileSetupState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<Interest> interests;

  ProfileSetupState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.interests = const [],
  });

  ProfileSetupState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<Interest>? interests,
  }) {
    return ProfileSetupState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      interests: interests ?? this.interests,
    );
  }
}
