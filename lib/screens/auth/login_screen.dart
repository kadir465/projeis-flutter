import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeis/data/services/auth_service.dart';
import 'package:projeis/core/theme/app_theme.dart';
import 'package:projeis/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AppTheme tema = AppTheme();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';
  bool _showForgotPassword = false;

  Future<void> createUser() async {
    try {
      await AuthService().signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.message!;
        });
      }
    }
  }

  Future<void> signIn() async {
    try {
      await AuthService().signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1D1E33),
              title: const Text(
                'Kullanıcı Bulunamadı',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Kayıtlı değilsiniz. Kayıt olmak ister misiniz?',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal', style: TextStyle(color: Color(0xFFEB1555))),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    createUser();
                  },
                  child: const Text('Kayıt Ol', style: TextStyle(color: Color(0xFF24D876))),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = e.message!;
          });
        }
      }
    }
  }

  void resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        errorMessage = "Lütfen bir e-posta adresi girin";
      });
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF1D1E33),
            content: Text(
              'Şifre sıfırlama bağlantısı email adresinize gönderildi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
        setState(() {
          _showForgotPassword = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.message!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E21),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: 180,
                  height: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1D1E33), Color(0xFF111328)],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                      border: Border.all(color: const Color(0xFF24D876)),
                      color: const Color(0xFF1D1E33),
                    ),
                    child: const Icon(
                      Icons.login,
                      size: 50,
                      color: Color(0xFF24D876),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    _showForgotPassword ? "Şifre Sıfırlama" : "Giriş Yap",
                    style: GoogleFonts.golosText(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      errorMessage,
                      style: GoogleFonts.golosText(
                        color: const Color(0xFFEB1555),
                        fontSize: 16,
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1E33),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "E-posta adresinizi girin",
                      hintStyle: GoogleFonts.golosText(color: Colors.white70, fontSize: 16),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF24D876)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    style: GoogleFonts.golosText(color: Colors.white, fontSize: 16),
                  ),
                ),
                if (!_showForgotPassword)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1E33),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Şifre giriniz",
                        hintStyle: GoogleFonts.golosText(color: Colors.white70, fontSize: 16),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF24D876)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      style: GoogleFonts.golosText(color: Colors.white, fontSize: 16),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showForgotPassword = !_showForgotPassword;
                      errorMessage = '';
                    });
                  },
                  child: Text(
                    _showForgotPassword ? "Giriş Yap" : "Şifremi Unuttum",
                    style: GoogleFonts.golosText(
                      color: const Color(0xFF24D876),
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_showForgotPassword)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24D876),
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        "Şifre Sıfırlama Linki Gönder",
                        style: GoogleFonts.golosText(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF24D876),
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        "Giriş Yap",
                        style: GoogleFonts.golosText(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: createUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D1E33),
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        "Kayıt Ol",
                        style: GoogleFonts.golosText(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
