import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeis/screens/tasks/duty_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:projeis/screens/settings/settings_screen.dart';
import 'package:firebase_database/firebase_database.dart';

class ProjectScreen extends StatefulWidget {
  String projeAdi;
  String projeAciklamasi;
  DateTime baslangicTarihi;
  DateTime bitisTarihi;

  ProjectScreen({
    Key? key,
    required this.projeAdi,
    required this.projeAciklamasi,
    required this.baslangicTarihi,
    required this.bitisTarihi,
  }) : super(key: key);

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final List<Gorev> gorevler = [];
  double projeIlerleme = 0.0;
  final TextEditingController _aciklamaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verileriYukle();
    _aciklamaController.text = widget.projeAciklamasi;
  }

  Future<void> _verileriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final kaydedilmisAciklama = prefs.getString('${widget.projeAdi}_aciklama');
      if (kaydedilmisAciklama != null) {
        widget.projeAciklamasi = kaydedilmisAciklama;
        _aciklamaController.text = kaydedilmisAciklama;
      }
      final gorevlerJson = prefs.getString('${widget.projeAdi}_gorevler');
      if (gorevlerJson != null) {
        final List<dynamic> gorevlerList = jsonDecode(gorevlerJson);
        gorevler.clear();
        for (var gorev in gorevlerList) {
          gorevler.add(Gorev(baslik: gorev['baslik'], aciklama: gorev['aciklama'], atananKisi: gorev['atananKisi'], mail: gorev['mail'] ?? '', tamamlandi: gorev['tamamlandi']));
        }
        ilerlemeHesapla();
      }
    });
  }

  Future<void> _verileriKaydet() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${widget.projeAdi}_aciklama', widget.projeAciklamasi);
    final gorevlerList = gorevler.map((gorev) => {'baslik': gorev.baslik, 'aciklama': gorev.aciklama, 'atananKisi': gorev.atananKisi, 'tamamlandi': gorev.tamamlandi}).toList();
    await prefs.setString('${widget.projeAdi}_gorevler', jsonEncode(gorevlerList));
  }

  void gorevEkle(String baslik, String aciklama, String atananKisi, String mail) {
    setState(() {
      gorevler.add(Gorev(baslik: baslik, aciklama: aciklama, atananKisi: atananKisi, mail: mail, tamamlandi: false));
      ilerlemeHesapla();
      _verileriKaydet();
    });
  }

  void gorevDurumDegistir(int index, bool tamamlandi) {
    setState(() {
      gorevler[index].tamamlandi = tamamlandi;
      ilerlemeHesapla();
      _verileriKaydet();
    });
  }

  void ilerlemeHesapla() {
    if (gorevler.isEmpty) { projeIlerleme = 0.0; return; }
    int tamamlananGorevler = gorevler.where((g) => g.tamamlandi).length;
    projeIlerleme = tamamlananGorevler / gorevler.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1E33),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF24D876)), onPressed: () => Navigator.pop(context)),
        title: Text(widget.projeAdi, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF24D876)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(settings: UserSettings(name: 'Kullanıcı', email: 'user@example.com', phone: '0555', role: 'User', password: '***', bildirimAktif: true, dilSecenegi: 'tr', tema: 'dark'))));
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF1D1E33)])),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Proje Detayları', style: GoogleFonts.golosText(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16.0),
              Card(
                color: const Color(0xFF1D1E33),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _aciklamaController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Açıklama', labelStyle: TextStyle(color: Color(0xFF24D876)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF24D876)))),
                        onChanged: (value) { setState(() { widget.projeAciklamasi = value; _verileriKaydet(); }); },
                      ),
                      const SizedBox(height: 8),
                      Row(children: [Text('Başlangıç: ', style: const TextStyle(color: Colors.white70)), TextButton(child: Text(widget.baslangicTarihi.toString().split(' ')[0], style: const TextStyle(color: Color(0xFF24D876))), onPressed: () async { final date = await showDatePicker(context: context, initialDate: widget.baslangicTarihi, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (date != null) setState(() => widget.baslangicTarihi = date); })]),
                      Row(children: [Text('Bitiş: ', style: const TextStyle(color: Colors.white70)), TextButton(child: Text(widget.bitisTarihi.toString().split(' ')[0], style: const TextStyle(color: Color(0xFF24D876))), onPressed: () async { final date = await showDatePicker(context: context, initialDate: widget.bitisTarihi, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (date != null) setState(() => widget.bitisTarihi = date); })]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Proje İlerlemesi: %${(projeIlerleme * 100).toInt()}', style: GoogleFonts.golosText(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              LinearProgressIndicator(value: projeIlerleme, minHeight: 10, backgroundColor: const Color(0xFF1D1E33), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF24D876))),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Görevler', style: GoogleFonts.golosText(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)), ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF24D876), foregroundColor: Colors.white), onPressed: () => showDialog(context: context, builder: (context) => GorevEkleDialog(onGorevEkle: gorevEkle)), icon: const Icon(Icons.add), label: const Text('Görev Ekle'))]),
              ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: gorevler.length, itemBuilder: (context, index) => GorevKarti(gorev: gorevler[index], onDurumDegistir: (tamamlandi) => gorevDurumDegistir(index, tamamlandi), onSil: () { setState(() { gorevler.removeAt(index); _verileriKaydet(); }); })),
            ],
          ),
        ),
      ),
    );
  }
}

