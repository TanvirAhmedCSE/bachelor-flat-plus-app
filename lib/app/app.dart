import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/verify_email_screen.dart';
import '../views/home/home_screen.dart';
import '../views/meal/meal_screen.dart';
import '../views/expense/expense_screen.dart';
import '../views/task/task_screen.dart';
import '../views/chat/chat_list_screen.dart';
import '../views/chat/chat_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/activity/activity_screen.dart';
import '../views/notice/notice_list_screen.dart';
import '../views/notice/notice_details_screen.dart';
import '../views/sos/sos_location_screen.dart';
import '../views/bazar/bazar_list_screen.dart';
import '../views/bazar/bazar_list_details_screen.dart';
import '../views/bazar/create_and_edit_bazar_list_screen.dart';
import '../models/notice_model.dart';
import '../models/sos_alert_model.dart';
import '../services/firestore_service.dart';
import '../views/task/task_details_screen.dart';
import '../models/task_model.dart';
import 'theme.dart';

class BachelorFlatApp extends StatefulWidget {
  const BachelorFlatApp({super.key});

  @override
  State<BachelorFlatApp> createState() => _BachelorFlatAppState();
}

class _BachelorFlatAppState extends State<BachelorFlatApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupOneSignalHandler();
  }

  void _setupOneSignalHandler() {
    OneSignal.Notifications.addClickListener((event) async {
      final data = event.notification.additionalData;
      if (data == null || data['type'] != 'sos') return;

      final alertId = data['alertId'] as String?;
      final flatId = data['flatId'] as String?;
      final lat = (data['lat'] as num?)?.toDouble() ?? 0.0;
      final lng = (data['lng'] as num?)?.toDouble() ?? 0.0;

      if (alertId == null || flatId == null) return;

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      SosAlertModel? alert;
      try {
        final snap = await FirestoreService.getActiveSosAlerts(flatId).first;
        alert = snap.where((a) => a.id == alertId).firstOrNull;
      } catch (_) {}

      alert ??= SosAlertModel(
        id: alertId,
        victimUid: '',
        victimName: data['victimName'] ?? 'Someone',
        flatId: flatId,
        latitude: lat,
        longitude: lng,
        triggeredAt: DateTime.now(),
        isActive: true,
      );

      _navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => SosLocationScreen(alert: alert!)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Bachelor Flat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/verify-email': (_) => const VerifyEmailScreen(),
          '/home': (_) => const HomeScreen(),
          '/meal': (_) => const MealScreen(),
          '/expense': (_) => const ExpenseScreen(),
          '/task': (_) => const TaskScreen(),
          '/chat-list': (_) => const ChatListScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/notice-list': (_) => const NoticeListScreen(),
          '/activity': (_) => const ActivityScreen(),
          '/bazar-list': (_) => const BazarListScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/chat') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ChatScreen(
                chatId: args['chatId'],
                chatName: args['chatName'],
                isGroup: args['isGroup'] ?? false,
                flatId: args['flatId'] ?? '',
              ),
            );
          }
          if (settings.name == '/notice-details') {
            final notice = settings.arguments as NoticeModel;
            return MaterialPageRoute(
              builder: (_) => NoticeDetailsScreen(notice: notice),
            );
          }
          if (settings.name == '/bazar-create') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) =>
                  CreateAndEditBazarListScreen(flatId: args['flatId']),
            );
          }
          if (settings.name == '/bazar-details') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => BazarListDetailsScreen(
                bazar: args['bazar'],
                flatId: args['flatId'],
              ),
            );
          }
          if (settings.name == '/task-details') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => TaskDetailsScreen(
                task: args['task'] as TaskModel,
                mode: args['mode'] as TaskViewMode,
                onDone: args['onDone'] as VoidCallback?,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
