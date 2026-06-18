import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../models/expense_model.dart';
import '../models/meal_model.dart';
import '../models/task_model.dart';
import '../models/activity_log_model.dart';
import '../models/notice_model.dart';
import '../models/sos_alert_model.dart';
import '../models/bazar_list_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // flat sub-collection shortcut
  static CollectionReference _flat(String flatId, String col) =>
      _db.collection('flats').doc(flatId).collection(col);

  //  USERS
  // Only returns active members (for member list display)
  static Stream<List<UserModel>> getMembers(String flatId) {
    return _db
        .collection('users')
        .where('flatId', isEqualTo: flatId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => UserModel.fromMap(d.data())).toList(),
        );
  }

  static Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  static Future<void> transferAdmin(
    String newAdminUid,
    String oldAdminUid,
  ) async {
    final batch = _db.batch();
    batch.update(_db.collection('users').doc(oldAdminUid), {'role': 'member'});
    batch.update(_db.collection('users').doc(newAdminUid), {'role': 'admin'});
    await batch.commit();
  }

  // Soft delete: set status='removed', clear flatId — data preserved
  static Future<void> removeMember(String uid, String flatId) async {
    await _db.collection('users').doc(uid).update({
      'status': 'removed',
      'flatId': '',
    });
    await _db.collection('flats').doc(flatId).update({
      'memberCount': FieldValue.increment(-1),
    });
  }

  //  JOIN REQUESTS
  // Stream of pending join requests for a flat
  static Stream<List<Map<String, dynamic>>> getPendingRequests(String flatId) {
    return _flat(flatId, 'join_requests')
        .orderBy('requestedAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
              .toList(),
        );
  }

  // Admin approves one or more pending users
  static Future<void> approveMembers(String flatId, List<String> uids) async {
    final batch = _db.batch();
    for (final uid in uids) {
      // Activate the user
      batch.update(_db.collection('users').doc(uid), {
        'status': 'active',
        'flatId': flatId,
      });
      // Remove from join_requests
      batch.delete(_flat(flatId, 'join_requests').doc(uid));
    }
    // Update member count
    batch.update(_db.collection('flats').doc(flatId), {
      'memberCount': FieldValue.increment(uids.length),
    });
    await batch.commit();
  }

  //  MESSAGES
  static Stream<List<MessageModel>> getMessages(String flatId, String chatId) {
    return _flat(flatId, 'chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => MessageModel.fromMap(d.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  static Future<void> sendMessage(
    String flatId,
    String chatId,
    MessageModel message,
  ) async {
    await _flat(
      flatId,
      'chats',
    ).doc(chatId).collection('messages').doc(message.id).set(message.toMap());

    final preview = message.type == 'image' ? '📷 Image' : message.text ?? '';
    await _flat(flatId, 'chats').doc(chatId).set({
      'lastMessage': preview,
      'lastTimestamp': message.timestamp.toIso8601String(),
      'lastSender': message.senderName,
    }, SetOptions(merge: true));
  }

  static Future<void> ensureGroupChat(String flatId) async {
    final doc = await _flat(flatId, 'chats').doc('group').get();
    if (!doc.exists) {
      await _flat(flatId, 'chats').doc('group').set({
        'type': 'group',
        'name': 'Flat Group Chat',
        'lastMessage': '',
        'lastTimestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  static Future<String> ensurePrivateChat(
    String flatId,
    String myUid,
    String otherUid,
    String otherName,
    String myName,
  ) async {
    final ids = [myUid, otherUid]..sort();
    final chatId = '${ids[0]}_${ids[1]}';
    final doc = await _flat(flatId, 'chats').doc(chatId).get();
    if (!doc.exists) {
      await _flat(flatId, 'chats').doc(chatId).set({
        'type': 'private',
        'members': [myUid, otherUid],
        'memberNames': {myUid: myName, otherUid: otherName},
        'lastMessage': '',
        'lastTimestamp': DateTime.now().toIso8601String(),
      });
    }
    return chatId;
  }

  static Stream<List<Map<String, dynamic>>> getMyChats(
    String flatId,
    String uid,
  ) {
    return _flat(
      flatId,
      'chats',
    ).orderBy('lastTimestamp', descending: true).snapshots().map((snap) {
      return snap.docs
          .map((d) => {'id': d.id, ...d.data() as Map<String, dynamic>})
          .where((chat) {
            if (chat['type'] == 'group') return true;
            final members = chat['members'] as List?;
            return members != null && members.contains(uid);
          })
          .toList();
    });
  }

  //  EXPENSES
  static Stream<List<ExpenseModel>> getExpenses(String flatId) {
    return _flat(flatId, 'expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => ExpenseModel.fromMap(d.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  static Future<void> addExpense(String flatId, ExpenseModel expense) async {
    await _flat(flatId, 'expenses').doc(expense.id).set(expense.toMap());
  }

  static Future<void> deleteExpense(String flatId, String id) async {
    await _flat(flatId, 'expenses').doc(id).delete();
  }

  //  MEALS
  static Stream<List<MealModel>> getMeals(String flatId, int year, int month) {
    return _flat(flatId, 'meals')
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => MealModel.fromMap(d.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  static Future<void> setMeal(String flatId, MealModel meal) async {
    await _flat(flatId, 'meals').doc(meal.id).set(meal.toMap());
  }

  //  TASKS
  static Stream<List<TaskModel>> getTasks(String flatId) {
    return _flat(flatId, 'tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => TaskModel.fromMap(d.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  static Future<void> addTask(String flatId, TaskModel task) async {
    await _flat(flatId, 'tasks').doc(task.id).set(task.toMap());
  }

  static Future<void> completeTask(
    String flatId,
    String taskId,
    String userId,
  ) async {
    final docRef = _flat(flatId, 'tasks').doc(taskId);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;
    final task = TaskModel.fromMap(data);

    // already completed by this user — skip
    if (task.completedBy.contains(userId)) return;

    final updatedCompletedBy = [...task.completedBy, userId];

    // check if all assigned members are done
    final allDone =
        task.assignedTo.isNotEmpty &&
        task.assignedTo.every((uid) => updatedCompletedBy.contains(uid));

    await docRef.update({
      'completedBy': FieldValue.arrayUnion([userId]),
      if (allDone) 'status': 'completed',
    });
  }

  //  NOTICES
  static Stream<List<NoticeModel>> getNotices(String flatId) {
    return _flat(flatId, 'notices')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => NoticeModel.fromMap(d.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  static Future<void> addNotice(String flatId, NoticeModel notice) async {
    await _flat(flatId, 'notices').doc(notice.id).set(notice.toMap());
  }

  //  ACTIVITY LOG
  static Future<void> logActivity(String flatId, ActivityLogModel log) async {
    await _flat(flatId, 'activity_logs').doc(log.id).set(log.toMap());
  }

  static Stream<List<ActivityLogModel>> getActivityLogs(
    String flatId, {
    String? type,
  }) {
    return _flat(
      flatId,
      'activity_logs',
    ).orderBy('timestamp', descending: true).limit(100).snapshots().map((snap) {
      final all = snap.docs
          .map(
            (d) => ActivityLogModel.fromMap(d.data() as Map<String, dynamic>),
          )
          .toList();

      if (type == null || type == 'all') return all;

      if (type == 'bazar') {
        return all
            .where(
              (log) => log.type == 'bazar_add' || log.type == 'bazar_update',
            )
            .toList();
      }

      return all.where((log) => log.type == type).toList();
    });
  }

  static Future<TaskModel?> getTaskOnce(String flatId, String taskId) async {
    final doc = await _flat(flatId, 'tasks').doc(taskId).get();
    if (!doc.exists) return null;
    return TaskModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  static Future<void> deleteTaskCompleteLog(
    String flatId,
    String taskId,
  ) async {
    final snap = await _flat(flatId, 'activity_logs')
        .where('type', isEqualTo: 'task_complete')
        .where('relatedId', isEqualTo: taskId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  //  SOS
  static Stream<List<SosAlertModel>> getActiveSosAlerts(String flatId) {
    return _flat(flatId, 'sos_alerts')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => SosAlertModel.fromMap(d.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  static Future<void> createSosAlert(SosAlertModel alert) async {
    await _flat(alert.flatId, 'sos_alerts').doc(alert.id).set(alert.toMap());
  }

  static Future<void> updateSosLocation(
    String flatId,
    String alertId,
    double lat,
    double lng,
  ) async {
    await _flat(
      flatId,
      'sos_alerts',
    ).doc(alertId).update({'latitude': lat, 'longitude': lng});
  }

  static Future<void> cancelSosAlert(String flatId, String alertId) async {
    await _flat(flatId, 'sos_alerts').doc(alertId).update({'isActive': false});
  }

  static Future<void> saveOneSignalPlayerId(String uid, String playerId) async {
    await _db.collection('users').doc(uid).update({
      'oneSignalPlayerId': playerId,
    });
  }

  static Future<List<String>> getMembersPlayerIds(
    String flatId,
    String excludeUid,
  ) async {
    final snap = await _db
        .collection('users')
        .where('flatId', isEqualTo: flatId)
        .where('status', isEqualTo: 'active')
        .get();

    final ids = <String>[];
    for (final doc in snap.docs) {
      if (doc.id == excludeUid) continue;
      final pid = doc.data()['oneSignalPlayerId'] as String?;
      if (pid != null && pid.isNotEmpty) ids.add(pid);
    }
    return ids;
  }

  //  BAZAR LIST
  static Stream<List<BazarListModel>> getBazarLists(String flatId) {
    return _flat(flatId, 'bazar_lists')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => BazarListModel.fromMap(d.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  static Future<void> addBazarList(String flatId, BazarListModel bazar) async {
    await _flat(flatId, 'bazar_lists').doc(bazar.id).set(bazar.toMap());
  }

  static Future<void> updateBazarList(
    String flatId,
    BazarListModel bazar,
  ) async {
    await _flat(flatId, 'bazar_lists').doc(bazar.id).update(bazar.toMap());
  }

  static Future<String?> getFlatName(String flatId) async {
    final doc = await _db.collection('flats').doc(flatId).get();
    return doc.data()?['flatName'] as String?;
  }
}
