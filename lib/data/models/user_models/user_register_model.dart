class UserRegisterModel {
  String? name;
  String? surname;
  String? nickname;
  String? phoneNumber;
  String? email;
  String? password;

  UserRegisterModel({
    this.name,
    this.surname,
    this.nickname,
    this.phoneNumber,
    this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'nickname': nickname,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
    };
  }

  factory UserRegisterModel.fromJson(Map<String, dynamic> json) {
    return UserRegisterModel(
      name: json['name'],
      surname: json['surname'],
      nickname: json['nickname'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      password: json['password'],
    );
  }
}
