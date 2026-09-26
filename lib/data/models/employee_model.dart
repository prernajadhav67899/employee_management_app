/// Employee model, matching the fields returned by
/// GET /api/v1/employee (verified against the live mockapi.io response).
/// Note: the API returns both `email` and `emailId` — `email` is used
/// as the primary field per the assignment spec; `emailId` is kept
/// only in case a screen needs to display it.
class Employee {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String country;
  final String state;
  final String district;
  final String avatar;
  final DateTime? createdAt;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.country,
    required this.state,
    required this.district,
    this.avatar = '',
    this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: (json['email'] ?? json['emailId'] ?? '').toString(),
      mobile: json['mobile']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  /// Body for POST/PUT calls. `id` and `createdAt` are omitted since
  /// mockapi.io assigns/manages those itself.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'country': country,
      'state': state,
      'district': district,
      'avatar': avatar,
    };
  }

  Employee copyWith({
    String? name,
    String? email,
    String? mobile,
    String? country,
    String? state,
    String? district,
    String? avatar,
  }) {
    return Employee(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
    );
  }
}