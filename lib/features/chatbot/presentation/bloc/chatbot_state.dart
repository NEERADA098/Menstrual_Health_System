import 'package:equatable/equatable.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

abstract class ChatbotState extends Equatable {
  final List<ChatMessage> messages;
  const ChatbotState({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatbotInitial extends ChatbotState {
  const ChatbotInitial() : super(messages: const []);
}

class ChatbotLoading extends ChatbotState {
  const ChatbotLoading({required super.messages});
}

class ChatbotLoaded extends ChatbotState {
  const ChatbotLoaded({required super.messages});
}

class ChatbotError extends ChatbotState {
  final String error;
  const ChatbotError({required super.messages, required this.error});

  @override
  List<Object?> get props => [messages, error];
}
