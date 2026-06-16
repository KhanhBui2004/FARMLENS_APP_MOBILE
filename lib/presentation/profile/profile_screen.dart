import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:farmlens_app/data/models/auth/user_model.dart';
import 'package:farmlens_app/data/services/auth/auth_service.dart';
import 'package:farmlens_app/presentation/widgets/header.dart';
import 'package:farmlens_app/presentation/widgets/textInput_widget.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmlens_app/presentation/widgets/buttonCustom_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void showAwesomeSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required ContentType type,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 3),
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: type,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'Home':
        Navigator.of(context).pushNamed(AppRoutes.home);
        break;
      case 'Logout':
        _authService.logout();
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        showAwesomeSnackBar(
          context: context,
          title: 'Thành công',
          message: 'Đăng xuất thành công!',
          type: ContentType.success,
        );
        break;
      case 'History':
        Navigator.of(context).pushNamed(AppRoutes.history);
        break;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      debugPrint('Loaded user JSON: $userJson');
      if (userJson != null) {
        final loadedUser = User.fromJson(jsonDecode(userJson));
        debugPrint(
          'Parsed user: ${loadedUser.username}, ${loadedUser.email}, ${loadedUser.fullName}',
        );

        if (!mounted) return;
        setState(() {
          _fullNameController.text = loadedUser.fullName;
          _usernameController.text = loadedUser.username;
          _emailController.text = loadedUser.email;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final result = await _authService.updateProfile(
          fullName: _fullNameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _newPasswordController.text.trim().isEmpty
              ? null
              : _newPasswordController.text.trim(),
        );

        if (!mounted) return;

        if (result['code'] == 200) {
          showAwesomeSnackBar(
            context: context,
            title: 'Thành công',
            message: 'Cập nhật hồ sơ thành công!',
            type: ContentType.success,
          );

          await _loadUserData();

          if (!mounted) return;

          setState(() {});
        } else {
          showAwesomeSnackBar(
            context: context,
            title: 'Lỗi',
            message: result['message'] ?? 'Cập nhật hồ sơ thất bại.',
            type: ContentType.failure,
          );
        }
      } catch (e) {
        if (!mounted) return;

        showAwesomeSnackBar(
          context: context,
          title: 'Lỗi',
          message: 'Đã xảy ra lỗi không mong muốn',
          type: ContentType.failure,
        );
        debugPrint('Error updating profile: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF6FBF5),
                    Color(0xFFEAF4EA),
                    Color(0xFFFDFEFE),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -60,
              right: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF3F8E5A).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -70,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: HomeHeader(
                          onMenuSelected: _handleMenuAction,
                          title: 'Hồ sơ FarmLens',
                          subtitle:
                              'Theo dõi vệ tinh, phân đoạn U-Net và phân tích cây trồng',
                        ),
                      ),
                      const SizedBox(height: 18),
                      Icon(Icons.person, size: 50, color: colorScheme.primary),
                      Text(
                        'Cài đặt hồ sơ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Họ và tên',
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        controller: _fullNameController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Họ và tên là bắt buộc';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Tên đăng nhập',
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tên đăng nhập là bắt buộc';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Email',
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email là bắt buộc';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Mật khẩu mới',
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        controller: _newPasswordController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Xác nhận mật khẩu mới',
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        controller: _confirmPasswordController,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value != _newPasswordController.text) {
                            return 'Mật khẩu xác nhận không khớp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ButtonCustomWidget(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          _updateProfile();
                        },
                        text: 'Lưu thay đổi',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
