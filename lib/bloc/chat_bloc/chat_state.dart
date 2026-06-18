part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatFailure extends ChatState {
  final String message;
  ChatFailure(this.message);
}

class ChatReady extends ChatState {
  final UserModel currentUser;
  final List<MessageModel> messages;
  final bool isUploading;

  ChatReady({
    required this.currentUser,
    required this.messages,
    this.isUploading = false,
  });

  ChatReady copyWith({List<MessageModel>? messages, bool? isUploading}) {
    return ChatReady(
      currentUser: currentUser,
      messages: messages ?? this.messages,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}
