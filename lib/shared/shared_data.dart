import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:manag_department_software_2/layout/admin_home_layout.dart';
import 'package:manag_department_software_2/layout/employee_home_layout.dart';
import 'package:manag_department_software_2/layout/principal_home_layout.dart';
import 'package:manag_department_software_2/layout/secretary_home_layout.dart';
import 'package:manag_department_software_2/screenes/login_screen.dart';

class SharedData extends ChangeNotifier {
  static final SharedData instance = SharedData._();
  SharedData._();

  // =========================
  // Firebase
  // =========================
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================
  // Lifecycle Guard
  // =========================
  bool _initialized = false;
  bool _disposed = false;

  // حالة استعادة الجلسة عند فتح التطبيق (لسه بنتحقق مين المستخدم المسجل)
  bool authRestoring = true;

  // Stream Subscriptions (IMPORTANT)
  StreamSubscription<User?>? _authSub;
  StreamSubscription? _usersSub;
  StreamSubscription? _devicesSub;
  StreamSubscription? _schoolsSub;
  StreamSubscription? _requestsSub;
  StreamSubscription? _transfersSub;
  StreamSubscription? _commentsSub;
  StreamSubscription? _deviceTypesSub;

  // =========================
  // STATE (RAW)
  // =========================
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> devices = [];
  List<Map<String, dynamic>> schools = [];
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> transfers = [];
  List<Map<String, dynamic>> taskComments = [];
  List<Map<String, dynamic>> deviceTypes = [];

  Map<String, dynamic>? get school {
    final schoolNum = currentUser?['schoolNumber']?.toString();
    if (schoolNum == null || schoolNum.isEmpty) return null;
    return schools.firstWhere(
      (s) => s['number'].toString() == schoolNum,
      orElse: () => {},
    );
  }

  // =========================
  // CACHED COMPUTED STATE
  // =========================
  List<Map<String, dynamic>> pendingRequests = [];
  List<Map<String, dynamic>> activeRequests = [];
  List<Map<String, dynamic>> completedRequests = [];

  Map<String, dynamic> dashboardStats = {};

  void init() {
    if (_initialized) return;
    _initialized = true;

    _listenUsers();
    _listenDevices();
    _listenSchools();
    _listenRequests();
    _listenTransfers();
    _listenComments();
    _listenDeviceTypes();
    _listenAuthState();
  }

  // يراقب حالة تسجيل الدخول بـ Firebase Auth ويستعيد بيانات المستخدم
  // تلقائياً عند فتح التطبيق (بدل ما يضطر يسجل دخول كل مرة).
  void _listenAuthState() {
    _authSub?.cancel();
    _authSub = _auth.authStateChanges().listen((firebaseUser) async {
      if (_disposed) return;

      if (firebaseUser == null) {
        currentUser = null;
        authRestoring = false;
        _computeDashboard();
        if (!_disposed) notifyListeners();
        return;
      }

      try {
        final doc = await _db.collection('users').doc(firebaseUser.uid).get();
        if (!doc.exists) {
          // مستخدم موجود بـ Auth بس ملفه الشخصي مش موجود بـ Firestore
          currentUser = null;
        } else {
          currentUser = {'id': doc.id, ...doc.data()!};
        }
      } catch (_) {
        currentUser = null;
      }

      authRestoring = false;
      _computeDashboard();
      if (!_disposed) notifyListeners();
    });
  }

  void _listenUsers() {
    _usersSub?.cancel();

    _usersSub = _db.collection('users').snapshots().listen((snapshot) {
      if (_disposed) return;

      users = snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
      _usersReady = true;
      _recomputeAll();
    });
  }

  void _listenDevices() {
    _devicesSub?.cancel();

    _devicesSub = _db.collection('devices').snapshots().listen((snapshot) {
      if (_disposed) return;

      devices = snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();

      _devicesReady = true;
      _recomputeAll();
    });
  }

  void _listenSchools() {
    _schoolsSub?.cancel();

    _schoolsSub = _db.collection('schools').snapshots().listen((snapshot) {
      if (_disposed) return;

      schools = snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
      _schoolsReady = true;
      _recomputeAll();
    });
  }

  void _listenRequests() {
    _requestsSub?.cancel();

    _requestsSub = _db.collection('requests').snapshots().listen((snapshot) {
      if (_disposed) return;

      requests = snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
      _requestsReady = true;
      _recomputeAll();
    });
  }

