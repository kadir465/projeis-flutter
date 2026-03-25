import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeis/screens/project/project_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> projeler = [];

  void projeEkle() {
    setState(() {
      int enYuksekNumara = 0;
      for (var proje in projeler) {
        String projeAdi = proje['ad'];
        if (projeAdi.startsWith('Proje ')) {
          int numara = int.tryParse(projeAdi.substring(6)) ?? 0;
          if (numara > enYuksekNumara) {
            enYuksekNumara = numara;
          }
        }
      }
      projeler.add({
        'ad': 'Proje ${enYuksekNumara + 1}',
        'durum': 'Devam Ediyor',
        'gorevSayisi': 0,
        'gorevler': [],
      });
    });
  }

  void gorevEkle(int projeIndex) {
    setState(() {
      projeler[projeIndex]['gorevSayisi']++;
      projeler[projeIndex]['gorevler'].add({
        'ad': 'Görev ${projeler[projeIndex]['gorevSayisi']}',
        'tamamlandi': false,
        'tarih': DateTime.now().add(const Duration(days: 7)),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1D1E33),
        title: Text(
          'Proje Yönetimi',
          style: GoogleFonts.golosText(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF1D1E33)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aktif Projeler',
                style: GoogleFonts.golosText(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: projeler.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectScreen(
                              projeAdi: projeler[index]['ad'],
                              projeAciklamasi: '',
                              baslangicTarihi: DateTime.now(),
                              bitisTarihi: DateTime.now().add(const Duration(days: 30)),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1D1E33), Color(0xFF111328)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                projeler[index]['ad'],
                                style: GoogleFonts.golosText(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF24D876).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  projeler[index]['durum'],
                                  style: const TextStyle(
                                    color: Color(0xFF24D876),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'Görev Sayısı: ${projeler[index]['gorevSayisi']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_task, color: Color(0xFF24D876), size: 28),
                                    onPressed: () => gorevEkle(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Color(0xFFEB1555), size: 28),
                                    onPressed: () {
                                      setState(() {
                                        projeler.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF24D876),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Yeni Proje',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: projeEkle,
      ),
    );
  }
}
