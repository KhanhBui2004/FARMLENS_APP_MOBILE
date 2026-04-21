import 'package:flutter/material.dart';
import 'package:farmlens_app/presentation/auth/register_screen.dart';
import 'package:farmlens_app/presentation/widget/buttonCustom_widget.dart';
import 'package:farmlens_app/presentation/widget/textInput_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    form.save();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logging in...')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Login Here',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Welcome back! Please login to your account.',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                // Icon(Icons.login, size: 64, color: colorScheme.primary),
                const SizedBox(height: 12),
                TextInputWidget(
                  hintText: 'Email',
                  obscureText: false,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                TextInputWidget(
                  hintText: 'Password',
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  controller: _passwordController,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _submit,
                  child: const ButtonCustomWidget(text: 'Login'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Register',
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
    );
  }
}
