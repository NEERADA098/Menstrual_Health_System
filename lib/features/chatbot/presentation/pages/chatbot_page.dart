import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/voice/voice_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/chatbot_bloc.dart';
import '../bloc/chatbot_event.dart';
import '../bloc/chatbot_state.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;

  String get _currentLocaleId {
    final locale = context.locale;
    if (locale.languageCode == 'ml') return 'ml_IN';
    if (locale.languageCode == 'hi') return 'hi_IN';
    return 'en_US';
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<ChatbotBloc>().add(
          ChatMessageSent(question: text, userId: authState.user.uid),
        );
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  Future<void> _toggleVoice() async {
    if (_isListening) {
      await voiceService.stopListening();
      setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);

    await voiceService.startListening(
      localeId: _currentLocaleId,
      onResult: (text) {
        setState(() {
          _controller.text = text;
          _isListening = false;
        });
      },
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    if (_isListening) voiceService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('health_assistant'.tr()),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 14),
                const SizedBox(width: 4),
                Text(
                  'clinically_verified'.tr(),
                  style: const TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatbotBloc, ChatbotState>(
              builder: (context, state) {
                if (state.messages.isEmpty) {
                  return _WelcomeView();
                }
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length +
                      (state is ChatbotLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length &&
                        state is ChatbotLoading) {
                      return const _TypingIndicator();
                    }
                    return _MessageBubble(message: state.messages[index]);
                  },
                );
              },
            ),
          ),
          if (_isListening)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: AppColors.primaryLight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Listening...',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          _InputBar(
            controller: _controller,
            onSend: _sendMessage,
            onVoice: _toggleVoice,
            isListening: _isListening,
          ),
        ],
      ),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  final suggestions = const [
    'Are my cramps normal?',
    'What is a normal cycle length?',
    'What are signs of PCOS?',
    'When should I see a doctor?',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text('health_assistant'.tr(),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about your menstrual health. '
            'My answers are based on verified medical knowledge.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.grey600),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'suggested_questions'.tr(),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.grey700),
            ),
          ),
          const SizedBox(height: 12),
          ...suggestions.map((q) => _SuggestionChip(question: q)),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String question;
  const _SuggestionChip({required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          final authState = context.read<AuthBloc>().state;
          if (authState is! AuthAuthenticated) return;
          context.read<ChatbotBloc>().add(
                ChatMessageSent(
                    question: question, userId: authState.user.uid),
              );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.chat_bubble_outline,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(question)),
              const Icon(Icons.arrow_forward_ios,
                  size: 12, color: AppColors.grey400),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          border: isUser ? null : Border.all(color: AppColors.grey200),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? AppColors.white : AppColors.grey900,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.grey200,
              ),
            ),
            SizedBox(width: 8),
            Text('Thinking...',
                style: TextStyle(color: AppColors.grey600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final bool isListening;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onVoice,
    required this.isListening,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onVoice,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isListening
                    ? AppColors.primary
                    : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isListening ? Icons.stop : Icons.mic,
                color: isListening ? AppColors.white : AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'ask_health_question'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: onSend,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.send, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
