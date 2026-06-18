part of 'chat_bloc.dart';

abstract class ChatEvent {}

class ChatInitialized extends ChatEvent {
  final String flatId;
  final String chatId;
  ChatInitialized({required this.flatId, required this.chatId});
}

class ChatTextSent extends ChatEvent {
  final String text;
  ChatTextSent(this.text);
}

class ChatImageSent extends ChatEvent {
  final String imageUrl;
  ChatImageSent(this.imageUrl);
}
