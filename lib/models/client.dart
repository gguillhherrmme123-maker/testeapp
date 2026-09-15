class Client {
  String id;
  String name;
  String notes;

  Client({
    required this.id,
    required this.name,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'notes': notes,
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      notes: json['notes'],
    );
  }
}
