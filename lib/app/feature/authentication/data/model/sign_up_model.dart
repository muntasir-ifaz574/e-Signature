import '../../domain/entity/sign_up_entity.dart';

class SignUpModel extends SignUpEntity {
  const SignUpModel({required super.message});

  factory SignUpModel.fromJson(Map<String, dynamic> json) {
    return SignUpModel(message: json['message']);
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }

  SignUpEntity toEntity() {
    return SignUpEntity(message: message);
  }
}
