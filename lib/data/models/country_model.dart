class Country {
  final String id;
  final String name;
  final String flag;

  const Country({
    required this.id,
    required this.name,
    this.flag = '',
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id']?.toString() ?? '',
      name: json['country']?.toString() ?? '',
      flag: json['flag']?.toString() ?? '',
    );
  }
}