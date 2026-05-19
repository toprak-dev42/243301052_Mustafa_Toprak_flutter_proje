import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'hakkimizda_screen.dart'; // YENİ SAYFAMIZI BURAYA ÇAĞIRDIK

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _yukleniyor = false;

  void _girisYap() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _yukleniyor = true);

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.user != null) {
        final veri = await Supabase.instance.client.from('profiles').select('role').eq('id', res.user!.id).single();
        final String gelenRol = veri['role'] as String;

        await Supabase.instance.client.from('logs').insert({'user_id': res.user!.id, 'islem': 'Kullanıcı giriş yaptı.'});

        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(rol: gelenRol)));
        }
      }
    } catch (hata) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $hata")));
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/arka_plan.png'), fit: BoxFit.cover),
        ),
        child: _yukleniyor
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.music_note_rounded, size: 80, color: Colors.orange),
                      const SizedBox(height: 10),
                      const Text("Enstrüman Kiralama", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 40),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "E-posta Adresi", labelStyle: TextStyle(color: Colors.orange), border: OutlineInputBorder(), filled: true, fillColor: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Şifre", labelStyle: TextStyle(color: Colors.orange), border: OutlineInputBorder(), filled: true, fillColor: Colors.black54),
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _girisYap,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          child: const Text("Giriş Yap", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                        child: const Text("Hesabın yok mu? Hemen Kayıt Ol", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      
                      // KISA VE ÖZ YENİ SAYFAYA GEÇİŞ BUTONU
                      TextButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HakkimizdaScreen())),
                        icon: const Icon(Icons.info, color: Colors.grey, size: 20),
                        label: const Text("Uygulama Hakkında", style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}