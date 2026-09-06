class CustomerAccount {
  final int id;
  final String name;
  final String phone;
  final String? email;

  CustomerAccount({required this.id, required this.name, required this.phone, this.email});

  factory CustomerAccount.fromJson(Map<String, dynamic> json) {
    return CustomerAccount(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
    );
  }
}
