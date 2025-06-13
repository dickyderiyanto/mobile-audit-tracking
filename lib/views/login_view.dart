import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_audit_tracking/views/home_view.dart';
import '../bloc/login/login_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Bagian atas background biru
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                color: Colors.blue.shade800,
              ),
            ),
          ),

          // Form login dalam card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - 160,
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
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: 360,
                    height: 420,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Form Login",
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 30),

                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.face),
                            labelText: "Username",
                          ),
                          controller: usernameController,
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.lock),
                            labelText: "Password",
                            suffixIcon: Icon(Icons.visibility),
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
    );
  }
}
