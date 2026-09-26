/// Country model, matching GET /api/v1/country (verified against
/// the live mockapi.io response). Used to populate the country
/// dropdown on the Add/Edit Employee form.
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