class Workspace {
  final int? id;
  final String name;
  final bool isDefault; // seeder ile oluşturulan "Varsayılan Çalışma Alanı"

  const Workspace({
    this.id,
    required this.name,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isDefault': isDefault ? 1 : 0,
    };
  }

  factory Workspace.fromMap(Map<String, dynamic> map) {
    return Workspace(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      isDefault: (map['isDefault'] as int? ?? 0) == 1,
    );
  }
}
