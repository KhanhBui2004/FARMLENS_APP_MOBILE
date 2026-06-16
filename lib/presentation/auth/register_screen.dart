import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:farmlens_app/data/services/auth/auth_service.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:farmlens_app/presentation/widgets/buttonCustom_widget.dart';
import 'package:farmlens_app/presentation/widgets/textInput_widget.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService? authService;

  const RegisterScreen({super.key, this.authService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  bool isLoading = false;
  String loadingMessage = 'Đang xử lý...';

  late final AuthService authService;

  @override
  void initState() {
    super.initState();
    authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showLoading(String message) {
    setState(() {
      isLoading = true;
      loadingMessage = message;
    });
  }

  void _hideLoading() {
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
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

  Future<void> _submit() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      FocusManager.instance.primaryFocus?.unfocus();

      _showLoading('Đang tạo tài khoản...');
      final response = await authService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _fullNameController.text.trim(),
      );

      if (!mounted) return;

      if (response['code'] == 200) {
        showAwesomeSnackBar(
          context: context,
          title: 'Thành công',
          message: 'Đăng ký thành công!',
          type: ContentType.success,
        );
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      } else {
        showAwesomeSnackBar(
          context: context,
          title: 'Lỗi',
          message: response['message'] ?? 'Đăng ký thất bại',
          type: ContentType.failure,
        );
      }
    } catch (e) {
      showAwesomeSnackBar(
        context: context,
        title: 'Lỗi',
        message: e.toString(),
        type: ContentType.failure,
      );
      return;
    } finally {
      _hideLoading();
    }
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 35,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Icon(
                        Icons.person_add_alt_1,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tạo Tài Khoản',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tạo tài khoản của bạn để tiếp tục',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextInputWidget(
                        hintText: 'Họ và tên',
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Họ và tên là bắt buộc';
                          }
                          return null;
                        },
                        controller: _fullNameController,
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Email',
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email là bắt buộc';
                          }
                          return null;
                        },
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Tên đăng nhập',
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tên đăng nhập là bắt buộc';
                          }
                          return null;
                        },
                        controller: _usernameController,
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Mật khẩu',
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mật khẩu là bắt buộc';
                          }
                          return null;
                        },
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Xác nhận mật khẩu',
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu';
                          }
                          if (value != _passwordController.text) {
                            return 'Mật khẩu không khớp';
                          }
                          return null;
                        },
                        controller: _confirmPasswordController,
                      ),
                      const SizedBox(height: 24),
                      ButtonCustomWidget(text: 'Đăng ký', onPressed: _submit),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Đã có tài khoản?"),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed(AppRoutes.login);
                            },
                            child: Text(
                              'Đăng nhập',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        loadingMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
