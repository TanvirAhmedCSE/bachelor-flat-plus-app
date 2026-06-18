import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_model.dart';
import '../../models/message_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  String? _flatId;
  String? _chatId;

  ChatBloc() : super(ChatInitial()) {
    on<ChatInitialized>(_onInitialized);
    on<ChatTextSent>(_onTextSent);
    on<ChatImageSent>(_onImageSent);
  }

  Future<void> _onInitialized(
    ChatInitialized event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    _flatId = event.flatId;
    _chatId = event.chatId;

    final user = await AuthService.getCurrentUserModel();
    if (user == null) {
      emit(ChatFailure('User not found'));
      return;
    }

    await emit.forEach<List<MessageModel>>(
      FirestoreService.getMessages(_flatId!, _chatId!),
      onData: (messages) => ChatReady(
        currentUser: user,
        messages: messages,
        isUploading: state is ChatReady
            ? (state as ChatReady).isUploading
            : false,
      ),
    );
  }

  Future<void> _onTextSent(ChatTextSent event, Emitter<ChatState> emit) async {
    final current = state;
    if (current is! ChatReady) return;
    if (event.text.trim().isEmpty) return;

    final msg = MessageModel(
      id: const Uuid().v4(),
      senderId: current.currentUser.uid,
      senderName: current.currentUser.name,
      text: event.text.trim(),
      type: 'text',
      timestamp: DateTime.now(),
    );
    await FirestoreService.sendMessage(_flatId!, _chatId!, msg);
  }

  Future<void> _onImageSent(
    ChatImageSent event,
    Emitter<ChatState> emit,
  ) async {
    final current = state;
    if (current is! ChatReady) return;

    final msg = MessageModel(
      id: const Uuid().v4(),
      senderId: current.currentUser.uid,
      senderName: current.currentUser.name,
      imageUrl: event.imageUrl,
      type: 'image',
      timestamp: DateTime.now(),
    );
    await FirestoreService.sendMessage(_flatId!, _chatId!, msg);
  }
}
