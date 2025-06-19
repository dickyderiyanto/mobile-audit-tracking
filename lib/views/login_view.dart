import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_audit_tracking/views/home_view.dart';
import '../bloc/login/login_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Bagian atas background biru
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              // right: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text(
                    "Helo,",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // SizedBox(height: 2),
                  Text(
                    "Silahkan login untuk melanjutkan.",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form login dalam card
            Positioned(
              top: MediaQuery.of(context).size.height * 0.5 - 220,
              left: MediaQuery.of(context).size.width / 2 - 180,
              child: BlocConsumer<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginSuccess) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeView()),
                    );
                  } else if (state is LoginFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  if (state is LoginLoading) {
                    return const SizedBox(
                      width: 360,
                      height: 420,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return Card(
                    color: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      width: 360,
                      height: 420,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Audit Tracking",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "Tracing the history of a transaction",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(fontSize: 12),
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.person),
                              labelText: "Username",
                            ),
                            controller: usernameController,
                          ),

                          const SizedBox(height: 16),
                          TextFormField(
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              icon: Icon(Icons.lock),
                              labelText: "Password",
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            controller: passwordController,
                          ),
                          const SizedBox(height: 40),
                          Container(
                            height: 40,
                            width: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.blue.shade800,
                            ),
                            child: TextButton(
                              onPressed: () {
                                final username = usernameController.text;
                                final password = passwordController.text;

                                context.read<LoginBloc>().add(
                                  LoginSubmitted(
                                    username: username,
                                    password: password,
                                  ),
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
