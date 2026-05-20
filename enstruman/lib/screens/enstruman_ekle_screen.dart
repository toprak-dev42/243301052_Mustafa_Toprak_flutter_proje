import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnstrumanEkleScreen extends StatefulWidget {
  const EnstrumanEkleScreen({super.key});

  @override
  State<EnstrumanEkleScreen> createState() => _EnstrumanEkleScreenState();
}

class _EnstrumanEkleScreenState extends State<EnstrumanEkleScreen> {
  final _cihazAdiController = TextEditingController();
  final _hasarController = TextEditingController();
  bool _yukleniyor = false;

  void _ilanEkle() async {
    if (_cihazAdiController.text.isEmpty || _hasarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun!")),
      );
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Oturum hatası, tekrar giriş yapın!")));
         return;
      }

      // 1. İlanı Supabase'e ekle
      await Supabase.instance.client.from('enstrumanlar').insert({
        'musteri_id': user.id,
        'enstruman_adi': _cihazAdiController.text.trim(),
        'hasar_aciklamasi': _hasarController.text.trim(),
      });

      // 2. Logs tablosuna kaydet
      await Supabase.instance.client.from('logs').insert({
        'user_id': user.id,
        'islem': 'İlan eklendi: ${_cihazAdiController.text.trim()}',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enstrüman başarıyla eklendi!")),
        );
        // Ana sayfaya dön ve listeyi yenilemesini söyle
        Navigator.pop(context, true); 
      }
    } catch (hata) {
      if (mounted) {
        // Eğer veritabanı reddederse kırmızı kırmızı hatayı ekrana basacak
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kayıt Hatası: ${hata.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hasarlı Cihaz Yükle")),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _cihazAdiController,
                    decoration: const InputDecoration(labelText: "Cihaz Adı (Örn: Gitar)", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _hasarController,
                    decoration: const InputDecoration(labelText: "Hasar Açıklaması", border: OutlineInputBorder()),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _ilanEkle,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text("İlanı Yayınla", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}