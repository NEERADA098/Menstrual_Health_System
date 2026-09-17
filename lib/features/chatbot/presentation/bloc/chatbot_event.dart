import 'package:equatable/equatable.dart';

abstract class ChatbotEvent extends Equatable {
  const ChatbotEvent();
  @override
  List<Object?> get props => [];
}

class ChatMessageSent extends ChatbotEvent {
  final String question;
  final String userId;

  const ChatMessageSent({required this.question, required this.userId});

  @override
  List<Object?> get props => [question, userId];
}
