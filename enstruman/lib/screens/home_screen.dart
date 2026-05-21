import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'enstruman_ekle_screen.dart';
import 'enstruman_detay_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String rol; 

  const HomeScreen({super.key, required this.rol});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> ihaleListesi = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _verileriGetir(); 
  }

  Future<void> _verileriGetir() async {
    setState(() => _yukleniyor = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      var query = Supabase.instance.client.from('enstrumanlar').select();

      
      if (widget.rol == 'musteri') {
        query = query.eq('musteri_id', user.id);
      }

      final List<dynamic> gelenVeri = await query.order('created_at', ascending: false);

      setState(() {
        ihaleListesi = List<Map<String, dynamic>>.from(gelenVeri);
      });
    } catch (hata) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veri çekilirken hata oluştu: $hata")),
      );
    } finally {
      setState(() => _yukleniyor = false);
    }
  }


  Future<void> _ilaniSil(int ilanId, String enstrumanAdi) async {
    
    bool? onay = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("İlanı Sil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Bu enstrümanı ve ona gelen teklifleri tamamen silmek istediğinize emin misiniz?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Hayır
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), // Evet
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Evet, Sil", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (onay != true) return; 

    setState(() => _yukleniyor = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

     
      await Supabase.instance.client
          .from('enstrumanlar')
          .delete()
          .eq('id', ilanId)
          .eq('musteri_id', user.id); 
      
      await Supabase.instance.client.from('logs').insert({
        'user_id': user.id,
        'islem': 'Müşteri ilanını sildi: $enstrumanAdi',
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("İlan başarıyla silindi!")));
      _verileriGetir(); 

    } catch (hata) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Silme Hatası: $hata")));
      setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ihaleListesi.isEmpty && _yukleniyor == false) { _verileriGetir(); }

    final Color borderRengi = widget.rol == 'usta' ? Colors.red : Colors.orange;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: widget.rol == 'usta' ? Colors.red[900] : Colors.orange,
        title: Text(widget.rol == 'usta' ? "Usta İhale Paneli" : "Hasarlı Enstrümanlarım"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut(); 
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, 
                );
              }
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator()) 
          : RefreshIndicator(
              onRefresh: _verileriGetir, 
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    color: Colors.black26,
                    child: Text(
                      widget.rol == 'usta'
                          ? "Aşağıdaki ilanlara en uygun fiyatı ver, işi sen kap!"
                          : "Yüklediğin hasarlı enstrümanlar ve ustalardan gelen teklifler:",
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ihaleListesi.isEmpty
                        ? ListView( 
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.music_off_rounded, size: 70, color: borderRengi),
                                    const SizedBox(height: 15),
                                    Text(
                                      "Henüz aktif bir ilan bulunmuyor.",
                                      style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      widget.rol == 'musteri'
                                          ? "Aşağıdaki butona basarak ilk ilanını ekleyebilirsin."
                                          : "Müşterilerin ilan yüklemesi bekleniyor.",
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount: ihaleListesi.length,
                            itemBuilder: (context, index) {
                              final ilan = ihaleListesi[index];
                              return Card(
                                color: Colors.black54,
                                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15), 
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            ilan['enstruman_adi']?.toString() ?? "Bilinmeyen Cihaz", 
                                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: widget.rol == 'usta' ? Colors.red[900] : Colors.orange[900],
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text("Aktif İhale", style: TextStyle(color: Colors.white, fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        ilan['hasar_aciklamasi']?.toString() ?? "Açıklama yok.", 
                                        style: const TextStyle(color: Colors.white70, fontSize: 14)
                                      ),
                                      const SizedBox(height: 15),
                                      const Divider(color: Colors.grey),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          
                                          if (widget.rol == 'musteri')
                                            IconButton(
                                              onPressed: () => _ilaniSil(int.parse(ilan['id'].toString()), ilan['enstruman_adi'].toString()),
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              tooltip: "İlanı Sil",
                                            ),
                                          
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => EnstrumanDetayScreen(ilan: ilan, rol: widget.rol)),
                                              );
                                            },
                                            icon: Icon(widget.rol == 'usta' ? Icons.gavel : Icons.visibility, color: Colors.black, size: 18),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: widget.rol == 'usta' ? Colors.red : Colors.orange,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            label: Text(
                                              widget.rol == 'usta' ? "Fiyat Teklifi Ver" : "Detayları Gör",
                                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: widget.rol == 'musteri' 
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EnstrumanEkleScreen()),
                );
                _verileriGetir(); 
              },
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text("Yeni Hasarlı Cihaz Yükle", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }
}