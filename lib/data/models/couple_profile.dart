class CoupleProfile {
  const CoupleProfile({
    required this.names,
    required this.relationshipStartDate,
    required this.birthday,
    required this.character1,
    required this.character2,
  });

  final String names;
  final DateTime relationshipStartDate;
  final DateTime? birthday;
  final String character1;
  final String character2;

  CoupleProfile copyWith({
    String? names,
    DateTime? relationshipStartDate,
    DateTime? birthday,
    String? character1,
    String? character2,
  }) => CoupleProfile(
        names: names ?? this.names,
        relationshipStartDate: relationshipStartDate ?? this.relationshipStartDate,
        birthday: birthday ?? this.birthday,
        character1: character1 ?? this.character1,
        character2: character2 ?? this.character2,
      );
}
