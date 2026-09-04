import 'package:equatable/equatable.dart';

abstract class AshaState extends Equatable {
  const AshaState();
  @override
  List<Object?> get props => [];
}

class AshaInitial extends AshaState {
  const AshaInitial();
}

class AshaLoading extends AshaState {
  const AshaLoading();
}

class AshaLoaded extends AshaState {
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> flaggedUsers;

  const AshaLoaded({
    required this.summary,
    required this.flaggedUsers,
  });

  @override
  List<Object?> get props => [summary, flaggedUsers];
}

class AshaError extends AshaState {
  final String message;
  const AshaError(this.message);
  @override
  List<Object?> get props => [message];
}
