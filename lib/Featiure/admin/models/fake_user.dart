class FakeUser {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final bool status;
  final String imgUrl;

  FakeUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.status,
    required this.imgUrl,
  });

  factory FakeUser.fromJson(Map<String, dynamic> json) {
    return FakeUser(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      age: json['age'] ?? 0,
      status: json['status'] ?? false,
      imgUrl: json['imgUrl'] ?? '',
    );
  }
}
