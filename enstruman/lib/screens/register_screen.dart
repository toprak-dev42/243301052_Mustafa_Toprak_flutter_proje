import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'musteri'; 
  bool _yukleniyor = false;

  void _kayitOl() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      // Supabase Auth Sistemine Kayıt Atıyoruz
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = res.user;

      if (user != null) {
        // SQL Veritabanına Profili mühürlüyoruz
        await Supabase.instance.client.from('profiles').insert({
          'id': user.id,
          'full_name': _nameController.text.trim(),
          'role': _selectedRole,
        });

        // Logs tablosuna işlem kaydı düşüyoruz
        await Supabase.instance.client.from('logs').insert({
          'user_id': user.id,
          'islem': 'Yeni kullanıcı kaydı oluşturuldu. Rol: $_selectedRole',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kayıt Başarılı! Şimdi giriş yapabilirsiniz.")),
          );
          Navigator.pop(context);
        }
      }
    } catch (hata) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kayıt sırasında bir durum oluştu, lütfen giriş yapmayı deneyin.")),
        );
        // Eğer Auth oluşup SQL'de takıldıysa bile kullanıcıyı ana ekrana döndür ki giriş yapabilsin
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Kayıt")),
      body: _yukleniyor 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Ad Soyad", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "E-posta", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Şifre (En az 6 karakter)", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  RadioListTile<String>(
                    title: const Text("Enstrüman Kullanıcısı (Müşteri)"),
                    value: 'musteri',
                    groupValue: _selectedRole,
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                  RadioListTile<String>(
                    title: const Text("Tamir Ustası (Ekspertiz)"),
                    value: 'usta',
                    groupValue: _selectedRole,
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _kayitOl,
                      child: const Text("Kayıt Ol"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}