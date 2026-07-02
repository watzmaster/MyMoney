import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xfff6f8ff);
  static const ink = Color(0xff15213a);
  static const muted = Color(0xff7b8497);
  static const blue = Color(0xff2f7cff);
  static const purple = Color(0xff7c5cff);
  static const green = Color(0xff35c889);
  static const red = Color(0xffff5f7a);
  static const orange = Color(0xffffb34d);
  static const line = Color(0xffe8ecf5);
}

void main() {
  runApp(const MyMoneyApp());
}

class MyMoneyApp extends StatelessWidget {
  const MyMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyMoney',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.ink,
          titleTextStyle: TextStyle(
            color: AppColors.ink,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.purple, width: 1.4),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 78,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.purple.withValues(alpha: .12),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
              color:
                  states.contains(WidgetState.selected)
                      ? AppColors.purple
                      : AppColors.muted,
              fontWeight:
                  states.contains(WidgetState.selected)
                      ? FontWeight.w800
                      : FontWeight.w600,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          elevation: 10,
          shape: StadiumBorder(),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _token;
  String _baseUrl =
      const String.fromEnvironment('API_BASE_URL').isNotEmpty
          ? const String.fromEnvironment('API_BASE_URL')
          : Platform.isAndroid
          ? 'http://10.0.2.2:8080'
          : 'http://localhost:8080';

  void _signedIn(String token, String baseUrl) {
    setState(() {
      _token = token;
      _baseUrl = baseUrl;
    });
  }

  void _logout() {
    setState(() => _token = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_token == null) {
      return LoginScreen(defaultBaseUrl: _baseUrl, onSignedIn: _signedIn);
    }

    return HomeScreen(
      api: ApiClient(baseUrl: _baseUrl, token: _token),
      onLogout: _logout,
    );
  }
}

class ApiClient {
  ApiClient({required this.baseUrl, this.token});

  final String baseUrl;
  final String? token;

