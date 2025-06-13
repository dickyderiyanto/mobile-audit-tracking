import 'package:flutter/material.dart';
import 'package:mobile_audit_tracking/bloc/user_info/user_info_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_audit_tracking/repository/auth_repository.dart';
import 'package:mobile_audit_tracking/views/login_view.dart';

class ProfileView extends StatefulWidget {
  final String token;
  const ProfileView({super.key, required this.token});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<UserInfoBloc>().add(LoadUserInfo(widget.token));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Profil"), actions: const []),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            height: MediaQuery.of(context).size.height * 0.20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                color: Colors.blue.shade800,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25 - 100,
            left: (MediaQuery.of(context).size.width - 380) / 2,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 380,
                height: 420,
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<UserInfoBloc, UserInfoState>(
                  builder: (context, state) {
                    if (state is UserInfoLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is UserInfoLoaded) {
                      final user = state.userInfo;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // const Text("Profile", style: TextStyle(fontSize: 20)),
                          CircleAvatar(
                            radius: 28.0,
                            backgroundImage: NetworkImage(
                              "https://res.cloudinary.com/dotz74j1p/raw/upload/v1716044979/nr7gt66alfhmu9vaxu2u.png",
                            ),
                          ),

                          const SizedBox(height: 16),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Username: ${user.username}"),
                          Text("Kode User: ${user.userCode}"),
                          // Text("Role: ${user.roleCode}"),
                          SizedBox(height: 40),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _showLogoutDialog(context),
                            child: const Text("Keluar"),
                          ),
                        ],
                      );
                    } else if (state is UserInfoError) {
                      return Center(child: Text("Gagal memuat data profile"));
                    } else {
                      return Text("Tidak ada data user");
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah yakin ingin keluar aplikasi ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Batal
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog

                // Hapus token dan pindah ke login
                await AuthRepository().logout();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginView()),
                  (route) => false,
                );
              },
              child: const Text('Keluar'),
            ),
          ],
        ),
  );
}
