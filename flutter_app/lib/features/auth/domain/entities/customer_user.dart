class CustomerUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String token;

  const CustomerUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.role = 'customer',
    required this.token,
  });

  factory CustomerUser.fromJson(Map<String, dynamic> json, {String? token}) {
    return CustomerUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'អតិថិជន',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      role: json['role']?.toString() ?? 'customer',
      token: token ?? json['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'token': token,
    };
  }

  CustomerUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? role,
    String? token,
  }) {
    return CustomerUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
