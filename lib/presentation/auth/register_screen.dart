import 'package:flutter/material.dart';
import 'package:farmlens_app/presentation/widget/buttonCustom_widget.dart';
import 'package:farmlens_app/presentation/widget/textInput_widget.dart';
import 'package:farmlens_app/presentation/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    form.save();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Registering...')));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      //   appBar: AppBar(
      //     title: const Text('Create account'),
      //     backgroundColor: colorScheme.inversePrimary,
      //   ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 166, 49, 49),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Create your account to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 204, 124, 124),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // TextFormField(
                //   textInputAction: TextInputAction.next,
                //   decoration: const InputDecoration(
                //     labelText: 'Full name',
                //     prefixIcon: Icon(Icons.badge_outlined),
                //     border: OutlineInputBorder(),
                //   ),
                //   validator: (value) {
                //     if (value == null || value.trim().isEmpty) {
                //       return 'Please enter your name';
                //     }
                //     return null;
                //   },
                // ),
                TextInputWidget(
                  hintText: 'Full name',
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  controller: _fullNameController,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                TextInputWidget(
                  hintText: 'Confirm password',
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  controller: _confirmPasswordController,
                ),

                // TextFormField(
                //   textInputAction: TextInputAction.next,
                //   keyboardType: TextInputType.emailAddress,
                //   decoration: const InputDecoration(
                //     labelText: 'Email',
                //     prefixIcon: Icon(Icons.email_outlined),
                //     border: OutlineInputBorder(),
                //   ),
                //   validator: (value) {
                //     if (value == null || value.trim().isEmpty) {
                //       return 'Please enter your email';
                //     }
                //     final email = value.trim();
                //     if (!email.contains('@') || !email.contains('.')) {
                //       return 'Please enter a valid email';
                //     }
                //     return null;
                //   },
                // ),
                const SizedBox(height: 16),
                // TextFormField(
                //   controller: _passwordController,
                //   textInputAction: TextInputAction.next,
                //   obscureText: _obscurePassword,
                //   decoration: InputDecoration(
                //     labelText: 'Password',
                //     prefixIcon: const Icon(Icons.lock_outline),
                //     border: const OutlineInputBorder(),
                //     suffixIcon: IconButton(
                //       onPressed: () {
                //         setState(() {
                //           _obscurePassword = !_obscurePassword;
                //         });
                //       },
                //       icon: Icon(
                //         _obscurePassword
                //             ? Icons.visibility_outlined
                //             : Icons.visibility_off_outlined,
                //       ),
                //     ),
                //   ),
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please enter a password';
                //     }
                //     if (value.length < 6) {
                //       return 'Password must be at least 6 characters';
                //     }
                //     return null;
                //   },
                // ),
                const SizedBox(height: 16),
                // TextFormField(
                //   textInputAction: TextInputAction.done,
                //   obscureText: _obscureConfirmPassword,
                //   decoration: InputDecoration(
                //     labelText: 'Confirm password',
                //     prefixIcon: const Icon(Icons.lock_outline),
                //     border: const OutlineInputBorder(),
                //     suffixIcon: IconButton(
                //       onPressed: () {
                //         setState(() {
                //           _obscureConfirmPassword = !_obscureConfirmPassword;
                //         });
                //       },
                //       icon: Icon(
                //         _obscureConfirmPassword
                //             ? Icons.visibility_outlined
                //             : Icons.visibility_off_outlined,
                //       ),
                //     ),
                //   ),
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please confirm your password';
                //     }
                //     if (value != _passwordController.text) {
                //       return 'Passwords do not match';
                //     }
                //     return null;
                //   },
                // ),
                const SizedBox(height: 24),
                // ElevatedButton(
                //   onPressed: _submit,
                //   style: ElevatedButton.styleFrom(
                //     padding: const EdgeInsets.symmetric(vertical: 14),
                //   ),
                //   child: const Text('Register'),
                // ),
                // const SizedBox(height: 12),
                ButtonCustomWidget(text: 'Register', onPressed: _submit),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ),
                  child: const Text('Already have an account? Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
