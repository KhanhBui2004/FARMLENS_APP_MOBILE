import 'package:farmlens_app/data/services/auth/auth_service.dart';
import 'package:farmlens_app/utils/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:farmlens_app/presentation/widgets/buttonCustom_widget.dart';
import 'package:farmlens_app/presentation/widgets/textInput_widget.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class LoginScreen extends StatefulWidget {
  final AuthService? authService;

  const LoginScreen({super.key, this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthService authService;
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  String loadingMessage = 'Đang xử lý...';

  @override
  void initState() {
    super.initState();
    authService = widget.authService ?? AuthService();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
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

  Future<void> _submit() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      FocusManager.instance.primaryFocus?.unfocus();
      _showLoading('Đang đăng nhập...');

      final result = await authService.login(
        _identifierController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result['code'] == 200) {
        debugPrint('Sign in successful!');

        showAwesomeSnackBar(
          context: context,
          title: 'Thành công',
          message: 'Đăng nhập thành công!',
          type: ContentType.success,
        );

        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        // Navigate to home screen or dashboard
      } else {
        debugPrint('Sign in failed: ${result['message']}');
        showAwesomeSnackBar(
          context: context,
          title: 'Lỗi',
          message: 'Tên người dùng hoặc mật khẩu không đúng',
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
                      Icon(Icons.person, size: 64, color: colorScheme.primary),
                      Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Chào mừng trở lại! Vui lòng đăng nhập vào tài khoản của bạn.',
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextInputWidget(
                        hintText: 'Tên đăng nhập hoặc email',
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        controller: _identifierController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tên đăng nhập hoặc email là bắt buộc';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Mật khẩu',
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mật khẩu là bắt buộc';
                          }
                          return null;
                        },
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password logic
                          },
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ButtonCustomWidget(text: 'Đăng nhập', onPressed: _submit),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Chưa có tài khoản?"),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed(AppRoutes.register);
                            },
                            child: Text(
                              'Đăng ký',
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
                          fontWeight: FontWeight.w600,
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
