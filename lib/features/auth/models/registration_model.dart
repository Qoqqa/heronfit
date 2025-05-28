import 'package:flutter/foundation.dart';

@immutable
class RegistrationModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String gender;
  final String birthday;
  final String weight;
  final String height;
  final String goal;
  final String userRole;
  final String roleStatus;
  final String? verificationDocumentUrl;

  const RegistrationModel({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.gender = '',
    this.birthday = '',
    this.weight = '',
    this.height = '',
    this.goal = '',
    this.userRole = 'PUBLIC',
    this.roleStatus = 'VERIFIED',
    this.verificationDocumentUrl,
  });

  RegistrationModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? gender,
    String? birthday,
    String? weight,
    String? height,
    String? goal,
    String? userRole,
    String? roleStatus,
    String? verificationDocumentUrl,
    bool setVerificationDocumentUrlToNull = false,
  }) {
    return RegistrationModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      userRole: userRole ?? this.userRole,
      roleStatus: roleStatus ?? this.roleStatus,
      verificationDocumentUrl: setVerificationDocumentUrlToNull 
          ? null 
          : verificationDocumentUrl ?? this.verificationDocumentUrl,
    );
  }
}