class Gorev {
  String baslik; String aciklama; String atananKisi; bool tamamlandi; String mail;
  Gorev({required this.baslik, required this.aciklama, required this.atananKisi, required this.mail, this.tamamlandi = false});
}

class GorevKarti extends StatelessWidget {
  final Gorev gorev; final Function(bool) onDurumDegistir; final VoidCallback onSil;
  const GorevKarti({Key? key, required this.gorev, required this.onDurumDegistir, required this.onSil}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(color: const Color(0xFF1D1E33), margin: const EdgeInsets.symmetric(vertical: 8.0), child: ListTile(title: Text(gorev.baslik, style: const TextStyle(color: Colors.white)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(gorev.aciklama, style: const TextStyle(color: Colors.white70)), Text('Atanan: ${gorev.atananKisi}', style: const TextStyle(color: Colors.white70))]), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Checkbox(value: gorev.tamamlandi, onChanged: (value) => onDurumDegistir(value ?? false), activeColor: const Color(0xFF24D876), checkColor: Colors.white), IconButton(icon: const Icon(Icons.delete, color: Color(0xFFEB1555)), onPressed: onSil), IconButton(icon: const Icon(Icons.message, color: Color(0xFF24D876)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DutyScreen(receiverId: 'someId', receiverEmail: 'someEmail'))))])));
  }
}

class GorevEkleDialog extends StatefulWidget {
  final void Function(String, String, String, String) onGorevEkle;
  const GorevEkleDialog({Key? key, required this.onGorevEkle}) : super(key: key);
  @override
  _GorevEkleDialogState createState() => _GorevEkleDialogState();
}

class _GorevEkleDialogState extends State<GorevEkleDialog> {
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _atananKisiController = TextEditingController();
  final _mailController = TextEditingController();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child("gorevler");
  @override
  Widget build(BuildContext context) {
    return AlertDialog(backgroundColor: const Color(0xFF1D1E33), title: const Text('Yeni Görev', style: TextStyle(color: Colors.white)), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: _baslikController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Görev Başlığı', labelStyle: TextStyle(color: Color(0xFF24D876)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF24D876))))), TextField(controller: _aciklamaController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Görev Açıklaması', labelStyle: TextStyle(color: Color(0xFF24D876)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF24D876))))), TextField(controller: _atananKisiController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Atanan Kişi', labelStyle: TextStyle(color: Color(0xFF24D876)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF24D876))))), TextField(controller: _mailController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'E-Mail', labelStyle: TextStyle(color: Color(0xFF24D876)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF24D876)))))])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal', style: TextStyle(color: Color(0xFF24D876)))), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF24D876), foregroundColor: Colors.white), onPressed: () { if (_baslikController.text.isNotEmpty) { String? key = _databaseRef.push().key; if (key != null) _databaseRef.child(key).set({'baslik': _baslikController.text, 'aciklama': _aciklamaController.text, 'atananKisi': _atananKisiController.text, 'mail': _mailController.text}); widget.onGorevEkle(_baslikController.text, _aciklamaController.text, _atananKisiController.text, _mailController.text); Navigator.pop(context); } }, child: const Text('Ekle'))]);
  }
}
