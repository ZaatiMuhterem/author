import 'package:flutter/material.dart';
import 'package:yazar/model/kitap.dart';
import 'package:yazar/sabitler.dart';
import 'package:yazar/view/bolumler_sayfasi.dart';
import 'package:yazar/yerel_veri_tabani.dart';

class KitaplarSayfasi extends StatefulWidget {
  @override
  State<KitaplarSayfasi> createState() => _KitaplarSayfasiState();
}

class _KitaplarSayfasiState extends State<KitaplarSayfasi> {
  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();

  ScrollController _scrollController = ScrollController();

  List<Kitap> _kitaplar = [];

  List<int> _tumKategoriler = [-1];
  int _secilenKategori = -1;

  List<int> _secilenKitapIdleri = [];

  @override
  void initState() {
    super.initState();
    _tumKategoriler.addAll(Sabitler.kategoriler.keys);
    _scrollController.addListener(_kaydirmaKontrol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildKitapEkleFab(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Kitaplar Sayfası"),
      actions: [
        IconButton(
          icon: Icon(
            Icons.delete,
          ),
          onPressed: _seciliKitaplariSil,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: _ilkKitaplariGetir(),
      builder: _buildListView,
    );
  }

  Widget _buildListView(BuildContext context, AsyncSnapshot<void> snapshot) {
    return Column(
      children: [
        _buildKategoriFiltresi(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _kitaplar.length,
            itemBuilder: _buildListItem,
          ),
        ),
      ],
    );
  }

  Widget _buildKategoriFiltresi() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text("Kategori:"),
        DropdownButton<int>(
          value: _secilenKategori,
          items: _tumKategoriler.map((kategoriId) {
            return DropdownMenuItem<int>(
              value: kategoriId,
              child: Text(
                kategoriId == -1
                    ? "Hepsi"
                    : Sabitler.kategoriler[kategoriId] ?? "",
              ),
            );
          }).toList(),
          onChanged: (int? yeniDeger) {
            if (yeniDeger != null) {
              setState(() {
                _secilenKategori = yeniDeger;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          _kitaplar[index].id.toString(),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.edit,
            ),
            onPressed: () {
              _kitapGuncelle(context, index);
            },
          ),
          Checkbox(
            value: _secilenKitapIdleri.contains(_kitaplar[index].id),
            onChanged: (bool? yeniDeger) {
              if (yeniDeger != null) {
                int? kitapId = _kitaplar[index].id;
                if (kitapId != null) {
                  setState(() {
                    if (yeniDeger) {
                      _secilenKitapIdleri.add(kitapId);
                    } else {
                      _secilenKitapIdleri.remove(kitapId);
                    }
                  });
                }
              }
            },
          ),
        ],
      ),
      title: Text(_kitaplar[index].isim),
      subtitle: Text(Sabitler.kategoriler[_kitaplar[index].kategori] ?? ""),
      onTap: () {
        _bolumlerSayfasiniAc(context, index);
      },
    );
  }

  Widget _buildKitapEkleFab(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        _kitapEkle(context);
      },
    );
  }

  void _kitapEkle(BuildContext context) async {
    List<dynamic>? sonuc = await _pencereAc(context);

    if (sonuc != null && sonuc.length > 1) {
      String kitapAdi = sonuc[0];
      int kategori = sonuc[1];

      Kitap yeniKitap = Kitap(kitapAdi, DateTime.now(), kategori);
      int kitapIdsi = await _yerelVeriTabani.createKitap(yeniKitap);
      print("Kitap Idsi: $kitapIdsi");
      _kitaplar = [];
      setState(() {});
    }
  }

  void _kitapGuncelle(BuildContext context, int index) async {
    Kitap kitap = _kitaplar[index];

    List<dynamic>? sonuc = await _pencereAc(
      context,
      mevcutIsim: kitap.isim,
      mevcutKategori: kitap.kategori,
    );

    if (sonuc != null && sonuc.length > 1) {
      String yeniKitapAdi = sonuc[0];
      int yeniKategori = sonuc[1];

      if (kitap.isim != yeniKitapAdi || kitap.kategori != yeniKategori) {
        kitap.isim = yeniKitapAdi;
        kitap.kategori = yeniKategori;

        int guncellenenSatirSayisi = await _yerelVeriTabani.updateKitap(kitap);
        if (guncellenenSatirSayisi > 0) {
          setState(() {});
        }
      }
    }
  }

  void _kitapSil(int index) async {
    Kitap kitap = _kitaplar[index];
    int silinenSatirSayisi = await _yerelVeriTabani.deleteKitap(kitap);
    if (silinenSatirSayisi > 0) {
      _kitaplar = [];
      setState(() {});
    }
  }

  void _seciliKitaplariSil() async {
    int silinenSatirSayisi = await _yerelVeriTabani.deleteKitaplar(
      _secilenKitapIdleri,
    );
    if (silinenSatirSayisi > 0) {
      _kitaplar = [];
      setState(() {});
    }
  }

  Future<void> _ilkKitaplariGetir() async {
    if(_kitaplar.isEmpty) {
      _kitaplar = await _yerelVeriTabani.readTumKitaplar(_secilenKategori, 0);
      print("İlk kitaplar");
      for(Kitap k in _kitaplar){
        print("${k.isim}, ");
      }
    }
  }

  Future<void> _sonrakiKitaplariGetir() async {
    int? sonKitapId = _kitaplar.last.id;

    if (sonKitapId != null) {
      List<Kitap> sonrakiKitaplar = await _yerelVeriTabani.readTumKitaplar(
        _secilenKategori,
        sonKitapId,
      );
      _kitaplar.addAll(sonrakiKitaplar);
      print("Sonraki kitaplar");
      for(Kitap k in _kitaplar){
        print("${k.isim}, ");
      }
      setState(() {});
    }
  }

  Future<List<dynamic>?> _pencereAc(
    BuildContext context, {
    String mevcutIsim = "",
    int mevcutKategori = 0,
  }) {
    TextEditingController isimController = TextEditingController(
      text: mevcutIsim,
    );

    return showDialog<List<dynamic>>(
      context: context,
      builder: (context) {
        int kategori = mevcutKategori;

        return AlertDialog(
          title: Text("Kitap Adını Giriniz"),
          content: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: isimController,
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Kategori:"),
                      DropdownButton<int>(
                        value: kategori,
                        items: Sabitler.kategoriler.keys.map((kategoriId) {
                          return DropdownMenuItem<int>(
                            value: kategoriId,
                            child: Text(
                              Sabitler.kategoriler[kategoriId] ?? "",
                            ),
                          );
                        }).toList(),
                        onChanged: (int? yeniDeger) {
                          if (yeniDeger != null) {
                            setState(() {
                              kategori = yeniDeger;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text("İptal"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("Onayla"),
              onPressed: () {
                Navigator.pop(context, [isimController.text.trim(), kategori]);
              },
            ),
          ],
        );
      },
    );
  }

  void _bolumlerSayfasiniAc(BuildContext context, int index) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (context) {
        return BolumlerSayfasi(_kitaplar[index]);
      },
    );
    Navigator.push(context, sayfaYolu);
  }

  void _kaydirmaKontrol() {
    if(_scrollController.offset == _scrollController.position.maxScrollExtent){
      _sonrakiKitaplariGetir();
    }
  }
}
