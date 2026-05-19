import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase bağlantısını senin anahtarınla başlattık
  await Supabase.initialize(
    url: 'https://ekjnrgnrhyudwrmmitrk.supabase.co',
    anonKey: 'sb_publishable_H9c94THVUJccurWiqAlETA_u7mGrsUM', 
  );

  runApp(const Uygulamam());
}

class Uygulamam extends StatelessWidget {
  const Uygulamam({super.key});

  @override
  Widget build(BuildContext context) {
    // HOCANIN ŞARTI: Aktif oturum var mı kontrol ediyoruz
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enstrüman Kiralama',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
      ),
      // Kullanıcı önceden giriş yaptıysa direkt ana sayfaya, yapmadıysa giriş ekranına gönderiyoruz
      home: session != null ? const HomeScreen(rol: 'musteri') : const LoginScreen(),
    );
  }
}