import 'package:flutter/material.dart';
import 'package:kisiler_uygulamasi/data/entity/kisiler.dart';
import 'package:kisiler_uygulamasi/ui/views/detay_sayfa.dart';
import 'package:kisiler_uygulamasi/ui/views/kayit_sayfa.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  bool aramaYapiliyorMu = false;
  String aramaKelimesi = "";

  List<Kisiler> tumKisiler = [];

  List<Kisiler> get gosterilecekKisiler {
    if (aramaKelimesi.trim().isEmpty) {
      return tumKisiler;
    }
    return tumKisiler
        .where(
          (kisi) => kisi.kisi_ad.toLowerCase().contains(
            aramaKelimesi.toLowerCase(),
          ),
        )
        .toList();
  }

  Future<void> kisiSil(int kisiId) async {
    setState(() {
      tumKisiler.removeWhere((kisi) => kisi.kisi_id == kisiId);
    });
    print("kisi sil: $kisiId");
  }

  int yeniKisiIdUret() {
    if (tumKisiler.isEmpty) {
      return 1;
    }
    return tumKisiler.map((kisi) => kisi.kisi_id).reduce((a, b) => a > b ? a : b) +
        1;
  }

  void kisiEkle(Kisiler kisi) {
    setState(() {
      tumKisiler.add(
        Kisiler(
          kisi_id: yeniKisiIdUret(),
          kisi_ad: kisi.kisi_ad,
          kisi_tel: kisi.kisi_tel,
        ),
      );
    });
  }

  void kisiGuncelle(Kisiler guncelKisi) {
    var index = tumKisiler.indexWhere((kisi) => kisi.kisi_id == guncelKisi.kisi_id);
    if (index == -1) {
      return;
    }
    setState(() {
      tumKisiler[index] = guncelKisi;
    });
  }

  void silmeOnayDialog(Kisiler kisi) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Silme İşlemi"),
          content: Text("${kisi.kisi_ad} silinsin mi?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                kisiSil(kisi.kisi_id);
              },
              child: const Text("Sil"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var kisiListesi = gosterilecekKisiler;

    return Scaffold(
      appBar: AppBar(
        title: aramaYapiliyorMu
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: "Kişi ara"),
                style: const TextStyle(color: Colors.white),
                onChanged: (aramaSonucu) {
                  setState(() {
                    aramaKelimesi = aramaSonucu;
                  });
                },
              )
            : const Text("Kişiler"),
        actions: [
          aramaYapiliyorMu
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      aramaYapiliyorMu = false;
                      aramaKelimesi = "";
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      aramaYapiliyorMu = true;
                    });
                  },
                  icon: const Icon(Icons.search),
                ),
        ],
      ),
      body: kisiListesi.isEmpty
          ? const Center(child: Text("Henüz kayıtlı kişi yok"))
          : ListView.builder(
              itemCount: kisiListesi.length,
              itemBuilder: (context, index) {
                var kisi = kisiListesi[index];
                return Card(
                  child: SizedBox(
                    height: 70,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetaySayfa(kisi: kisi),
                                ),
                              ).then((value) {
                                if (value != null && value is Kisiler) {
                                  kisiGuncelle(value);
                                }
                              });
                            },
                            leading: CircleAvatar(
                              child: Text(kisi.kisi_ad[0]),
                            ),
                            title: Text(kisi.kisi_ad),
                            subtitle: Text(kisi.kisi_tel),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (secim) {
                            if (secim == "sil") {
                              silmeOnayDialog(kisi);
                            }
                          },
                          itemBuilder: (context) {
                            return const [
                              PopupMenuItem<String>(
                                value: "sil",
                                child: Text("Sil"),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KayitSayfa()),
          ).then((value) {
            if (value != null && value is Kisiler) {
              kisiEkle(value);
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
