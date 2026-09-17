import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/chatbot_remote_datasource.dart';
import 'chatbot_event.dart';
import 'chatbot_state.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final ChatbotRemoteDataSource _dataSource;

  ChatbotBloc({ChatbotRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? ChatbotRemoteDataSource(),
        super(const ChatbotInitial()) {
    on<ChatMessageSent>(_onMessageSent);
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatbotState> emit,
  ) async {
    final userMessage = ChatMessage(
      text: event.question,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];
    emit(ChatbotLoading(messages: updatedMessages));

    try {
      final answer = await _dataSource.sendMessage(
        question: event.question,
        userId: event.userId,
      );

      final botMessage = ChatMessage(
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
      );

      emit(ChatbotLoaded(messages: [...updatedMessages, botMessage]));
    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Sorry, I could not connect to the server. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      emit(ChatbotLoaded(messages: [...updatedMessages, errorMessage]));
    }
  }
}
