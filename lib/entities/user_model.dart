class UserModel {
  final String? email;
  final String? imageUrl;
  final String? name;
  final String? provider;
  final String? uid;

  UserModel({
    this.email,
    this.imageUrl,
    this.name,
    this.provider,
    this.uid,
  });

  UserModel copyWith({
    String? email,
    String? imageUrl,
    String? name,
    String? provider,
    String? uid,
  }) {
    return UserModel(
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      uid: uid ?? this.uid,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      imageUrl: json['image_url'] ?? '',
      name: json['name'] ?? '',
      provider: json['provider'] ?? '',
      uid: json['uid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'image_url': imageUrl,
      'name': name,
      'provider': provider,
      'uid': uid,
    };
  }
}
