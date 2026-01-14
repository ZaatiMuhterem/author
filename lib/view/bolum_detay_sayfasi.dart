import 'package:flutter/material.dart';
import 'package:yazar/model/bolum.dart';
import 'package:yazar/yerel_veri_tabani.dart';

class BolumDetaySayfasi extends StatelessWidget {
  final Bolum _bolum;

  YerelVeriTabani _yerelVeriTabani = YerelVeriTabani();
  TextEditingController _icerikController = TextEditingController();

  BolumDetaySayfasi(this._bolum, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_bolum.baslik),
      actions: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: _icerigiKaydet,
        ),
      ],
    );
  }

  Widget _buildBody() {
    _icerikController.text = _bolum.icerik;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _icerikController,
        maxLines: 1000,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _icerigiKaydet() async {
    _bolum.icerik = _icerikController.text;
    await _yerelVeriTabani.updateBolum(_bolum);
  }
}
