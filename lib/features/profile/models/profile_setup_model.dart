class ProfileSetupModel {
  final String userName;
  final String? emoji;
  final String? about;
  final String? location;
  final DateTime? dob;
  final String? gender;
  final String? profileImageUrl;
  final String? audioUrl;
  final String? highlightQuestion;
  final List<int> interests;

  ProfileSetupModel({
    required this.userName,
    this.emoji,
    this.about,
    this.location,
    this.dob,
    this.gender,
    this.profileImageUrl,
    this.audioUrl,
    this.highlightQuestion,
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
      'highlight_question': highlightQuestion,
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
      highlightQuestion: json['highlight_question'] ?? json['highlightQuestion'],
      interests: List<int>.from(json['interests'] ?? []),
    );
  }
}

class InterestSubcategory {
  final int id;
  final String name;

  InterestSubcategory({
    required this.id,
    required this.name,
  });

  factory InterestSubcategory.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return InterestSubcategory(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0,
      name: (json['name'] ?? json['interestName'] ?? '').toString(),
    );
  }
}

class InterestCategory {
  final int id;
  final String name;
  final List<InterestSubcategory> subcategories;

  InterestCategory({
    required this.id,
    required this.name,
    required this.subcategories,
  });

  factory InterestCategory.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawSubcategories =
        (json['subcategories'] ?? json['children'] ?? []) as List<dynamic>;

    return InterestCategory(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0,
      name: (json['name'] ?? json['interestName'] ?? '').toString(),
      subcategories: rawSubcategories
          .map((sub) => InterestSubcategory.fromJson(sub as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProfileSetupState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<InterestCategory> interests;

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
    List<InterestCategory>? interests,
  }) {
    return ProfileSetupState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      interests: interests ?? this.interests,
    );
  }
}