  void _listenTransfers() {
    _transfersSub?.cancel();

    _transfersSub = _db.collection('transfers').snapshots().listen((snapshot) {
      if (_disposed) return;

      transfers = snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
      _transfersReady = true;
      _recomputeAll();
    });
  }

  void _listenComments() {
    _commentsSub?.cancel();

    _commentsSub = _db.collection('taskcomments').snapshots().listen((
      snapshot,
    ) {
      if (_disposed) return;

      taskComments = snapshot.docs
          .map((e) => {'id': e.id, ...e.data()})
          .toList();

      _commentsReady = true;
      _recomputeAll();
    });
  }

  void _listenDeviceTypes() {
    _deviceTypesSub?.cancel();

    _deviceTypesSub = _db.collection('deviceTypes').snapshots().listen((
      snapshot,
    ) {
      if (_disposed) return;

      deviceTypes = snapshot.docs
          .map((e) => {'id': e.id, ...e.data()})
          .toList();

      _deviceTypesReady = true;
      _recomputeAll();
    });
  }

  bool _usersReady = false;
  bool _devicesReady = false;
  bool _schoolsReady = false;
  bool _requestsReady = false;
  bool _transfersReady = false;
  bool _commentsReady = false;
  bool _deviceTypesReady = false;
  bool get _ready =>
      _usersReady &&
      _devicesReady &&
      _schoolsReady &&
      _requestsReady &&
      _transfersReady &&
      _commentsReady &&
      _deviceTypesReady;
  Timer? _debounce;
  void _recomputeAll() {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 80), () {
      _computeRequests();
      if (!_ready || _disposed) return;
      _computeDashboard();

      if (!_disposed) {
        notifyListeners();
      }
    });
  }

  void _computeRequests() {
    pendingRequests = requests.where((r) => r['status'] == 'معلقة').toList();

    activeRequests = requests.where((r) => r['status'] == 'جارية').toList();
    completedRequests = requests.where((r) => r['status'] == 'مكتملة').toList();
  }

  void _computeDashboard() {
    final schoolNum = currentUser?['schoolNumber']?.toString() ?? '';
    final schoolDevices = devicesBySchool(schoolNum);
    final schoolRequests = getRequestsInSchool(schoolNum);

    // ===== مهام المستخدم الحالي =====
    final username = currentUser?['username'];
    final myTasks = username == null
        ? <Map<String, dynamic>>[]
        : requests.where((r) {
            final List participants = r['participants'] ?? [];
            return participants.any((p) => p['username'] == username);
          }).toList();

    dashboardStats = {
      'schools': schools.length,
      'devices': devices.length,
      'pendingRequests': pendingRequests.length,
      'activeRequests': activeRequests.length,
      'completedRequests': completedRequests.length,
      'users': users.length,
      // إحصائيات المدرسة
      'devicesInSchool': schoolDevices.length,
      'devicesInSchoolWorke': schoolDevices
          .where((d) => d['status'] == 'يعمل')
          .length,
      'devicesInSchoolDamaged': schoolDevices
          .where((d) => d['status'] == 'تالف')
          .length,
      'requestsInSchool': schoolRequests.length,
      'getRequestsInSchoolDane': schoolRequests
          .where((r) => r['status'] == 'مكتملة')
          .length,
      'myTasks': myTasks.length,
      // ===== إحصائيات مهامي (الموظف الحالي) =====
      'myTasksCount': myTasks.length,
      'myActiveTasksCount': myTasks.where((r) => r['status'] == 'جارية').length,
      'myCompletedTasksCount': myTasks
          .where((r) => r['status'] == 'مكتملة')
          .length,
    };
  }

  @override
  void dispose() {
    _disposed = true;

    _authSub?.cancel();
    _usersSub?.cancel();
    _devicesSub?.cancel();
    _schoolsSub?.cancel();
    _requestsSub?.cancel();
    _transfersSub?.cancel();
    _commentsSub?.cancel();
    _deviceTypesSub?.cancel();

    super.dispose();
  }

  // =========================
  // Current User
  // =========================
  Map<String, dynamic>? currentUser;
  // فحص صلاحية معينة - الأدمن دايمًا عنده كل الصلاحيات
  bool hasPermission(String permission) {
    final role = currentUser?['role'];
    if (role == 'admin') return true;

    final List permissions = currentUser?['permissions'] ?? [];
    return permissions.contains(permission);
  }

  Future<void> loginWithUsername(
    BuildContext context,
    String username,
    String password,
  ) async {
    try {
      // 1) نحوّل اسم المستخدم إلى إيميل عبر مجموعة "usernames" العامة
      //    (هذه المجموعة لا تحتوي على أي شيء حساس، فقط username -> email)
      final usernameDoc = await _db
          .collection('usernames')
          .doc(username.trim().toLowerCase())
          .get();

      if (!usernameDoc.exists) {
        _showError(context, 'اسم المستخدم غير صحيح');
        return;
      }

      final email = usernameDoc.data()?['email'] as String?;
      if (email == null || email.isEmpty) {
        _showError(context, 'حساب هذا المستخدم غير مكتمل، راجع الإدارة');
        return;
      }

      // 2) تسجيل الدخول الفعلي عبر Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        _showError(context, 'حدث خطأ، يرجى المحاولة لاحقاً');
        return;
      }

      // 3) جلب الملف الشخصي (الدور/الصلاحيات...) من Firestore
      final userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        _showError(context, 'حساب هذا المستخدم غير مكتمل، راجع الإدارة');
        await _auth.signOut();
        return;
      }

      final userData = {'id': userDoc.id, ...userDoc.data()!};

      // ✅ التحقق من تفعيل الحساب
      if (userData['isActive'] == false && userData['role'] == 'employee') {
        _showError(context, 'هذا الحساب غير مفعّل، يرجى مراجعة الإدارة');
        await _auth.signOut();
        return;
      }

      // حفظ بيانات المستخدم الحالي
      currentUser = userData;
      _computeDashboard();
      notifyListeners();

      // التنقل بناءً على الصلاحية
      if (!context.mounted) return;

      final String role = userData['role'] ?? '';

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHomeLayout()),
        );
      } else if (role == 'secretary') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SecretaryHomeLayout()),
        );
      } else if (role == 'employee') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => EmployeeHomeLayout()),
        );
      } else if (role == 'principal') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PrincipalHomeLayout()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          _showError(context, 'كلمة المرور غير صحيحة');
          break;
        case 'user-not-found':
          _showError(context, 'اسم المستخدم غير صحيح');
          break;
        case 'too-many-requests':
          _showError(context, 'محاولات كثيرة، حاول لاحقاً');
          break;
        case 'user-disabled':
          _showError(context, 'هذا الحساب معطّل، راجع الإدارة');
          break;
        default:
          _showError(context, 'حدث خطأ، يرجى المحاولة لاحقاً');
      }
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, 'حدث خطأ، يرجى المحاولة لاحقاً');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo'),
          textAlign: TextAlign.right,
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // لتسجيل الخروج
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    currentUser = null;
    _computeDashboard();
    notifyListeners();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  // جلب تعليقات طلب معين
  List<Map<String, dynamic>> taskCommentsByRequest(String requestNumber) {
    return taskComments
        .where((c) => c['requestNumber'] == requestNumber)
        .toList();
  }

  // جلب مدرسة بناءً على رقمها
  Map<String, dynamic> schoolBySchoolNumber(String schoolNumber) {
    return schools.firstWhere(
      (s) => s['number'].toString() == schoolNumber,
      orElse: () => {'name': 'غير معروف'},
    );
  }
  // =========================
  // دوال Firestore (CRUD)
  // =========================

  Future<void> addTaskComments({
    required String requestsNumber,
    required String employeeId,
    required String comment,
  }) async {
    await _db.collection('taskcomments').add({
      'requestNumber': requestsNumber,
      'employeeId': employeeId,
      'comment': comment,
      'createdAt': DateTime.now(),
    });
  }

  Future<void> updateRequest(
    String requestNumber,
    Map<String, dynamic> data,
  ) async {
    final query = await _db
        .collection('requests')
        .where('requestNumber', isEqualTo: requestNumber)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(data);
    }
  }

  Future<void> updateDevice(String deviceId, Map<String, dynamic> data) async {
    final query = await _db
        .collection('devices')
        .where('id', isEqualTo: deviceId)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(data);
    }
  }

  Future<void> addSchool({
    required String number,
    required String name,
    required String phonenumber,
    required String address,
    required String gender,
    required String interval,
    required String stage,
    required String type,
    required String managerName,
    required String notes,
  }) async {
    await _db.collection('schools').add({
      'number': number,
      'name': name,
      'phonenumber': phonenumber,
      'address': address,
      'gender': gender,
      'interval': interval,
      'stage': stage,
      'type': type,
      'managerName': managerName,
      'notes': notes,
    });
  }

  Future<void> updateSchool(
    String schoolNumber,
    Map<String, dynamic> data,
  ) async {
    final query = await _db
        .collection('schools')
        .where('number', isEqualTo: schoolNumber)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update(data);
    }
  }

  Future<void> deleteSchool(String schoolNumber) async {
    final query = await _db
        .collection('schools')
        .where('number', isEqualTo: schoolNumber)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.delete();
    }
  }

  // ينشئ حساب Firebase Auth حقيقي + ملف Firestore + ربط اسم المستخدم بالإيميل.
  // يستخدم تطبيق Firebase مؤقت (secondary app) حتى لا يفقد الأدمن جلسته
  // الحالية أثناء إنشاء حساب موظف جديد (هذه مشكلة معروفة في Firebase Auth
  // للـ client SDK: createUser يسجّل دخول الحساب الجديد على نفس الجلسة).
  Future<void> addUser({
    required String name,
    required String username,
    required String password,
    required String email,
    required String roleStr,
    required String role,
    required String schoolNumber,
    required String employeeNumber,
    required List permissions,
  }) async {
    final usernameKey = username.trim().toLowerCase();

    // تأكد أن اسم المستخدم غير مستخدم من قبل
    final existing = await _db.collection('usernames').doc(usernameKey).get();
    if (existing.exists) {
      throw Exception('اسم المستخدم مستخدم مسبقاً');
    }

    FirebaseApp? tempApp;
    try {
      tempApp = await Firebase.initializeApp(
        name: 'tempAuthApp_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      final cred = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      // ملف المستخدم بـ Firestore (بدون كلمة مرور إطلاقاً)
      await _db.collection('users').doc(uid).set({
        'name': name,
        'username': username,
        'email': email,
        'role': role,
        'roleStr': roleStr,
        'schoolNumber': schoolNumber,
        'employeeNumber': employeeNumber,
        'permissions': permissions,
        'isActive': true,
      });

      // ربط اسم المستخدم بالإيميل لتسهيل تسجيل الدخول
      await _db.collection('usernames').doc(usernameKey).set({
        'email': email,
      });
    } finally {
      // نسجّل خروج من الحساب المؤقت ونحذف التطبيق الثانوي دون أي أثر
      // على جلسة الأدمن الأساسية.
      if (tempApp != null) {
        await FirebaseAuth.instanceFor(app: tempApp).signOut();
        await tempApp.delete();
      }
    }
  }

  // ✅ تحديث مستخدم بالاعتماد على معرف المستند (أسرع وأدق من البحث بـ username)
  Future<void> updateUserById(String id, Map<String, dynamic> data) async {
    await _db.collection('users').doc(id).update(data);
  }

  // ✅ حذف مستخدم بالاعتماد على معرف المستند
  // ملاحظة مهمة: هذا يحذف ملف Firestore فقط. حذف حساب Firebase Auth
  // الفعلي يحتاج صلاحيات Admin SDK (لا يمكن تنفيذه من التطبيق مباشرة
  // لأسباب أمنية) — يُنصح بعمل Cloud Function صغيرة لهذا الغرض، أو
  // إلغاء تفعيل الحساب عبر setUserActiveById بدلاً من الحذف النهائي.
  Future<void> deleteUserById(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    final username = doc.data()?['username']?.toString().trim().toLowerCase();

    await _db.collection('users').doc(id).delete();

    if (username != null && username.isNotEmpty) {
      await _db.collection('usernames').doc(username).delete();
    }
  }

  // ✅ تفعيل/إلغاء تفعيل بالاعتماد على معرف المستند
  Future<void> setUserActiveById(String id, bool isActive) async {
    await _db.collection('users').doc(id).update({'isActive': isActive});
  }

  // Future<void> updateUser(String? username, Map<String, dynamic> data) async {
  //   if (username == null) return;
  //   final query = await _db
  //       .collection('users')
  //       .where('username', isEqualTo: username)
  //       .limit(1)
  //       .get();
  //   if (query.docs.isNotEmpty) {
  //     await query.docs.first.reference.update(data);
  //   }
  // }

  // // حذف مستخدم/موظف نهائياً من Firestore
  // Future<void> deleteUser(String? username) async {
  //   if (username == null) return;
  //   final query = await _db
  //       .collection('users')
  //       .where('username', isEqualTo: username)
  //       .limit(1)
  //       .get();
  //   if (query.docs.isNotEmpty) {
  //     await query.docs.first.reference.delete();
  //   }
  // }

  // // تفعيل / إلغاء تفعيل موظف
  // Future<void> setUserActive(String? username, bool isActive) async {
  //   if (username == null) return;
  //   final query = await _db
  //       .collection('users')
  //       .where('username', isEqualTo: username)
  //       .limit(1)
  //       .get();
  //   if (query.docs.isNotEmpty) {
  //     await query.docs.first.reference.update({'isActive': isActive});
  //   }
  // }

  Future<void> addDevice({
    required String number,
    required String type,
    required String id,
    required String serialNumber,
    required String brand,
    required String model,
    required DateTime purchaseDate,
    required String status,
    required String schoolNumber,
    required String schoolName,
    required String location,
    required String statusIn,
    required String project,
    required bool printTo,

    required String nameIn,
    required String note,
    String specs = '', // ✅ جديد: مواصفات الجهاز (المعالج/الرام/التخزين)
  }) async {
    await _db.collection('devices').add({
      'number': number,
      'type': type,
      'id': id,
      'serialNumber': serialNumber,
      'brand': brand,
      'model': model,
      'purchaseDate': purchaseDate,
      'status': status,
      'schoolNumber': schoolNumber,
      'schoolName': schoolName,
      'location': location,
      'statusIn': statusIn,
      'project': project,
      'printTo': printTo,

      'nameIn': nameIn,
      'note': note,
      'specs': specs, // ✅ جديد: مواصفات الجهاز
    });
  }

  // مستخدم في SchoolListScreen
  Map<String, Map<String, dynamic>> get userBySchool {
    final map = <String, Map<String, dynamic>>{};
    for (final user in users) {
      final schoolNum = user['schoolNumber']?.toString();
      if (schoolNum != null && schoolNum.isNotEmpty) {
        map[schoolNum] = user;
      }
    }
    return map;
  }

  // مستخدم في DeviceDetailsAdminScreen وSchoolListScreen
  List<Map<String, dynamic>> devicesBySchool(String schoolNumber) {
    return devices
        .where((d) => d['schoolNumber'].toString() == schoolNumber)
        .toList();
  }

  // مستخدم في DeviceDetailsAdminScreen
  List<Map<String, dynamic>> getRequestsInDevice(String deviceId) {
    return requests.where((r) => r['devicNumber'] == deviceId).toList();
  }

  // مستخدم في AssignTaskAdminScreen
  List<Map<String, dynamic>> getEmployeesAndAdmin() {
    return users
        .where(
          (u) =>
              (u['role'] == 'employee' || u['role'] == 'admin') &&
              u['isActive'] == true,
        )
        .toList();
  }

  // طلبات مدرسة معينة
  List<Map<String, dynamic>> getRequestsInSchool(String schoolNumber) {
    return requests
        .where((r) => r['schoolNumber'].toString() == schoolNumber)
        .toList();
  }

  Future<void> addRequest({
    required String requestNumber,
    required String schoolNumber,
    required String devicNumber,
    required String requestType,
    required String priority,
    required String description,
    required String status,
    required DateTime date,
    required DateTime expiryDate,
    required List participants,
  }) async {
    await _db.collection('requests').add({
      'requestNumber': requestNumber,
      'schoolNumber': schoolNumber,
      'devicNumber': devicNumber,
      'requestType': requestType,
      'priority': priority,
      'description': description,
      'status': status,
      'date': date,
      'expiryDate': expiryDate,
      'participants': participants,
    });
  }
  // ============= سجل النقل =============

  // جلب سجلات نقل جهاز معين
  List<Map<String, dynamic>> getTransferLogByDevice(String deviceId) {
    final logs = transfers.where((t) => t['deviceId'] == deviceId).toList();
    logs.sort((a, b) {
      final da = a['date'] is Timestamp
          ? (a['date'] as Timestamp).toDate()
          : DateTime(2000);
      final db = b['date'] is Timestamp
          ? (b['date'] as Timestamp).toDate()
          : DateTime(2000);
      return db.compareTo(da); // الأحدث أولاً
    });
    return logs;
  }

  // إضافة سجل نقل جديد + تحديث بيانات الجهاز
  Future<void> addTransfer({
    required String deviceId,
    required String fromSchoolNumber,
    required String fromSchoolName,
    required String toSchoolNumber,
    required String toSchoolName,
    required String byUser,
    String note = '',
  }) async {
    await _db.collection('transfers').add({
      'deviceId': deviceId,
      'fromSchoolNumber': fromSchoolNumber,
      'fromSchoolName': fromSchoolName,
      'toSchoolNumber': toSchoolNumber,
      'toSchoolName': toSchoolName,
      'byUser': byUser,
      'note': note,
      'date': DateTime.now(),
    });

    // تحديث المدرسة الحالية للجهاز
    await updateDevice(deviceId, {
      'schoolNumber': toSchoolNumber,
      'schoolName': toSchoolName,
    });
  }

  // ============= حذف جهاز =============
  Future<void> deleteDevice(String deviceId) async {
    final batch = _db.batch();

    // 1. هات مستند الجهاز نفسه
    final deviceQuery = await _db
        .collection('devices')
        .where('id', isEqualTo: deviceId)
        .limit(1)
        .get();

    if (deviceQuery.docs.isEmpty) return;
    batch.delete(deviceQuery.docs.first.reference);

    // 2. هات كل سجلات النقل المرتبطة بالجهاز واحذفها
    final transfersQuery = await _db
        .collection('transfers')
        .where('deviceId', isEqualTo: deviceId)
        .get();

    for (final doc in transfersQuery.docs) {
      batch.delete(doc.reference);
    }

    // 3. نفّذ الحذف كله مرة واحدة (atomic)
    await batch.commit();
  }

  Future<void> addDeviceType({required String name}) async {
    await _db.collection('deviceTypes').add({'name': name});
  }

  Future<void> updateDeviceType(String id, String name) async {
    await _db.collection('deviceTypes').doc(id).update({'name': name});
  }

  Future<void> deleteDeviceType(String id) async {
    await _db.collection('deviceTypes').doc(id).delete();
  }

  bool isDeviceTypeInUse(String typeName) {
    return devices.any((d) => d['type'] == typeName);
  }

  static String formatDate(dynamic value) {
    if (value == null) return '';
    if (value is Timestamp) {
      return value.toDate().toString().split(' ').first;
    }
    if (value is DateTime) {
      return value.toString().split(' ').first;
    }
    if (value is String) {
      try {
        return DateTime.parse(value).toString().split(' ').first;
      } catch (_) {
        return value.split(' ').first; // كحل أخير لو مش تاريخ صالح
      }
    }
    return value.toString();
  }

  // كل مهام الموظف (بكل الحالات) لو احتجتها لاحقاً
  List<Map<String, dynamic>> getEmployeeAllTasks(String username) {
    return requests.where((r) {
      final List participants = r['participants'] ?? [];
      return participants.any((p) => p['username'] == username);
    }).toList();
  }

  // إنجازات موظف معين ضمن فترة تاريخية (فلترة اختيارية)
  List<Map<String, dynamic>> getEmployeeAchievements(
    String username, {
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return requests.where((r) {
      final List participants = r['participants'] ?? [];
      final isParticipant = participants.any((p) => p['username'] == username);
      if (!isParticipant || r['status'] != 'مكتملة') return false;

      if (fromDate != null || toDate != null) {
        final DateTime? rDate = r['date'] is Timestamp
            ? (r['date'] as Timestamp).toDate()
            : (r['date'] is DateTime ? r['date'] as DateTime : null);
        if (rDate == null) return false;

        if (fromDate != null && rDate.isBefore(fromDate)) return false;
        if (toDate != null &&
            rDate.isAfter(toDate.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // إنجازات كل الموظفين مجمّعة حسب اسم المستخدم ضمن فترة تاريخية
  Map<String, List<Map<String, dynamic>>> getAllEmployeesAchievements(
    List<Map<String, dynamic>> employees, {
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final Map<String, List<Map<String, dynamic>>> result = {};
    for (final emp in employees) {
      final username = emp['username'] ?? '';
      result[username] = getEmployeeAchievements(
        username,
        fromDate: fromDate,
        toDate: toDate,
      );
    }
    return result;
  }
}
