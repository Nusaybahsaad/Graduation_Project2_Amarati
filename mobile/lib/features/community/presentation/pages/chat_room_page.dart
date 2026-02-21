import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../data/models/chat_room_model.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';

class ChatRoomPage extends StatefulWidget {
  final ChatRoomModel room;

  const ChatRoomPage({super.key, required this.room});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchMessages();
    });
  }

  void _fetchMessages() {
    context.read<CommunityBloc>().add(FetchMessagesEvent(widget.room.id));
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<CommunityBloc>().add(SendMessageEvent(widget.room.id, text));
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // We need the current user ID to know which messages are "ours"
    final currentUserId = context.select<AuthBloc, String?>((bloc) {
      final state = bloc.state;
      if (state is AuthAuthenticated) return state.user.id;
      return null;
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.room.name,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<CommunityBloc, CommunityState>(
              listener: (context, state) {
                if (state is MessagesLoaded && state.roomId == widget.room.id) {
                  // Optional: scroll to bottom when new messages arrive
                }
              },
              builder: (context, state) {
                if (state is CommunityLoading && state is! MessagesLoaded) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                } else if (state is CommunityError) {
                  return Center(
                    child: Text(
                      'خطأ: ${state.message}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: AppColors.error,
                      ),
                    ),
                  );
                } else if (state is MessagesLoaded &&
                    state.roomId == widget.room.id) {
                  final messages = state.messages.reversed
                      .toList(); // Assuming backend returns newest first
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد رسائل بعد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textHint,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Show newest at the bottom
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUserId;
                      return _buildMessageBubble(
                        msg.content,
                        msg.createdAt,
                        isMe,
                      );
                    },
                  );
                }
                return const Center(
                  child: Text(
                    'لا توجد بيانات',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, DateTime timestamp, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(0)
                : const Radius.circular(16),
            bottomRight: isMe
                ? const Radius.circular(16)
                : const Radius.circular(0),
          ),
          boxShadow: [
            if (!isMe)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(timestamp),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                color: isMe ? Colors.white70 : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالة...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    color: AppColors.textHint,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.textPrimary,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
