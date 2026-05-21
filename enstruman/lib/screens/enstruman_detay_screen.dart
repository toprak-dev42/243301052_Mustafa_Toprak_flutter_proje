import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnstrumanDetayScreen extends StatefulWidget {
  final Map<String, dynamic> ilan; 
  final String rol; 

  const EnstrumanDetayScreen({super.key, required this.ilan, required this.rol});

  @override
  State<EnstrumanDetayScreen> createState() => _EnstrumanDetayScreenState();
}

class _EnstrumanDetayScreenState extends State<EnstrumanDetayScreen> {
  final _fiyatController = TextEditingController();
  bool _yukleniyor = false;
  List<Map<String, dynamic>> _gelenTeklifler = []; 

  @override
  void initState() {
    super.initState();
    _teklifleriGetir(); 
  }

 
  Future<void> _teklifleriGetir() async {
    try {
      final int ilanId = int.parse(widget.ilan['id'].toString());
      
      
      final List<dynamic> veriler = await Supabase.instance.client
          .from('ustanin_fiyatlari')
          .select()
          .eq('enstruman_id', ilanId)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> tekliflerVeIsimler = [];

     
      for (var t in veriler) {
        Map<String, dynamic> teklif = Map<String, dynamic>.from(t);
        String ustaIsmi = "Bilinmeyen Usta"; 
        
        try {
          final profil = await Supabase.instance.client
              .from('profiles')
              .select('isim') 
              .eq('id', teklif['usta_id'])
              .maybeSingle();

          if (profil != null && profil['isim'] != null) {
            ustaIsmi = profil['isim'].toString();
          }
        } catch (e) {
          
        }

        teklif['usta_ismi'] = ustaIsmi;
        tekliflerVeIsimler.add(teklif);
      }

      setState(() {
        _gelenTeklifler = tekliflerVeIsimler;
      });
    } catch (hata) {
      print("Teklifler çekilirken hata: $hata");
    }
  }

  void _fiyatKaydet() async {
    if (_fiyatController.text.isEmpty) return;
    setState(() => _yukleniyor = true);
    
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      double girilenFiyat = double.parse(_fiyatController.text.replaceAll(',', '.'));
      int ilanId = int.parse(widget.ilan['id'].toString());

      await Supabase.instance.client.from('ustanin_fiyatlari').insert({
        'enstruman_id': ilanId,
        'usta_id': user.id, 
        'tespit_fiyati': girilenFiyat,
      });

      await Supabase.instance.client.from('logs').insert({
        'user_id': user.id,
        'islem': 'Usta teklif verdi: $girilenFiyat TL',
      });

      if (mounted) {
        _fiyatController.clear();
        _teklifleriGetir(); 
      }
    } catch (hata) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kayıt Hatası: $hata")));
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("İlan Detayı")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cihaz: ${widget.ilan['enstruman_adi']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Hasar: ${widget.ilan['hasar_aciklamasi']}"),
            const SizedBox(height: 30),

            const Text("Gelen Teklifler:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 10),
            
            _gelenTeklifler.isEmpty
                ? const Text("Bu ilana henüz fiyat teklifi verilmemiş.", style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _gelenTeklifler.length,
                    itemBuilder: (context, index) {
                      final teklif = _gelenTeklifler[index];
                      return Card(
                        color: Colors.grey[800],
                        child: ListTile(
                          leading: const Icon(Icons.currency_lira, color: Colors.green), 
                          title: Text("${teklif['tespit_fiyati']} TL", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Text("${teklif['usta_ismi']} adlı ustanın teklifi", style: const TextStyle(color: Colors.orange)),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 30),
            const Divider(color: Colors.grey),
            const SizedBox(height: 20),

            if (widget.rol == 'usta') ...[
              TextField(
                controller: _fiyatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Yeni Fiyat Teklifi (TL)"),
              ),
              const SizedBox(height: 10),
              _yukleniyor 
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _fiyatKaydet,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Teklif Gönder", style: TextStyle(color: Colors.white)),
                    ),
                  ),
            ] else ...[
              const Center(child: Text("Sadece ustalar fiyat teklifi verebilir.", style: TextStyle(color: Colors.grey))),
            ]
          ],
        ),
      ),
    );
  }
}