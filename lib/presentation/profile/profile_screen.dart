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
          title: 'Success',
          message: 'Logged out successfully!',
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
                          title: 'FarmLens Dashboard',
                          subtitle:
                              'Satellite monitoring, U-Net segmentation and crop analytics',
                        ),
                      ),
                      const SizedBox(height: 18),
                      Icon(Icons.person, size: 50, color: colorScheme.primary),
                      Text(
                        'Profile Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Full name',
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        controller: _fullNameController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Username',
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username is required';
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
                            return 'Email is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'New password',
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        controller: _newPasswordController,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextInputWidget(
                        hintText: 'Re-enter new password',
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        controller: _confirmPasswordController,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ButtonCustomWidget(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                        },
                        text: 'Save Changes',
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