  Future<Map<String, dynamic>> get(String path) => _request('GET', path);

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) {
    return _request('POST', path, body: body);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) {
    return _request('PUT', path, body: body);
  }

  Future<Map<String, dynamic>> delete(String path) => _request('DELETE', path);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final client = HttpClient();
    try {
      final request = await client.openUrl(method, uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }

      final response = await request.close();
      final text = await response.transform(utf8.decoder).join();
      final json =
          text.isEmpty
              ? <String, dynamic>{}
              : jsonDecode(text) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException((json['message'] ?? 'Request failed').toString());
      }
      return json;
    } on SocketException {
      throw ApiException(
        'เชื่อมต่อ API ไม่ได้ ตรวจสอบว่า backend รันอยู่และ URL ถูกต้อง',
      );
    } finally {
      client.close(force: true);
    }
  }
}

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.defaultBaseUrl,
    required this.onSignedIn,
  });

  final String defaultBaseUrl;
  final void Function(String token, String baseUrl) onSignedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _baseUrl;
  final _name = TextEditingController(text: 'Demo User');
  final _email = TextEditingController(text: 'demo@example.com');
  final _password = TextEditingController(text: 'password123');
  bool _register = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _baseUrl = TextEditingController(text: widget.defaultBaseUrl);
  }

  @override
  void dispose() {
    _baseUrl.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final api = ApiClient(baseUrl: _baseUrl.text.trim());
      final body = {
        if (_register) 'name': _name.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text,
      };
      final result = await api.post(
        _register ? '/auth/register' : '/auth/login',
        body,
      );
      widget.onSignedIn(result['token'].toString(), _baseUrl.text.trim());
    } on ApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('เกิดข้อผิดพลาด ลองใหม่อีกครั้ง');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 18),
            _LoginHero(register: _register),
            const SizedBox(height: 28),
            Text(
              _register ? 'สร้างบัญชีใหม่' : 'เข้าสู่ระบบ',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'เชื่อมต่อกับ MyMoney API เดิมของโปรเจกต์นี้',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _softDecoration(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _baseUrl,
                      decoration: const InputDecoration(labelText: 'API URL'),
                      validator:
                          (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'กรอก API URL'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    if (_register) ...[
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'ชื่อ'),
                        validator:
                            (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'กรอกชื่อ'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'อีเมล'),
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (value) =>
                              (value == null || !value.contains('@'))
                                  ? 'อีเมลไม่ถูกต้อง'
                                  : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
                      obscureText: true,
                      validator:
                          (value) =>
                              (value == null || value.length < 8)
                                  ? 'อย่างน้อย 8 ตัวอักษร'
                                  : null,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        child:
                            _loading
                                ? const SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  _register ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ',
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed:
                  _loading
                      ? null
                      : () => setState(() => _register = !_register),
              child: Text(
                _register
                    ? 'มีบัญชีแล้ว เข้าสู่ระบบ'
                    : 'ยังไม่มีบัญชี สมัครสมาชิก',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, required this.onLogout});

  final ApiClient api;
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  bool _loading = true;
  Map<String, dynamic>? _summary;
  List<dynamic> _accounts = [];
  List<dynamic> _categories = [];
  List<dynamic> _transactions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final now = DateTime.now();
      final from = DateTime(now.year, 1, 1);
      final to = DateTime(now.year, 12, 31);
      final results = await Future.wait([
        widget.api.get('/accounts'),
        widget.api.get('/categories'),
        widget.api.get(
          '/transactions?from=${_date(from)}&to=${_date(to)}&limit=200',
        ),
        widget.api.get('/reports/summary?from=${_date(from)}&to=${_date(to)}'),
      ]);
      setState(() {
        _accounts = results[0]['data'] as List<dynamic>;
        _categories = results[1]['data'] as List<dynamic>;
        _transactions = results[2]['data'] as List<dynamic>;
        _summary = results[3]['data'] as Map<String, dynamic>;
      });
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addTransaction() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => TransactionFormScreen(
              api: widget.api,
              accounts: _accounts,
              categories: _categories,
            ),
      ),
    );
    if (created == true) {
      await _load();
      setState(() => _tab = 1);
    }
  }

  Future<void> _editTransaction(Map<String, dynamic> transaction) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) => TransactionFormScreen(
              api: widget.api,
              accounts: _accounts,
              categories: _categories,
              transaction: transaction,
            ),
      ),
    );
    if (updated == true) {
      await _load();
      setState(() => _tab = 1);
    }
  }

  Future<void> _addAccount() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AccountFormScreen(api: widget.api)),
    );
    if (created == true) {
      await _load();
      setState(() => _tab = 2);
    }
  }

  Future<void> _editAccount(Map<String, dynamic> account) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AccountFormScreen(api: widget.api, account: account),
      ),
    );
    if (updated == true) {
      await _load();
      setState(() => _tab = 2);
    }
  }

  Future<void> _addCategory() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CategoryFormScreen(api: widget.api)),
    );
    if (created == true) {
      await _load();
      setState(() => _tab = 3);
    }
  }

  Future<void> _editCategory(Map<String, dynamic> category) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CategoryFormScreen(api: widget.api, category: category),
      ),
    );
    if (updated == true) {
      await _load();
      setState(() => _tab = 3);
    }
  }

  Future<void> _deleteResource(String path, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('ลบ$title?'),
            content: Text('ยืนยันการลบ$titleนี้'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('ยกเลิก'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('ลบ'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;

    try {
      await widget.api.delete(path);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ลบ$titleแล้ว')));
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  VoidCallback? get _fabAction {
    if (_tab == 2) return _addAccount;
    if (_tab == 3) return _addCategory;
    if (_accounts.isEmpty || _categories.isEmpty) return null;
    return _addTransaction;
  }

  String get _fabLabel {
    if (_tab == 2) return 'เพิ่มบัญชี';
    if (_tab == 3) return 'เพิ่มหมวดหมู่';
    return 'เพิ่มรายการ';
  }

  String get _pageTitle {
    return switch (_tab) {
      1 => 'รายการ',
      2 => 'บัญชี',
      3 => 'หมวดหมู่',
      _ => 'ภาพรวม',
    };
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardPage(
        summary: _summary,
        accounts: _accounts,
        categories: _categories,
        transactions: _transactions,
        onShowTransactions: () => setState(() => _tab = 1),
        onEditTransaction: _editTransaction,
      ),
      _TransactionsPage(
        transactions: _transactions,
        onEdit: _editTransaction,
        onDelete: (id) => _deleteResource('/transactions/$id', 'รายการ'),
      ),
      _AccountsPage(
        accounts: _accounts,
        onEdit: _editAccount,
        onDelete: (id) => _deleteResource('/accounts/$id', 'บัญชี'),
      ),
      _CategoriesPage(
        categories: _categories,
        onEdit: _editCategory,
        onDelete: (id) => _deleteResource('/categories/$id', 'หมวดหมู่'),
      ),
    ];

    return Scaffold(
      appBar:
          _tab == 0
              ? null
              : AppBar(
                toolbarHeight: 82,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(_pageTitle)],
                ),
                actions: [
                  _CircleButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: _load,
                  ),
                  const SizedBox(width: 8),
                  _CircleButton(
                    icon: Icons.logout_rounded,
                    onTap: widget.onLogout,
                  ),
                  const SizedBox(width: 16),
                ],
              ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : SafeArea(
                top: _tab == 0,
                child: RefreshIndicator(onRefresh: _load, child: pages[_tab]),
              ),
      floatingActionButton: _GradientFab(label: _fabLabel, onTap: _fabAction),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'ภาพรวม',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'รายการ',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'บัญชี',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'หมวดหมู่',
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      shadowColor: AppColors.blue.withValues(alpha: .12),
      elevation: 8,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? .46 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Ink(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [AppColors.purple, AppColors.blue],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: .32),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({
    super.key,
    required this.api,
    required this.accounts,
    required this.categories,
    this.transaction,
  });

  final ApiClient api;
  final List<dynamic> accounts;
  final List<dynamic> categories;
  final Map<String, dynamic>? transaction;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  String _type = 'expense';
  int? _accountId;
  int? _categoryId;
  DateTime _dateValue = DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.transaction != null;

  List<dynamic> get _visibleCategories {
    return widget.categories.where((item) => item['type'] == _type).toList();
  }

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      _type = transaction['type']?.toString() ?? 'expense';
      _accountId = _asInt(transaction['account_id']);
      _categoryId = _asInt(transaction['category_id']);
      _amount.text = (transaction['amount'] ?? '').toString();
      _notes.text =
          (transaction['notes'] ?? transaction['description'] ?? '').toString();
      _dateValue =
          DateTime.tryParse(
            transaction['transaction_date']?.toString() ?? '',
          ) ??
          DateTime.now();
    } else {
      _accountId = _asInt(widget.accounts.firstOrNull?['id']);
    }
    final categories = _visibleCategories;
    _categoryId ??= _asInt(categories.firstOrNull?['id']);
  }

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final body = {
        'account_id': _accountId,
        'category_id': _categoryId,
        'type': _type,
        'amount': double.parse(_amount.text),
        'transaction_date': _date(_dateValue),
        'description': _notes.text.trim(),
        'notes': _notes.text.trim(),
      };
      if (_isEditing) {
        await widget.api.put(
          '/transactions/${widget.transaction!['id']}',
          body,
        );
      } else {
        await widget.api.post('/transactions', body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _visibleCategories;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'แก้ไขรายการเงิน' : 'เพิ่มรายการเงิน'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('รายจ่าย'),
                    icon: Icon(Icons.trending_down),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('รายรับ'),
                    icon: Icon(Icons.trending_up),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) {
                  setState(() {
                    _type = value.first;
                    final nextCategories = _visibleCategories;
                    _categoryId = _asInt(nextCategories.firstOrNull?['id']);
                  });
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: _accountId,
                decoration: const InputDecoration(labelText: 'บัญชี'),
                items:
                    widget.accounts
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: _asInt(item['id']),
                            child: Text(item['name'].toString()),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _accountId = value),
                validator: (value) => value == null ? 'เลือกบัญชี' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                items:
                    categories
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: _asInt(item['id']),
                            child: Text(item['name'].toString()),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
                validator: (value) => value == null ? 'เลือกหมวดหมู่' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amount,
                decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  return amount == null || amount <= 0
                      ? 'กรอกจำนวนเงินให้ถูกต้อง'
                      : null;
                },
              ),
              const SizedBox(height: 14),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.white,
                title: const Text('วันที่'),
                subtitle: Text(_date(_dateValue)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    initialDate: _dateValue,
                  );
                  if (picked != null) setState(() => _dateValue = picked);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(labelText: 'บันทึกเพิ่มเติม'),
                minLines: 3,
                maxLines: 4,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _saving ? null : _save,
                child:
                    _saving
                        ? const CircularProgressIndicator()
                        : Text(_isEditing ? 'บันทึกการแก้ไข' : 'บันทึกรายการ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountFormScreen extends StatefulWidget {
  const AccountFormScreen({super.key, required this.api, this.account});

  final ApiClient api;
  final Map<String, dynamic>? account;

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _currency = TextEditingController(text: 'THB');
  final _openingBalance = TextEditingController(text: '0');
  String _type = 'cash';
  bool _saving = false;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    if (account != null) {
      _name.text = account['name']?.toString() ?? '';
      _currency.text = account['currency']?.toString() ?? 'THB';
      _openingBalance.text = (account['opening_balance'] ?? 0).toString();
      _type = account['type']?.toString() ?? 'cash';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _currency.dispose();
    _openingBalance.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final body = {
        'name': _name.text.trim(),
        'type': _type,
        'currency': _currency.text.trim().toUpperCase(),
        'opening_balance': double.tryParse(_openingBalance.text) ?? 0,
      };
      if (_isEditing) {
        await widget.api.put('/accounts/${widget.account!['id']}', body);
      } else {
        await widget.api.post('/accounts', body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'แก้ไขบัญชี' : 'เพิ่มบัญชี')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'ชื่อบัญชี'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'กรอกชื่อบัญชี'
                            : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'ประเภทบัญชี'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('เงินสด')),
                  DropdownMenuItem(value: 'bank', child: Text('ธนาคาร')),
                  DropdownMenuItem(
                    value: 'credit_card',
                    child: Text('บัตรเครดิต'),
                  ),
                  DropdownMenuItem(value: 'wallet', child: Text('วอลเล็ต')),
                ],
                onChanged: (value) => setState(() => _type = value ?? 'cash'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _currency,
                decoration: const InputDecoration(labelText: 'สกุลเงิน'),
                textCapitalization: TextCapitalization.characters,
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'กรอกสกุลเงิน'
                            : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _openingBalance,
                decoration: const InputDecoration(labelText: 'ยอดเริ่มต้น'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _saving ? null : _save,
                child:
                    _saving
                        ? const CircularProgressIndicator()
                        : Text(_isEditing ? 'บันทึกการแก้ไข' : 'บันทึกบัญชี'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryFormScreen extends StatefulWidget {
  const CategoryFormScreen({super.key, required this.api, this.category});

  final ApiClient api;
  final Map<String, dynamic>? category;

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  String _type = 'expense';
  String _icon = 'receipt';
  Color _color = const Color(0xfff97316);
  bool _saving = false;

  final _colors = const [
    Color(0xfff97316),
    Color(0xffef4444),
    Color(0xff8b5cf6),
    Color(0xff3b82f6),
    Color(0xff0f766e),
    Color(0xff22c55e),
    Color(0xffeab308),
    Color(0xff64748b),
  ];

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    if (category != null) {
      _name.text = category['name']?.toString() ?? '';
      _type = category['type']?.toString() ?? 'expense';
      _icon = category['icon']?.toString() ?? 'receipt';
      _color = _parseColor(category['color']) ?? const Color(0xfff97316);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final body = {
        'name': _name.text.trim(),
        'type': _type,
        'icon': _icon,
        'color': _hexColor(_color),
      };
      if (_isEditing) {
        await widget.api.put('/categories/${widget.category!['id']}', body);
      } else {
        await widget.api.post('/categories', body);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'แก้ไขหมวดหมู่' : 'เพิ่มหมวดหมู่'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('รายจ่าย'),
                    icon: Icon(Icons.trending_down),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('รายรับ'),
                    icon: Icon(Icons.trending_up),
                  ),
                ],
                selected: {_type},
                onSelectionChanged:
                    (value) => setState(() => _type = value.first),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'ชื่อหมวดหมู่'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'กรอกชื่อหมวดหมู่'
                            : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _icon,
                decoration: const InputDecoration(labelText: 'ไอคอน'),
                items: const [
                  DropdownMenuItem(value: 'receipt', child: Text('ใบเสร็จ')),
                  DropdownMenuItem(value: 'utensils', child: Text('อาหาร')),
                  DropdownMenuItem(value: 'car', child: Text('เดินทาง')),
                  DropdownMenuItem(
                    value: 'shopping-bag',
                    child: Text('ช้อปปิ้ง'),
                  ),
                  DropdownMenuItem(value: 'heart-pulse', child: Text('สุขภาพ')),
                  DropdownMenuItem(value: 'book-open', child: Text('การศึกษา')),
                  DropdownMenuItem(value: 'home', child: Text('บ้าน')),
                  DropdownMenuItem(value: 'gift', child: Text('ของขวัญ')),
                  DropdownMenuItem(value: 'wallet', child: Text('กระเป๋าเงิน')),
                  DropdownMenuItem(value: 'sparkles', child: Text('พิเศษ')),
                  DropdownMenuItem(value: 'tags', child: Text('ป้ายกำกับ')),
                  DropdownMenuItem(value: 'target', child: Text('เป้าหมาย')),
                ],
                onChanged:
                    (value) => setState(() => _icon = value ?? 'receipt'),
              ),
              const SizedBox(height: 14),
              Text('สี', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    _colors
                        .map(
                          (color) => ChoiceChip(
                            label: const SizedBox.shrink(),
                            selected: color == _color,
                            avatar: CircleAvatar(backgroundColor: color),
                            onSelected: (_) => setState(() => _color = color),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _saving ? null : _save,
                child:
                    _saving
                        ? const CircularProgressIndicator()
                        : Text(
                          _isEditing ? 'บันทึกการแก้ไข' : 'บันทึกหมวดหมู่',
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardPage extends StatefulWidget {
  const _DashboardPage({
    required this.summary,
    required this.accounts,
    required this.categories,
    required this.transactions,
    required this.onShowTransactions,
    required this.onEditTransaction,
  });

  final Map<String, dynamic>? summary;
  final List<dynamic> accounts;
  final List<dynamic> categories;
  final List<dynamic> transactions;
  final VoidCallback onShowTransactions;
  final void Function(Map<String, dynamic> transaction) onEditTransaction;

  @override
  State<_DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<_DashboardPage> {
  String _type = 'expense';
  String _period = 'month';
  int? _accountId;
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    if (_accountId != null &&
        !widget.accounts.any(
          (account) =>
              _asInt((account as Map<String, dynamic>)['id']) == _accountId,
        )) {
      _accountId = null;
    }
    final range = _periodRange(_period, _customRange);
    final periodTransactions = _filterTransactions(
      widget.transactions,
      range,
      accountId: _accountId,
    );
    final breakdown = _breakdown(periodTransactions, widget.categories, _type);
    final total = breakdown.fold<double>(0, (sum, item) => sum + item.amount);
    final selectedTotal = _money(_sumTransactions(periodTransactions, _type));
    final periodLabel = _periodLabel(_period, range);
    final incomeTotal = _money(_sumTransactions(periodTransactions, 'income'));
    final expenseTotal = _money(
      _sumTransactions(periodTransactions, 'expense'),
    );
    final balance = _money(_selectedBalance(widget.accounts, _accountId));
    final recentTransactions =
        periodTransactions.cast<Map<String, dynamic>>().take(4).toList();
    final showLegacyDashboardSections = DateTime.now().year < 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
      children: [
        const _DashboardTopBar(),
        const SizedBox(height: 28),
        Text(
          'ภาพรวม',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 390;
            final accountCard = _AccountPickerCard(
              accounts: widget.accounts,
              selectedId: _accountId,
              onChanged: (value) => setState(() => _accountId = value),
            );
            final rangeCard = _RangePickerCard(
              label: _periodLabel(_period, range),
              onTap: () async {
                final initialRange =
                    _customRange ?? _periodRange(_period, null);
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  initialDateRange: initialRange,
                );
                if (picked == null) return;
                setState(() {
                  _customRange = picked;
                  _period = 'range';
                });
              },
            );
            if (compact) {
              return Column(
                children: [accountCard, const SizedBox(height: 12), rangeCard],
              );
            }
            return Row(
              children: [
                Expanded(child: accountCard),
                const SizedBox(width: 14),
                Expanded(child: rangeCard),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        _QuickPeriodChips(
          selected: _period,
          onSelected: (key) async {
            if (key == 'range') {
              final initialRange = _customRange ?? _periodRange(_period, null);
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                initialDateRange: initialRange,
              );
              if (picked == null) return;
              setState(() {
                _customRange = picked;
                _period = key;
              });
              return;
            }
            setState(() => _period = key);
          },
        ),
        const SizedBox(height: 22),
        _SummaryHero(net: balance, income: incomeTotal, expense: expenseTotal),
        if (showLegacyDashboardSections) ...[
          const SizedBox(height: 14),
          _AccountFilter(
            accounts: widget.accounts,
            selectedId: _accountId,
            onChanged: (value) => setState(() => _accountId = value),
          ),
          const SizedBox(height: 14),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'expense',
                label: Text('ค่าใช้จ่าย'),
                icon: Icon(Icons.trending_down),
              ),
              ButtonSegment(
                value: 'income',
                label: Text('รายรับ'),
                icon: Icon(Icons.trending_up),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (value) => setState(() => _type = value.first),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  ['day', 'week', 'month', 'year', 'range'].map((key) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_periodChipLabel(key, _customRange)),
                        selected: _period == key,
                        onSelected: (_) async {
                          if (key == 'range') {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                              initialDateRange: _customRange,
                            );
                            if (picked == null) return;
                            setState(() {
                              _customRange = picked;
                              _period = key;
                            });
                            return;
                          }
                          setState(() => _period = key);
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 18),
        ],
        const SizedBox(height: 22),
        _DonutPanel(
          title:
              _type == 'expense'
                  ? 'ค่าใช้จ่าย$periodLabel'
                  : 'รายรับ$periodLabel',
          amount: selectedTotal,
          emptyText:
              _type == 'expense'
                  ? 'ยังไม่มีค่าใช้จ่ายในช่วงนี้'
                  : 'ยังไม่มีรายรับในช่วงนี้',
          slices:
              breakdown
                  .map((item) => DonutSlice(item.color, item.amount))
                  .toList(),
          items: breakdown,
          total: total,
        ),
        const SizedBox(height: 22),
        _RecentTransactionsCard(
          transactions: recentTransactions,
          onShowAll: widget.onShowTransactions,
          onEdit: widget.onEditTransaction,
        ),
        if (showLegacyDashboardSections) ...[
          const SizedBox(height: 14),
          if (breakdown.isEmpty)
            const _EmptyState(
              icon: Icons.pie_chart,
              text: 'ยังไม่มีข้อมูลหมวดหมู่',
            )
          else
            ...breakdown.map(
              (item) => _BreakdownTile(item: item, total: total),
            ),
          const SizedBox(height: 18),
          Text(
            'บัญชีของฉัน',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...widget.accounts.take(3).map((item) => _AccountTile(account: item)),
        ],
      ],
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.purple, Color(0xff4f6fff)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: .24),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'F',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FinNote',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'บันทึกรายรับรายจ่าย',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _CircleButton(icon: Icons.notifications_none_rounded, onTap: () {}),
            Positioned(
              right: 10,
              top: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountPickerCard extends StatelessWidget {
  const _AccountPickerCard({
    required this.accounts,
    required this.selectedId,
    required this.onChanged,
  });

  final List<dynamic> accounts;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: _softDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'บัญชี',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: selectedId,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: _PickerLabel(
                    icon: Icons.account_balance_wallet_rounded,
                    text: 'ทุกบัญชี',
                  ),
                ),
                ...accounts.cast<Map<String, dynamic>>().map(
                  (account) => DropdownMenuItem<int?>(
                    value: _asInt(account['id']),
                    child: _PickerLabel(
                      icon: Icons.account_balance_wallet_rounded,
                      text: (account['name'] ?? 'บัญชี').toString(),
                    ),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangePickerCard extends StatelessWidget {
  const _RangePickerCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 112,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: _softDecoration(radius: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ช่วงเวลา',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.ink,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerLabel extends StatelessWidget {
  const _PickerLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.purple, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickPeriodChips extends StatelessWidget {
  const _QuickPeriodChips({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const options = [
      ('day', 'วันนี้'),
      ('week', '7 วัน'),
      ('month', '30 วัน'),
      ('quarter', '3 เดือน'),
      ('range', 'กำหนดเอง'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            options.map((option) {
              final isSelected = selected == option.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(option.$2),
                  selected: isSelected,
                  showCheckmark: false,
                  selectedColor: AppColors.purple,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color:
                        isSelected
                            ? AppColors.purple
                            : AppColors.line.withValues(alpha: .9),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  onSelected: (_) => onSelected(option.$1),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({
    required this.transactions,
    required this.onShowAll,
    required this.onEdit,
  });

  final List<Map<String, dynamic>> transactions;
  final VoidCallback onShowAll;
  final ValueChanged<Map<String, dynamic>> onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: _softDecoration(radius: 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'รายการล่าสุด',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              TextButton(
                onPressed: onShowAll,
                child: const Text(
                  'ดูทั้งหมด',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: _EmptyState(
                icon: Icons.receipt_long,
                text: 'ยังไม่มีรายการในช่วงนี้',
              ),
            )
          else
            ...transactions.map(
              (item) => _RecentTransactionRow(
                transaction: item,
                onTap: () => onEdit(item),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentTransactionRow extends StatelessWidget {
  const _RecentTransactionRow({required this.transaction, required this.onTap});

  final Map<String, dynamic> transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction['type'] == 'income';
    final color = isIncome ? AppColors.green : AppColors.red;
    final bgColor = color.withValues(alpha: .14);
    final category =
        (transaction['category_name'] ?? 'ไม่ระบุหมวดหมู่').toString();
    final detail =
        (transaction['notes'] ?? transaction['description'] ?? 'แตะเพื่อแก้ไข')
            .toString();

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: bgColor,
              foregroundColor: color,
              child: Icon(
                isIncome
                    ? Icons.shopping_bag_rounded
                    : _categoryIcon(transaction['category_icon']?.toString()),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}฿ ${_money(transaction['amount'])}',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTransactionDate(transaction['transaction_date']),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.ink),
          ],
        ),
      ),
    );
  }
}

class _AccountFilter extends StatelessWidget {
  const _AccountFilter({
    required this.accounts,
    required this.selectedId,
    required this.onChanged,
  });

  final List<dynamic> accounts;
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: _softDecoration(radius: 20),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('ทุกบัญชี')),
            ...accounts.cast<Map<String, dynamic>>().map(
              (account) => DropdownMenuItem<int?>(
                value: _asInt(account['id']),
                child: Text(account['name']?.toString() ?? '-'),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({
    required this.net,
    required this.income,
    required this.expense,
  });

  final String net;
  final String income;
  final String expense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue, AppColors.purple],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: .26),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ยอดเงินคงเหลือ',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              Container(
                width: 78,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'รวมบัญชีที่เลือก',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            '฿$net',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroPill(
                  label: 'รายรับ',
                  value: income,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroPill(
                  label: 'รายจ่าย',
                  value: expense,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '฿$value',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPanel extends StatelessWidget {
  const _DonutPanel({
    required this.title,
    required this.amount,
    required this.emptyText,
    required this.slices,
    required this.items,
    required this.total,
  });

  final String title;
  final String amount;
  final String emptyText;
  final List<DonutSlice> slices;
  final List<_BreakdownItem> items;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _softDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.pie_chart_outline),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size.square(220),
                    painter: _DonutPainter(slices),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slices.isEmpty ? emptyText : '฿$amount',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (slices.isNotEmpty)
                        const Text(
                          'รวมตามหมวดหมู่',
                          style: TextStyle(color: Colors.black54),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...items
                  .take(6)
                  .map(
                    (item) => _CompactBreakdownRow(item: item, total: total),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompactBreakdownRow extends StatelessWidget {
  const _CompactBreakdownRow({required this.item, required this.total});

  final _BreakdownItem item;
  final double total;

  @override
  Widget build(BuildContext context) {
    final percent = total <= 0 ? 0 : (item.amount / total * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '฿ ${_money(item.amount)}',
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 38,
            child: Text(
              '$percent%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DonutSlice {
  const DonutSlice(this.color, this.value);

  final Color color;
  final double value;
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter(this.slices);

  final List<DonutSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 34
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xffe7e5e4);

    canvas.drawCircle(center, radius - 17, track);
    if (slices.isEmpty) return;

    final total = slices.fold<double>(0, (sum, item) => sum + item.value);
    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * math.pi * 2;
      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 34
            ..strokeCap = StrokeCap.round
            ..color = slice.color;
      canvas.drawArc(rect.deflate(17), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class _BreakdownItem {
  const _BreakdownItem({
    required this.name,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String name;
  final double amount;
  final Color color;
  final IconData icon;
}

class _BreakdownTile extends StatelessWidget {
  const _BreakdownTile({required this.item, required this.total});

  final _BreakdownItem item;
  final double total;

  @override
  Widget build(BuildContext context) {
    final percent = total <= 0 ? 0 : (item.amount / total * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: _softDecoration(radius: 22),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: item.color.withValues(alpha: .16),
            foregroundColor: item.color,
            child: Icon(item.icon),
          ),
          title: Text(item.name),
          subtitle: LinearProgressIndicator(
            value: total <= 0 ? 0 : item.amount / total,
            color: item.color,
            backgroundColor: item.color.withValues(alpha: .12),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$percent%'),
              Text(
                '฿${_money(item.amount)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionsPage extends StatelessWidget {
  const _TransactionsPage({
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  final List<dynamic> transactions;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long,
        text: 'ยังไม่มีรายการในเดือนนี้',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = transactions[index] as Map<String, dynamic>;
        final isIncome = item['type'] == 'income';
        return Container(
          decoration: _softDecoration(radius: 22),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isIncome ? const Color(0xffdcfce7) : const Color(0xffffe4e6),
              foregroundColor:
                  isIncome ? const Color(0xff15803d) : const Color(0xffbe123c),
              child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward),
            ),
            title: Text(item['category_name']?.toString() ?? '-'),
            subtitle: Text(
              '${item['transaction_date']} • ${item['notes'] ?? item['description'] ?? ''}',
            ),
            onTap: () => onEdit(item),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${_money(item['amount'])}',
                  style: TextStyle(
                    color:
                        isIncome
                            ? const Color(0xff15803d)
                            : const Color(0xffbe123c),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  tooltip: 'แก้ไข',
                  onPressed: () => onEdit(item),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'ลบ',
                  onPressed: () => onDelete(_asInt(item['id'])!),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccountsPage extends StatelessWidget {
  const _AccountsPage({
    required this.accounts,
    required this.onEdit,
    required this.onDelete,
  });

  final List<dynamic> accounts;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const _EmptyState(
        icon: Icons.account_balance_wallet,
        text: 'ยังไม่มีบัญชี',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
      itemCount: accounts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder:
          (context, index) => _AccountTile(
            account: accounts[index],
            onEdit: onEdit,
            onDelete: onDelete,
          ),
    );
  }
}

class _CategoriesPage extends StatelessWidget {
  const _CategoriesPage({
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  final List<dynamic> categories;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const _EmptyState(icon: Icons.category, text: 'ยังไม่มีหมวดหมู่');
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = categories[index] as Map<String, dynamic>;
        final isIncome = item['type'] == 'income';
        final color = _parseColor(item['color']) ?? const Color(0xfff97316);
        return Container(
          decoration: _softDecoration(radius: 22),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: .14),
              foregroundColor: color,
              child: Icon(isIncome ? Icons.trending_up : Icons.sell),
            ),
            title: Text(item['name'].toString()),
            subtitle: Text(isIncome ? 'รายรับ' : 'รายจ่าย'),
            onTap: () => onEdit(item),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'แก้ไข',
                  onPressed: () => onEdit(item),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'ลบ',
                  onPressed: () => onDelete(_asInt(item['id'])!),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, this.onEdit, this.onDelete});

  final dynamic account;
  final ValueChanged<Map<String, dynamic>>? onEdit;
  final ValueChanged<int>? onDelete;

  @override
  Widget build(BuildContext context) {
    final item = account as Map<String, dynamic>;
    return Container(
      decoration: _softDecoration(radius: 22),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.account_balance_wallet)),
        title: Text(item['name'].toString()),
        subtitle: Text(item['currency']?.toString() ?? 'THB'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _money(item['current_balance']),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (onEdit != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'แก้ไข',
                onPressed: () => onEdit!(item),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
            if (onDelete != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'ลบ',
                onPressed: () => onDelete!(_asInt(item['id'])!),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ],
        ),
        onTap: onEdit == null ? null : () => onEdit!(item),
        onLongPress:
            onDelete == null ? null : () => onDelete!(_asInt(item['id'])!),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.register});

  final bool register;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue, AppColors.purple],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: .22),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MyMoney',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  register
                      ? 'เริ่มจัดการเงินแบบเป็นระบบ'
                      : 'กลับมาดูแลเงินของคุณ',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 90),
        Icon(icon, size: 54, color: Colors.black26),
        const SizedBox(height: 12),
        Center(
          child: Text(text, style: const TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 52, color: Colors.black38),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('ลองใหม่')),
          ],
        ),
      ),
    );
  }
}

List<_BreakdownItem> _breakdown(
  List<dynamic> transactions,
  List<dynamic> categories,
  String type,
) {
  final byId = {
    for (final category in categories.cast<Map<String, dynamic>>())
      _asInt(category['id']): category,
  };
  final totals = <int, double>{};
  for (final transaction in transactions.cast<Map<String, dynamic>>()) {
    if (transaction['type'] != type) continue;
    final categoryId = _asInt(transaction['category_id']);
    if (categoryId == null) continue;
    totals[categoryId] =
        (totals[categoryId] ?? 0) +
        (double.tryParse((transaction['amount'] ?? 0).toString()) ?? 0);
  }

  final items =
      totals.entries.map((entry) {
        final category = byId[entry.key];
        final color =
            _parseColor(category?['color']) ??
            (type == 'income'
                ? const Color(0xff15803d)
                : const Color(0xfff97316));
        return _BreakdownItem(
          name:
              category?['name']?.toString() ??
              (type == 'income' ? 'รายรับอื่น ๆ' : 'รายจ่ายอื่น ๆ'),
          amount: entry.value,
          color: color,
          icon: _categoryIcon(category?['icon']?.toString()),
        );
      }).toList();
  items.sort((a, b) => b.amount.compareTo(a.amount));
  return items;
}

List<dynamic> _filterTransactions(
  List<dynamic> transactions,
  DateTimeRange range, {
  int? accountId,
}) {
  final toExclusive = range.end.add(const Duration(days: 1));
  return transactions.where((item) {
    final map = item as Map<String, dynamic>;
    final date = DateTime.tryParse(map['transaction_date']?.toString() ?? '');
    if (date == null) return false;
    final inRange = !date.isBefore(range.start) && date.isBefore(toExclusive);
    if (!inRange) return false;
    if (accountId == null) return true;
    return _asInt(map['account_id']) == accountId ||
        _asInt(map['to_account_id']) == accountId;
  }).toList();
}

DateTimeRange _periodRange(String period, DateTimeRange? customRange) {
  final now = DateTime.now();
  DateTime from;
  DateTime to;
  switch (period) {
    case 'day':
      from = DateTime(now.year, now.month, now.day);
      to = from;
      break;
    case 'week':
      to = DateTime(now.year, now.month, now.day);
      from = to.subtract(const Duration(days: 6));
      break;
    case 'quarter':
      to = DateTime(now.year, now.month, now.day);
      from = DateTime(now.year, now.month - 2, now.day);
      break;
    case 'year':
      from = DateTime(now.year, 1, 1);
      to = DateTime(now.year, 12, 31);
      break;
    case 'range':
      if (customRange != null) return customRange;
      from = DateTime(now.year, now.month, 1);
      to = DateTime(now.year, now.month + 1, 0);
      break;
    case 'month':
    default:
      to = DateTime(now.year, now.month, now.day);
      from = to.subtract(const Duration(days: 29));
      break;
  }
  return DateTimeRange(start: from, end: to);
}

double _sumTransactions(List<dynamic> transactions, String type) {
  return transactions.cast<Map<String, dynamic>>().fold<double>(0, (sum, item) {
    if (item['type'] != type) return sum;
    return sum + (double.tryParse((item['amount'] ?? 0).toString()) ?? 0);
  });
}

String _periodLabel(String period, DateTimeRange range) {
  return switch (period) {
    'day' => _thaiShortDate(range.start),
    'week' => '${_thaiShortDate(range.start)} - ${_thaiShortDate(range.end)}',
    'quarter' =>
      '${_thaiShortDate(range.start)} - ${_thaiShortDate(range.end)}',
    'year' => '${range.start.year + 543}',
    'range' => '${_thaiShortDate(range.start)} - ${_thaiShortDate(range.end)}',
    _ => _thaiMonthYear(range.start),
  };
}

String _periodChipLabel(String period, DateTimeRange? customRange) {
  final range = _periodRange(period, customRange);
  return switch (period) {
    'day' => 'วัน ${_thaiShortDate(range.start)}',
    'week' =>
      'สัปดาห์ ${_thaiShortDate(range.start)} - ${_thaiShortDate(range.end)}',
    'year' => 'ปี ${range.start.year + 543}',
    'range' =>
      'ช่วงเวลา ${_thaiShortDate(range.start)} - ${_thaiShortDate(range.end)}',
    _ => 'เดือน ${_thaiMonthYear(range.start)}',
  };
}

double _selectedBalance(List<dynamic> accounts, int? accountId) {
  return accounts.cast<Map<String, dynamic>>().fold<double>(0, (sum, account) {
    if (accountId != null && _asInt(account['id']) != accountId) return sum;
    return sum +
        (double.tryParse((account['current_balance'] ?? 0).toString()) ?? 0);
  });
}

IconData _categoryIcon(String? icon) {
  return switch (icon) {
    'utensils' => Icons.restaurant,
    'car' => Icons.directions_car,
    'shopping-bag' => Icons.shopping_bag,
    'heart-pulse' => Icons.favorite,
    'book-open' => Icons.menu_book,
    'home' => Icons.home,
    'gift' => Icons.card_giftcard,
    'wallet' => Icons.account_balance_wallet,
    'sparkles' => Icons.auto_awesome,
    'tags' => Icons.sell,
    'target' => Icons.track_changes,
    _ => Icons.receipt_long,
  };
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

String _date(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _thaiShortDate(DateTime value) {
  const months = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];
  return '${value.day} ${months[value.month - 1]}';
}

String _thaiMonthYear(DateTime value) {
  const months = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];
  return '${months[value.month - 1]} ${value.year + 543}';
}

String _formatTransactionDate(dynamic value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return '';
  final parsed = DateTime.tryParse(text);
  if (parsed == null) return text;
  return _thaiShortDate(parsed);
}

String _money(dynamic value) {
  final amount = double.tryParse((value ?? 0).toString()) ?? 0;
  return amount.toStringAsFixed(2);
}

BoxDecoration _softDecoration({double radius = 28}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withValues(alpha: .7)),
    boxShadow: [
      BoxShadow(
        color: AppColors.blue.withValues(alpha: .07),
        blurRadius: 30,
        offset: const Offset(0, 14),
      ),
    ],
  );
}

Color? _parseColor(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().replaceFirst('#', '');
  final parsed = int.tryParse('ff$raw', radix: 16);
  return parsed == null ? null : Color(parsed);
}

String _hexColor(Color color) {
  final value = color.toARGB32().toRadixString(16).padLeft(8, '0');
  return '#${value.substring(2)}';
}
