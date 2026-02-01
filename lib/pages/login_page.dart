import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool startAnimation = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => startAnimation = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /// ================= BACKGROUND =================
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6EC6FF),
                  Color(0xFFE3F2FD),
                ],
              ),
            ),
          ),

          /// ================= ☁️ AWAN-AWAN =================
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            top: -10,
            left: startAnimation ? -40 : -200,
            child: Image.asset(
              'assets/images/awan_kiri.png',
              width: 120,
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOut,
            top: 0,
            right: startAnimation ? -60 : -200,
            child: Image.asset(
              'assets/images/awan_kecil.png',
              width: 120,
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOut,
            top: 110,
            left: startAnimation ? -30 : -220,
            child: Image.asset(
              'assets/images/awan_kecil.png',
              width: 150,
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOut,
            top: 90,
            right: startAnimation ? -40 : -220,
            child: Image.asset(
              'assets/images/awan_knn.png',
              width: 160,
            ),
          ),

          /// ================= LOGIN CARD =================
          Align(
            alignment: const Alignment(0, -0.05),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: startAnimation ? 1 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                offset: startAnimation
                    ? Offset.zero
                    : const Offset(0, 0.4), // ⬅️ DARI BAWAH
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// LOGO
                      Image.asset(
                        'assets/images/sekolah.png',
                        width: 300,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'ABSENSI SISWA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Login Dulu yah',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// USERNAME
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Username',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// PASSWORD
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// LOGIN BUTTON
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// LUPA PASSWORD
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Lupa Password?',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
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
