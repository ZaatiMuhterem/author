import 'package:flutter/material.dart';
import 'package:yazar/view/kitaplar_sayfasi.dart';

void main() {
  runApp(AnaUygulama());
}

class AnaUygulama extends StatelessWidget {
  const AnaUygulama({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KitaplarSayfasi(),
      debugShowCheckedModeBanner: false,
    );
  }
}
