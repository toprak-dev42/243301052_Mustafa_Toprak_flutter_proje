import 'package:flutter/material.dart';

class HakkimizdaScreen extends StatelessWidget {
  const HakkimizdaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Uygulama Hakkında", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black), // Geri dönüş okunun rengi
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 30),
                SizedBox(width: 10),
                Text("Proje Amacı", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Bu uygulama, hasarlı enstrümanlarını tamir ettirmek isteyen müzisyenler ile alanında uzman tamir ustalarını tek bir çatı altında toplayan bir 'İhale ve Teklif' platformudur.",
              style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🎸 Müşteriler:", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  Text("Hasarlı cihazlarını sisteme detaylarıyla yükler ve ustalardan gelen teklifleri değerlendirir.", style: TextStyle(color: Colors.white70, fontSize: 15)),
                  SizedBox(height: 20),
                  Text("🛠️ Ustalar:", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 8),
                  Text("Sisteme düşen ilanları inceler ve hasar durumuna göre kendi tamir bedelini sisteme girer.", style: TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            ),
            const Spacer(),
            const Center(
              child: Text(
                "Şeffaf, hızlı ve güvenilir tamir ekosistemi.",
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}