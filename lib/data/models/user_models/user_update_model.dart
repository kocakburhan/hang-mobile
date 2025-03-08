import 'package:flutter/foundation.dart';

enum Gender { MALE, FEMALE, OTHER }

enum UserType { INDIVIDUAL, COMPANY }

class UserUpdateModel {
  String? name;
  String? surname;
  String? nickname;
  String? phoneNumber;
  String? email;
  String? password;
  bool? isPremium;
  String? location;
  String? profilePicture;
  int? age;
  Gender? gender;
  List<String>? hobbies;
  String? biography;
  String? zodiacSign;
  String? risingSign;
  UserType? userType;

  UserUpdateModel({
    this.name,
    this.surname,
    this.nickname,
    this.phoneNumber,
    this.email,
    this.password,
    this.isPremium,
    this.location,
    this.profilePicture,
    this.age,
    this.gender,
    this.hobbies,
    this.biography,
    this.zodiacSign,
    this.risingSign,
    this.userType,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (surname != null) 'surname': surname,
      if (nickname != null) 'nickname': nickname,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (isPremium != null) 'isPremium': isPremium,
      if (location != null) 'location': location,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender?.toString().split('.').last,
      'hobbies': hobbies ?? [], // Her zaman hobi listesi gönder (boş bile olsa)
      if (biography != null) 'biography': biography,
      if (zodiacSign != null) 'zodiacSign': zodiacSign,
      if (risingSign != null) 'risingSign': risingSign,
      if (userType != null) 'userType': userType?.toString().split('.').last,
    };
  }

  factory UserUpdateModel.fromJson(Map<String, dynamic> json) {
    return UserUpdateModel(
      name: json['name'],
      surname: json['surname'],
      nickname: json['nickname'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      password: json['password'],
      isPremium: json['isPremium'],
      location: json['location'],
      profilePicture: json['profilePicture'],
      age: json['age'],
      gender:
          json['gender'] != null
              ? Gender.values.firstWhere(
                (e) => e.toString() == 'Gender.${json['gender']}',
                orElse: () => Gender.OTHER,
              )
              : null,
      hobbies:
          json['hobbies'] != null ? List<String>.from(json['hobbies']) : null,
      biography: json['biography'],
      zodiacSign: json['zodiacSign'],
      risingSign: json['risingSign'],
      userType:
          json['userType'] != null
              ? UserType.values.firstWhere(
                (e) => e.toString() == 'UserType.${json['userType']}',
                orElse: () => UserType.INDIVIDUAL,
              )
              : null,
    );
  }

  factory UserUpdateModel.fromUserData(Map<String, dynamic> userData) {
    return UserUpdateModel(
      name: userData['name'],
      surname: userData['surname'],
      nickname: userData['nickname'],
      phoneNumber: userData['phoneNumber'],
      email: userData['email'],
      isPremium: userData['isPremium'],
      location: userData['location'],
      profilePicture: userData['profilePicture'],
      age: userData['age'],
      gender:
          userData['gender'] != null
              ? Gender.values.firstWhere(
                (e) => e.toString() == 'Gender.${userData['gender']}',
                orElse: () => Gender.OTHER,
              )
              : null,
      hobbies:
          userData['hobbies'] != null
              ? List<String>.from(userData['hobbies'])
              : null,
      biography: userData['biography'],
      zodiacSign: userData['zodiacSign'],
      risingSign: userData['risingSign'],
      userType:
          userData['userType'] != null
              ? UserType.values.firstWhere(
                (e) => e.toString() == 'UserType.${userData['userType']}',
                orElse: () => UserType.INDIVIDUAL,
              )
              : null,
    );
  }
}
