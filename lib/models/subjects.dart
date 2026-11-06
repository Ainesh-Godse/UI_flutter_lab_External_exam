class Subject {
  final String id;
  final String name;
  final int attendedClasses;
  final int totalClasses;
  final int targetPercentage; // e.g., 75 for 75%

  Subject({
    required this.id,
    required this.name,
    required this.attendedClasses,
    required this.totalClasses,
    required this.targetPercentage,
  });

  // Helper method to create a copy with updated values (useful for marking attendance)
  Subject copyWith({
    String? name,
    int? attendedClasses,
    int? totalClasses,
    int? targetPercentage,
  }) {
    return Subject(
      id: id, // ID never changes
      name: name ?? this.name,
      attendedClasses: attendedClasses ?? this.attendedClasses,
      totalClasses: totalClasses ?? this.totalClasses,
      targetPercentage: targetPercentage ?? this.targetPercentage,
    );
  }

  // Convert Object to JSON (Map) for saving
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'attendedClasses': attendedClasses,
      'totalClasses': totalClasses,
      'targetPercentage': targetPercentage,
    };
  }

  // Create Object from JSON (Map) when loading
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      attendedClasses: json['attendedClasses'] as int,
      totalClasses: json['totalClasses'] as int,
      targetPercentage: json['targetPercentage'] as int,
    );
  }
}