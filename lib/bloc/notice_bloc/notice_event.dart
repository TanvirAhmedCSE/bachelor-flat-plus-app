part of 'notice_bloc.dart';

abstract class NoticeEvent {}

class NoticeInitialized extends NoticeEvent {}

class NoticeCategoryChanged extends NoticeEvent {
  final String category;
  NoticeCategoryChanged(this.category);
}

class NoticeMonthChanged extends NoticeEvent {
  final int month;
  NoticeMonthChanged(this.month);
}

class NoticeAdded extends NoticeEvent {
  final String title;
  final String description;
  final String category;
  final List<File> imageFiles;
  NoticeAdded({
    required this.title,
    required this.description,
    required this.category,
    required this.imageFiles,
  });
}
