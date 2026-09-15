class Employee {
  String id;
  String name;
  String role;
  String phone;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'phone': phone,
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      phone: json['phone'],
    );
  }
}
