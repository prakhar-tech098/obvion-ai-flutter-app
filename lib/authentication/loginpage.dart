import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// --- IMPORTANT: Adjust these import paths to match your project structure ---
import '../core/api/auth_provider.dart';
import 'SignUp.dart';


import 'forgot_password.dart';
// This should point to the file containing your AppGradients class
import '../../core/theme/app_color.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers and local UI state are kept here
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // A helper to determine if the login button should be enabled
  bool get isFilled =>
      emailController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty;

  // A helper to check if the keyboard is visible for animations
  bool get isKeyboardVisible =>
      MediaQuery.of(context).viewInsets.bottom != 0;

  // This method calls the login logic from the provider
  void _login() {
    // Hide the keyboard
    FocusScope.of(context).unfocus();
    // Use context.read inside a function/callback
    context.read<AuthProvider>().login(
      emailController.text,
      passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use context.watch to listen for state changes from the provider
    final authProvider = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Replaced the solid color with your reusable dark gradient
          Container(
            decoration: AppGradients.darkGradient,
          ),

          // Background Logo Image with smooth animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: isKeyboardVisible ? 30 : size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/logo.jpg', // Your image path
                width: size.width * 0.5,
              ),
            ),
          ),

          // Bottom White Container with Inputs
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.65,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Welcome Back!",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      "Login to your account",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 28),

                    // Email Field
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgotPasswordPage()),
                          );
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),

                    // 2. Display error message from the provider
                    if (authProvider.errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Center(
                        child: Text(
                          authProvider.errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),

                    // Login Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading || !isFilled ? null : _login,
                        style: ElevatedButton.styleFrom(
                          // 1. Make the button's own background transparent
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero, // Remove padding from the button itself
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Ink(
                          // 2. Apply the decoration to an Ink widget for splash effects
                          decoration: BoxDecoration(
                            // Use the gradient when the button is active
                            gradient: isFilled ? AppGradients.darkGradient.gradient : null,
                            // Use a solid grey color when disabled
                            color: isFilled ? null : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Container(
                            // 3. This container holds the content and defines the button's size
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            child: authProvider.isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                                : Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                // 4. Set the text color based on the button's state
                                color: isFilled ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                     Center(
                      child: Text("OR", style: TextStyle(color: Colors.grey[900])),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?",
                            style: TextStyle(color: Colors.black54)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpPage()),
                            );
                          },
                          child: const Text("Sign Up",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


