import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase bağlantısının nasıl yapılacağı için link
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
    //  Aktif oturum var mı kontrol etmek için ekledim bunu
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enstrüman Kiralama',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
      ),
    
      home: session != null ? const HomeScreen(rol: 'musteri') : const LoginScreen(),
    );
  }
}