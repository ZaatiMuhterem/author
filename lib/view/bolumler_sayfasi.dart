import 'package:flutter/material.dart';
import 'package:yazar/model/bolum.dart';
import 'package:yazar/model/kitap.dart';
import 'package:yazar/view/bolum_detay_sayfasi.dart';
import 'package:yazar/yerel_veri_tabani.dart';

class BolumlerSayfasi extends StatefulWidget {
  final Kitap _kitap;

  const BolumlerSayfasi(this._kitap, {super.key});

  @override
  State<BolumlerSayfasi> createState() => _BolumlerSayfasiState();
}

class _BolumlerSayfasiState extends State<BolumlerSayfasi> {
  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();

  List<Bolum> _bolumler = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildBolumEkleFab(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget._kitap.isim),
    );
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: _tumBolumleriGetir(),
      builder: _buildListView,
    );
  }

  Widget _buildListView(BuildContext context, AsyncSnapshot<void> snapshot) {
    return ListView.builder(
      itemCount: _bolumler.length,
      itemBuilder: _buildListItem,
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          _bolumler[index].id.toString(),
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
              _bolumGuncelle(context, index);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
            ),
            onPressed: () {
              _bolumSil(index);
            },
          ),
        ],
      ),
      title: Text(_bolumler[index].baslik),
      onTap: (){
        _bolumDetaySayfasiniAc(context, index);
      },
    );
  }

  Widget _buildBolumEkleFab(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        _bolumEkle(context);
      },
    );
  }

  void _bolumEkle(BuildContext context) async {
    String? bolumBasligi = await _pencereAc(context);
    int? kitapId = widget._kitap.id;

    if (bolumBasligi != null && kitapId != null) {
      Bolum yeniBolum = Bolum(kitapId, bolumBasligi);
      int bolumIdsi = await _yerelVeriTabani.createBolum(yeniBolum);
      print("Bolum Idsi: $bolumIdsi");
      setState(() {});
    }
  }

  void _bolumGuncelle(BuildContext context, int index) async {
    String? yeniBolumBasligi = await _pencereAc(context);

    if (yeniBolumBasligi != null) {
      Bolum bolum = _bolumler[index];
      bolum.baslik = yeniBolumBasligi;
      int guncellenenSatirSayisi = await _yerelVeriTabani.updateBolum(bolum);
      if (guncellenenSatirSayisi > 0) {
        setState(() {});
      }
    }
  }

  void _bolumSil(int index) async {
    Bolum bolum = _bolumler[index];
    int silinenSatirSayisi = await _yerelVeriTabani.deleteBolum(bolum);
    if (silinenSatirSayisi > 0) {
      setState(() {});
    }
  }

  Future<void> _tumBolumleriGetir() async {
    int? kitapId = widget._kitap.id;

    if(kitapId != null) {
      _bolumler = await _yerelVeriTabani.readTumBolumler(kitapId);
    }
  }

  Future<String?> _pencereAc(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        String? sonuc;

        return AlertDialog(
          title: Text("Bölüm Adını Giriniz"),
          content: TextField(
            onChanged: (yeniDeger) {
              sonuc = yeniDeger;
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
                Navigator.pop(context, sonuc);
              },
            ),
          ],
        );
      },
    );
  }

  void _bolumDetaySayfasiniAc(BuildContext context, int index) {
    MaterialPageRoute sayfaYolu = MaterialPageRoute(
      builder: (context) {
        return BolumDetaySayfasi(_bolumler[index]);
      },
    );
    Navigator.push(context, sayfaYolu);
  }
}
