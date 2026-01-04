import 'package:equatable/equatable.dart';

class SignUpEntity extends Equatable {
  const SignUpEntity({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
