import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api/auth_provider.dart';
import '../presentation/screens/home_screen.dart';
import 'SignUp.dart';
import 'forgot_password.dart';
import '../../core/theme/app_color.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.decelerate,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool get isFilled =>
      emailController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty;

  bool get isKeyboardVisible => MediaQuery.of(context).viewInsets.bottom != 0;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final authProvider = context.read<AuthProvider>();

    bool success = await authProvider.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
    // On failure, your LoginPage UI already shows errorMessage from provider.
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(decoration: AppGradients.darkGradient),

          // Logo
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: isKeyboardVisible ? 20 : size.height * 0.13,
            left: 0,
            right: 0,
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.cyanAccent],
                ).createShader(bounds),
                child: Hero(
                  tag: 'appLogo',
                  child: Image.asset(
                    'assets/mylog.png',
                    width: size.width * 0.42,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Login form panel
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isKeyboardVisible ? size.height * 0.6 : size.height * 0.7,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1D), // dark panel
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Welcome Back 👋",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 6),
                      const Text("Login to your account",
                          style: TextStyle(color: Colors.grey)),

                      const SizedBox(height: 28),

                      // Email
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Email",
                          hintText: "you@example.com",
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "******",
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
                          },
                          child: const Text("Forgot Password?",
                              style: TextStyle(color: Colors.deepPurpleAccent)),
                        ),
                      ),

                      if (authProvider.errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            authProvider.errorMessage,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading || !isFilled ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: isFilled
                                ? const Color(0xFF000000) // Your new active color
                                : const Color(0xFF2A2A2E),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: authProvider.isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3)
                              : Text(
                            "Login",
                            style: TextStyle(
                              color: isFilled
                                  ? Colors.white
                                  : Colors.grey.shade300,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Center(
                          child: Text("or",
                              style: TextStyle(color: Colors.grey))),
                      const SizedBox(height: 10),

                      // Sign up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account?",
                              style: TextStyle(color: Colors.white60)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const SignUpPage()));
                            },
                            child: const Text("Sign Up",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurpleAccent)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
